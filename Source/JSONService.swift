import ReactiveCocoa

// MARK: -
// MARK: JSON Service
// MARK: -
/**
 A singleton where the `InstanceType` is a `ServiceHostType`.
 */
public protocol JSONService: Singleton {
    associatedtype InstanceType: ServiceHostType
}

// MARK: -
// MARK: Extension, Request
// MARK: -
extension JSONService {
    /**
     Performs a JSON request.
     
     - parameter endpoint: The endpoint string.
     - parameter method: How the request should be made. Defaults to `GET`.
     - parameter parameters: Optional request parameters.
     
     - returns: A signal that, when started, sends `T` values parsed from response, or an error.
     */
    public static func request<T>(endpoint endpoint: String, method: RequestMethodType = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<T, NetworkError> {
        return sharedInstance()
            .request(endpoint: endpoint, method: method, parameters: parameters, token: token)
    }
    
    /**
     Performs a JSON request, automatically mapping the result to an instance of `R`.

     - parameter endpoint: The endpoint string.
     - parameter method: How the request should be made. Defaults to `GET`.
     - parameter parameters: Optional request parameters.
     
     - returns: A signal that, when started, sends `R` values parsed from response, or an error.
     */
    public static func request<R: ResourceJSON>(endpoint endpoint: String, method: RequestMethodType = .Get, parameters: [String : AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<R, NetworkError> {
        return request(endpoint: endpoint, method: method, parameters: parameters, token: token)
            .mapResourceJSON()
    }
}
