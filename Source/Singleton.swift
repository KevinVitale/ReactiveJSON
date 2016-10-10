// MARK: - Singleton -
//------------------------------------------------------------------------------
public protocol Singleton {
    /// The singleton's instance `TYPE` value.
    associatedtype Instance

    /// - parameter shared: The shared instance.
    static var shared: Instance { get }
}
