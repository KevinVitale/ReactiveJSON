public struct Resource<I: Hashable>: Resourceable {
    //--------------------------------------------------------------------------
    public typealias IdentityValue = I
    public typealias Attributes = JSONResource
    //--------------------------------------------------------------------------
    public var id: IdentityValue? {
        return self["id"] as? IdentityValue
    }
    //--------------------------------------------------------------------------
    public let attributes: Attributes?
    //--------------------------------------------------------------------------
    public init(_ json: [String:AnyObject]) {
        attributes = Attributes(json)
    }
}
