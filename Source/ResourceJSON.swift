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

// MARK: -
// MARK: JSON Resource
// MARK: -
/**
 A generic response that provides public access to `json`.
 */
public struct JSONResource: ResourceJSON {
    /// - parameter json: The response object used to initialize the value.
    public let json: [String:AnyObject]

    /**
     Initializes a new JSON resource value.
     
     - parameter json: The resource object.
     */
    public init?(_ json: [String:AnyObject]) {
        self.json = json
    }

    public init() {
        self.json = [:]
    }

    public subscript(key: String) -> AnyObject? {
        return json[key]
    }
}
