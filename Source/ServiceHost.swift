// MARK: - Service Host -
//------------------------------------------------------------------------------
public protocol ServiceHost {
    /// - parameter scheme: The service's `scheme`. Example: `https`, `file`.
    static var scheme: String { get }

    /// - parameter host: The service's host. Example: `example.com`.
    static var host: String { get }

    /// - parameter path: An appended root path. Example: `v2`, `api`.
    static var path: String? { get }
}
