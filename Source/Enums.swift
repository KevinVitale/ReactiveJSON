// MARK: - Auth Token -
//------------------------------------------------------------------------------
public enum AuthToken: Equatable {
    case OAuth2(token: String)
    case None

    //--------------------------------------------------------------------------
    func apply(to request: NSMutableURLRequest) {
        switch self {
        case .OAuth2(let token):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        default: ()
        }
    }
}

// MARK: - Equatibility -
//------------------------------------------------------------------------------
public func ==(lhs: AuthToken, rhs: AuthToken) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None): return true
    case (.OAuth2(let lhsToken), .OAuth2(let rhsToken)): return lhsToken == rhsToken
    default: return false
    }
}

// MARK: - Request Method -
//------------------------------------------------------------------------------
public enum RequestMethod: String {
    case Get = "GET"
    case Post = "POST"
    case Delete = "DELETE"
    case Put = "PUT"
}
