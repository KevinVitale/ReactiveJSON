/**
 */
public protocol Singleton {
    associatedtype InstanceType
    static func sharedInstance() -> InstanceType
}
