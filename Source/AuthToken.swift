// MARK: - Auth Token -
//------------------------------------------------------------------------------
public enum AuthToken: Equatable {
    case oAuth2(token: String)
    case none

    //--------------------------------------------------------------------------
    func apply(to request: NSMutableURLRequest) {
        switch self {
        case .oAuth2(let token):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        default: ()
        }
    }
}

// MARK: - Equatibility -
//------------------------------------------------------------------------------
public func ==(lhs: AuthToken, rhs: AuthToken) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case (.oAuth2(let lhsToken), .oAuth2(let rhsToken)): return lhsToken == rhsToken
    default: return false
    }
}
