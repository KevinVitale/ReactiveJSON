import ReactiveSwift
import Result

// MARK: - JSON Service -
//------------------------------------------------------------------------------
extension Singleton where Instance: ServiceHost {
    public static func request<T>(endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .none) -> SignalProducer<(T, URLResponse), NetworkError> {
        return Instance.request(endpoint: endpoint, method: method, parameters: parameters, token: token)
            .attemptMap {
                guard let t = $0.0 as? T else {
					if let httpResponse = $0.1 as? HTTPURLResponse, httpResponse.statusCode == 401 {
						return .failure(NetworkError.unauthorized)
					}
                    return .failure(NetworkError.incorrectDataReturned)
                }
				if let httpResponse = $0.1 as? HTTPURLResponse, httpResponse.statusCode == 401 {
					return .failure(NetworkError.unauthorized)
				}
                return .success(t, $0.1)
        }
    }
    public static func request<T>(endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .none) -> SignalProducer<T,NetworkError> {
        return request(endpoint: endpoint, method: method, parameters: parameters, token: token).map { $0.0 }
    }
    //--------------------------------------------------------------------------
    public static func request<J: JSONConvertible>(endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .none) -> SignalProducer<([J], URLResponse), NetworkError> {
        return Instance.request(endpoint: endpoint, method: method, parameters: parameters, token: token)
            .attemptMap{
				if let httpResponse = $0.1 as? HTTPURLResponse, httpResponse.statusCode == 401 {
					return .failure(NetworkError.unauthorized)
				}
                switch $0.0 {
                case let json as [[String:AnyObject]]:
                    return .success(json.map({ J($0) }).flatMap({ $0 }), $0.1)
                case let json as [String:AnyObject]:
                    return .success([json].map({ J($0) }).flatMap({ $0 }), $0.1)
                default:
                    return .failure(NetworkError.incorrectDataReturned)
                }
        }
    }
    public static func request<J: JSONConvertible>(endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .none) -> SignalProducer<J, NetworkError> {
        return request(endpoint: endpoint, method: method, parameters: parameters, token: token)
            .flatMap(.merge) { (values: [J], response: URLResponse) in
                SignalProducer<J, NetworkError>(values)
        }
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
        return "\(baseURLString)/" + ("\(endpoint.replacingOccurrences(of: "//", with: "/"))")
    }

    static func URLRequest(_ endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .none) -> Foundation.URLRequest? {
        guard var components = URLComponents(string: URLString(with: endpoint)) else {
            return nil
        }

        var request: NSMutableURLRequest!
        
        switch method {
        case .Put: fallthrough
        case .Post:
            request = NSMutableURLRequest(url: components.url!)
            request.setValue(
                "application/x-www-form-urlencoded; charset=utf-8",
                forHTTPHeaderField: "Content-Type"
            )
            request.httpBody = parameters?.percentEncodedQuery?.data(using: String.Encoding.utf8)
        default:
            components.percentEncodedQuery = parameters?.percentEncodedQuery
            request = NSMutableURLRequest(url: components.url!)
        }

        //----------------------------------------------------------------------
        request.httpMethod = method.rawValue
        token.apply(to: request)

        //----------------------------------------------------------------------
        return request as URLRequest?
    }
    
    //--------------------------------------------------------------------------
    static func request(_ session: URLSession = URLSession.shared, endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .none) -> SignalProducer<(Any, URLResponse), NetworkError> {
        guard let request = URLRequest(endpoint, method: method, parameters: parameters, token: token) else {
            return SignalProducer(error: NetworkError.unknown)
        }

        return session.reactive
            .data(with: request)
            .mapNetworkError()
            .mapJSONResponse()
    }

    static func request<C: Collection>(_ session: URLSession = URLSession.shared, endpoint: String, method: RequestMethod = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .none) -> SignalProducer<(C, URLResponse), NetworkError> {
        return request(session, endpoint: endpoint, method: method, parameters: parameters, token: token)
            .attemptMap { (json, response) -> Result<(C, URLResponse), NetworkError> in
                switch (Mirror(reflecting: json).displayStyle, json) {
                case (.some(.collection), let json as C):
                    return .success(json, response)
                default:
                    let error = NetworkError.incorrectDataReturned
                    return .failure(error)
                }
        }
    }
}
