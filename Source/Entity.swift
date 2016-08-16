public struct Entity<I: Hashable>: Resource {
    // MARK: - Aliases -
    //--------------------------------------------------------------------------
    public typealias IdentityValue = I
    public typealias Attributes = JSONResource

    // MARK: - Computed -
    //--------------------------------------------------------------------------
    public var id: IdentityValue? {
        return self["id"] as? IdentityValue
    }

    // MARK: - Public -
    //--------------------------------------------------------------------------
    public let attributes: Attributes?

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public init(_ json: [String:AnyObject]) {
        attributes = Attributes(json)
    }
}
