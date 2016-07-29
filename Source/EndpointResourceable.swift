public struct EndpointResource<R: Resourceable>: EndpointResourceable {
    //--------------------------------------------------------------------------
    public typealias Resource = R
    //--------------------------------------------------------------------------
    public let resources: [R]
    //--------------------------------------------------------------------------
    public init?(_ response: Any?) {
        switch response {
        case let array as [AnyObject]:
            resources = array
                .map {
                    switch $0 {
                    case let json as [String:AnyObject]:
                        return R(json)
                    default:
                        return R([:])
                    }
                }
                .flatMap { $0 }
        case let dictionary as [String:AnyObject]:
            resources = [R(dictionary)].flatMap { $0 }
        default:
            resources = []
        }
    }
    //--------------------------------------------------------------------------
}

public protocol EndpointResourceable {
    associatedtype Resource: Resourceable
    var resources: [Resource] { get }
}

extension EndpointResourceable {
    public var count: Int {
        return resources.count
    }

    public subscript(index: Int) -> Resource? {
        return resources[index]
    }

    public var first: Resource? {
        return resources.first
    }
}

