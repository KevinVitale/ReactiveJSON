// MARK: - JSON Resource -
public struct JSONResource: JSONConvertible {
    // MARK: - Public -
    //--------------------------------------------------------------------------
    /// - parameter json: The response object used to initialize the value.
    public private(set) var json: [String:AnyObject] = [:]

    // MARK: - Initializaiton -
    //--------------------------------------------------------------------------
    /// - returns: An instance of `JSONResource`, or `nil`.
    public init?(_ json: [String:AnyObject]) {
        self.json = json
    }
    /// - returns: An instance of `JSONResource` with an empty `json` value.
    public init() {
    }

    // MARK: - Subscript -
    //--------------------------------------------------------------------------
    public subscript(key: String) -> AnyObject? {
        return json[key]
    }
}
