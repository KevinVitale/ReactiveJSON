public protocol Resourceable: ResourceJSON, Identifiable {
    associatedtype Attributes: ResourceJSON
    var attributes: Attributes? { get }
}

extension Resourceable {
    public static func parse<E: EndpointResourceable>(json: Any?) -> E? {
        return nil
    }
}

extension Resourceable where Attributes == JSONResource {
    public subscript(key: String) -> AnyObject? {
        return attributes?.json[key]
    }
}
