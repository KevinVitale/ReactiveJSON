import ReactiveCocoa
import Result

/// - parameter Session: A private instance of `NSURLSession`.
private let Session = NSURLSession.sharedSession()

// MARK: -
// MARK: JSON Request
// MARK: -
/**
 Makes a JSON request.

 - parameter serviceHost: The `ServiceHostType` instance used to make the network request.
 - parameter endpointPath: The path used to construct the request URL.
 - parameter method: The type of request to be make.
 - parameter parameters: Optional request parameters.
 
 - returns: An event stream that returns the result of the JSON request, or an error.
 */
internal func JSONRequest<T>(serviceHost: ServiceHostType.Type, endpointPath: String, method: RequestMethodType = .Get, parameters: [String:AnyObject]? = nil, token: AuthToken = .None) -> SignalProducer<T, NetworkError> {
    guard let request = serviceHost.URLRequest(endpointPath, method: method, parameters: parameters, token: token) else {
        return SignalProducer(error: NetworkError.Unknown)
    }

    return Session
        .rac_dataWithRequest(request)
        .mapNetworkError()
        .mapJSONResponse()
        .attemptMap { json -> Result<[T], NetworkError> in
            switch json {
            case is [T]:
                return .Success(json as! [T])
            case is T:
                return .Success([json as? T].flatMap { $0 })
            default:
                let error = NetworkError.IncorrectDataReturned
                return .Failure(error)
            }
        }
        .flatMap(.Merge) { SignalProducer<T, NetworkError>(values: $0) }
}
