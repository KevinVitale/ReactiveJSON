// MARK: - Extension, Query Items -
//------------------------------------------------------------------------------
extension Dictionary where Value: AnyObject {
    fileprivate var queryItems: [URLQueryItem] {
        return map { (key: Key, value: AnyObject) in ("\(key)", value.description) }
            .map(URLQueryItem.init)
            .sorted { $0.0.name < $0.1.name }
    }

    var percentEncodedQuery: String? {
        var components = URLComponents()
        components.queryItems = queryItems
        let percentEncodedQuery = components.percentEncodedQuery
        return percentEncodedQuery
    }
}
