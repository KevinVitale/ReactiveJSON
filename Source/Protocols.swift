import ReactiveCocoa
import Result

// MARK: - Identity -
//------------------------------------------------------------------------------
public protocol Identity {
    /// The identity's `TYPE` value.
    associatedtype Value: Hashable

    /// - parameter id: A unique identifying value.
    var id: Value? { get }
}

// MARK: - Int, Identity -
//------------------------------------------------------------------------------
extension Int: Identity {
    public typealias Value = Int
    public var id: Value? {
        return self
    }
}

// MARK: - String, Identity -
//------------------------------------------------------------------------------
extension String: Identity {
    public typealias Value = String
    public var id: Value? {
        return self
    }
}

// MARK: - JSON Service -
//------------------------------------------------------------------------------
extension Singleton where Instance: ServiceHost {
    public static func request<T>(endpoint endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<(T, NSURLResponse), NetworkError> {
        return Instance.request(endpoint: endpoint, method: method, parameters: parameters, token: token)
            .attemptMap {
                guard let t = $0.0 as? T else {
                    return .Failure(NetworkError.IncorrectDataReturned)
                }
                return .Success(t, $0.1)
        }
    }
    public static func request<T>(endpoint endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<T,NetworkError> {
        return request(endpoint: endpoint, method: method, parameters: parameters, token: token).map { $0.0 }
    }
    //--------------------------------------------------------------------------
    public static func request<J: JSONConvertible>(endpoint endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<([J], NSURLResponse), NetworkError> {
        return Instance.request(endpoint: endpoint, method: method, parameters: parameters, token: token)
            .attemptMap{
                switch $0.0 {
                case let json as [[String:AnyObject]]:
                    return .Success(json.map({ J($0) }).flatMap({ $0 }), $0.1)
                case let json as [String:AnyObject]:
                    return .Success([json].map({ J($0) }).flatMap({ $0 }), $0.1)
                default:
                    return .Failure(NetworkError.IncorrectDataReturned)
                }
        }
    }
    public static func request<J: JSONConvertible>(endpoint endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<J, NetworkError> {
        return request(endpoint: endpoint, method: method, parameters: parameters, token: token)
            .flatMap(.Merge) { (values: [J], response: NSURLResponse) in
                SignalProducer<J, NetworkError>(values:values)
        }
    }
}

// MARK: - JSON Convertible -
//------------------------------------------------------------------------------
public protocol JSONConvertible {
    /**
     Parses the receiver from the given `json`, or returns `nil` if parsing faile.
     
     - parameter json: A JSON object.
     - returns: An instance of `Self`, or `nil`.
     */
    init?(_ json: [String:AnyObject])
}

// MARK: - Resource -
//------------------------------------------------------------------------------
public protocol Resource: JSONConvertible, Identity {
    /// The resource's attributes.
    associatedtype Attributes

    /// - parameter attributes: A native representation of the resource.
    var attributes: Attributes? { get }
}

extension Resource where Attributes == JSONResource {
    public subscript(key: String) -> AnyObject? {
        return attributes?.json[key]
    }
}

extension ServiceHost {
    /// - parameter baseURLString: _"(scheme)://(host)/(path?)"_
    static var baseURLString: String {
        var baseURLString = "\(scheme)://\(host)"
        if let path = path {
            baseURLString += "/\(path)"
        }
        return baseURLString
    }

    //--------------------------------------------------------------------------
    static func URLString(with endpoint: String) -> String {
        return "\(baseURLString)/" + ("\(endpoint.stringByReplacingOccurrencesOfString("//", withString: "/"))")
    }

    static func URLRequest(endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> NSURLRequest? {
        guard let components = NSURLComponents(string: URLString(with: endpoint)) else {
            return nil
        }

        //----------------------------------------------------------------------
        var request: NSMutableURLRequest!

        //----------------------------------------------------------------------
        switch method {
        case .Put: fallthrough
        case .Post:
            request = NSMutableURLRequest(URL: components.URL!)
            request.setValue(
                "application/x-www-form-urlencoded; charset=utf-8",
                forHTTPHeaderField: "Content-Type"
            )
           request.HTTPBody = parameters?.queryString().dataUsingEncoding(NSUTF8StringEncoding)
        default:
            components.queryItems = parameters?.queryItems()
            request = NSMutableURLRequest(URL: components.URL!)
        }

        //----------------------------------------------------------------------
        request.HTTPMethod = method.rawValue
        token.apply(to: request)

        //----------------------------------------------------------------------
        return request
    }
    
    //--------------------------------------------------------------------------
    static func request(session: NSURLSession = NSURLSession.sharedSession(), endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<(AnyObject, NSURLResponse), NetworkError> {
        guard let request = URLRequest(endpoint, method: method, parameters: parameters, token: token) else {
            return SignalProducer(error: NetworkError.Unknown)
        }
        
        return session
            .rac_dataWithRequest(request)
            .mapNetworkError()
            .mapJSONResponse()
    }

    static func request<C: CollectionType>(session: NSURLSession = NSURLSession.sharedSession(), endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<(C, NSURLResponse), NetworkError> {
        return request(session, endpoint: endpoint, method: method, parameters: parameters, token: token)
            .attemptMap { (json, response) -> Result<(C, NSURLResponse), NetworkError> in
                switch (Mirror(reflecting: json).displayStyle, json) {
                case (.Some(.Collection), let json as C):
                    return .Success(json, response)
                default:
                    let error = NetworkError.IncorrectDataReturned
                    return .Failure(error)
                }
        }
    }
}
