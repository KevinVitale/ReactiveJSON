// MARK: - Resource -
//------------------------------------------------------------------------------
public protocol Resource: JSONConvertible, Identity {
    /// The resource's attributes.
    associatedtype Attributes

    /// - parameter attributes: A native representation of the resource.
    var attributes: Attributes? { get }
}

extension Resource where Attributes == JSONResource {
    public subscript(key: String) -> AnyObject? {
        return attributes?.json[key]
    }
}
