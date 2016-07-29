import ReactiveCocoa
import Result

// MARK: -
// MARK: Resource JSON
// MARK: -
public protocol ResourceJSON {
    /**
     Parses the receiver from the given `json`, or returns `nil` if parsing faile.
     
     - parameter json: A JSON object.
     */
    init?(_ json: [String:AnyObject])
}

// MARK: -
// MARK: Extension, Map Resource JSON
// MARK: -
extension SignalProducerType where Value == [String:AnyObject], Error == NetworkError {
    internal func mapResourceJSON<R: ResourceJSON>() -> SignalProducer<R, Error> {
        return attemptMap { json -> Result<R, Error> in
            if let resource = R(json) {
                return .Success(resource)
            } else {
                return .Failure(NetworkError.IncorrectDataReturned)
            }
        }
    }
}

