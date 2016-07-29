// MARK: -
// MARK: JSON Resource
// MARK: -
/**
 A "pass-through" response that provides public access to `json`.
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
