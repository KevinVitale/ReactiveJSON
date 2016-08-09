import ReactiveCocoa
import Result

// MARK: -
// MARK: Map JSON Response
// MARK: -
extension SignalProducerType where Value == (NSData, NSURLResponse), Error == NetworkError {
    /**
     Attempts to convert `NSData` values (ignore `NSURLResponse`) into `AnyObject` JSON objects.

     - returns: An event stream that sends the result of `NSJSONSerialization.JSONObjectWithData`, or an error.
     */
    func mapJSONResponse() -> SignalProducer<(AnyObject, NSURLResponse), NetworkError> {
        return attemptMap { (data, response) in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                return .Success(json, response)
            } catch _ {
                return .Failure(NetworkError.IncorrectDataReturned)
            }
        }
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
            return SignalProducer.empty }
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
            return SignalProducer.empty }
    }
}
