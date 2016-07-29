import ReactiveCocoa

// MARK: -
// MARK: Service Host Type
// MARK: -
public protocol ServiceHostType {
    static var scheme: String { get }
    static var host: String { get }
    static var path: String? { get }
}

public enum RequestMethodType: String {
    case Get = "GET"
    case Post = "POST"
    case Delete = "DELETE"
    case Put = "PUT"
}

public func ==(lhs: AuthToken, rhs: AuthToken) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None): return true
    case (.OAuth2(let lhsToken), .OAuth2(let rhsToken)): return lhsToken == rhsToken
    default: return false
    }
}

public enum AuthToken: Equatable {
    case OAuth2(token: String)
    case None

    private func apply(to request: NSMutableURLRequest) {
        switch self {
        case .OAuth2(let token):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        default: ()
        }
    }
}

// MARK: -
// MARK: Extension, URL
// MARK: -
extension ServiceHostType {
    internal static var baseURLString: String {
        var baseURLString = "\(Self.scheme)://\(Self.host)"
        if let path = Self.path {
            baseURLString += "/\(path)"
        }
        return baseURLString
    }

    internal static func URLWith(endpointPath: String) -> NSURL? {
        return NSURL(string: "\(Self.baseURLString)/" + ("\(endpointPath.stringByReplacingOccurrencesOfString("//", withString: "/"))"))
    }

    internal static func URLRequest(endpointPath: String, method: RequestMethodType = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> NSURLRequest? {
        guard
            let baseURL = Self.URLWith(endpointPath),
            let components = NSURLComponents(string: baseURL.absoluteString)
        else {
            return nil
        }

        var request: NSMutableURLRequest!

        // Set the query parameters
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

        request.HTTPMethod = method.rawValue

        token.apply(to: request)
        return request
    }
}

// MARK: -
// MARK: Request
// MARK: -
extension ServiceHostType {
    func request<T>(endpoint endpoint: String, method: RequestMethodType = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<T, NetworkError> {
        return JSONRequest(Self.self, endpointPath: endpoint, method: method, parameters: parameters, token: token)
    }
}
