import ReactiveCocoa
import Result

// MARK: -
// MARK: Resource JSON
// MARK: -
public protocol ResourceJSON {
    /**
     Parses the receiver from the given `json`, or returns `nil` if parsing faile.
     
     - parameter json: A JSON object.
     - returns: An instance of `Self`, or `nil`.
     */
    init?(_ json: [String:AnyObject])
}

