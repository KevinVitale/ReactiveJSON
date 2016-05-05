import ReactiveCocoa
import Result

/// - parameter Session: A private instance of `NSURLSession`.
private let Session = NSURLSession.sharedSession()

// MARK: -
// MARK: Map JSON
// MARK: -
extension SignalProducerType where Value == NSData, Error == NetworkError {
    /**
     Attempts to convert `NSData` values into `AnyObject` JSON objects.

     - returns: An event stream that sends the result of `NSJSONSerialization.JSONObjectWithData`, or an error.
     */
    private func _mapJSON() -> SignalProducer<AnyObject, NetworkError> {
        return attemptMap { data -> Result<AnyObject, NetworkError> in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                return .Success(json)
            } catch _ {
                return .Failure(NetworkError.IncorrectDataReturned)
            }
        }
    }
}

// MARK: -
// MARK: Map JSON Response
// MARK: -
extension SignalProducerType where Value == (NSData, NSURLResponse), Error == NetworkError {
    /**
     Attempts to convert `NSData` values (ignore `NSURLResponse`) into `AnyObject` JSON objects.
     
     - returns: An event stream that sends the result of `NSJSONSerialization.JSONObjectWithData`, or an error.
     */
    private func _mapJSONResponse() -> SignalProducer<AnyObject, NetworkError> {
        return map { $0.0 }
            ._mapJSON()
    }
}

// MARK: -
// MARK: Map Network Error
// MARK: -
extension SignalProducerType where Error == NSError {
    /**
     Maps `NSError` into `NetworkError`.
     
     - returns: An event stream that relies on `NetworkError` types.
     */
    public func mapNetworkError() -> SignalProducer<Value, NetworkError> {
        return mapError { NetworkError(error: $0) }
    }
}

// MARK: -
// MARK: Extension, Signal
// MARK: -
public extension SignalType {
    /**
     Returns a signal that silences any errors.
     */
    @warn_unused_result(message="Did you forget to call `observe` on the signal?")
    func ignoreError() -> Signal<Value, NoError> {
        return flatMapError { error in
            print("An error occurred: ", error)
            return SignalProducer.empty }
    }
    
    /**
     Try to cast `Value` to some type `T`.
     `nil` if the attempt fails.

     Equivalent to map { $0 as? T }
     */
    @warn_unused_result(message="Did you forget to call `observe` on the signal?")
    func castTo<T>(_ : T.Type) -> Signal<T?, Error> {
        return map { $0 as? T }
    }
}

// MARK: -
// MARK: Extension, Signal Producer
// MARK: -
public extension SignalProducerType {
    /**
     Returns a signal producer that silences any errors.
     */
    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    func ignoreError() -> SignalProducer<Value, NoError> {
        return flatMapError { error in
            print("An error occurred: ", error)
            return SignalProducer.empty }
    }
    
    /**
     Try to cast `Value` to some type `T`.
     `nil` if the attempt fails.

     Equivalent to map { $0 as? T }
     */
    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    func castTo<T>(_ : T.Type) -> SignalProducer<T?, Error> {
        return lift { $0.castTo(T) }
    }
    
    /**
     Only forward `NEXT` values when sampler (or its latest value) is true
     */
    @warn_unused_result(message="Did you forget to call `start` on the producer?")
    func filterWhile(sampler: SignalProducer<Bool, NoError>) -> SignalProducer<Value, Error> {
        return combineLatestWith(sampler.promoteErrors(Error)).filter { $0.1 } .map { $0.0 }
    }
}

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
        ._mapJSONResponse()
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
