// MARK: - Typealias, KeyValuePair -
//------------------------------------------------------------------------------
/// - returns: A tuple with `key` and a `value`.
typealias KeyValuePair = (key: String, value: AnyObject)

// MARK: - Extension, Query Items -
//------------------------------------------------------------------------------
extension SequenceType where Generator.Element == KeyValuePair {
    private func queryItems() -> [NSURLQueryItem] {
        return map { NSURLQueryItem( name: $0.key, value: $0.value.description) }
            .sort { $0.0.name < $0.1.name }
    }

    var percentEncodedQuery: String? {
        let components = NSURLComponents()
        components.queryItems = queryItems()
        let percentEncodedQuery = components.percentEncodedQuery
        return percentEncodedQuery
    }
}
