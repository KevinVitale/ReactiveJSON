public protocol Identifiable {
    associatedtype IdentityValue: Hashable
    var id: IdentityValue? { get }
}

extension Int: Identifiable {
    public typealias IdentityValue = Int
    public var id: IdentityValue? {
        return self
    }
}

extension String: Identifiable {
    public typealias IdentityValue = String
    public var id: IdentityValue? {
        return self
    }
}
