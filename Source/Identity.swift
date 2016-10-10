// MARK: - Identity -
//------------------------------------------------------------------------------
public protocol Identity {
    /// The identity's `TYPE` value.
    associatedtype Value: Hashable

    /// - parameter id: A unique identifying value.
    var id: Value? { get }
}

// MARK: - Int, Identity -
//------------------------------------------------------------------------------
extension Int: Identity {
    public typealias Value = Int
    public var id: Value? {
        return self
    }
}

// MARK: - String, Identity -
//------------------------------------------------------------------------------
extension String: Identity {
    public typealias Value = String
    public var id: Value? {
        return self
    }
}
