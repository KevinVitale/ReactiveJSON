// MARK: - Extension, Query Items -
//------------------------------------------------------------------------------
extension Dictionary where Value: AnyObject {
    private var queryItems: [NSURLQueryItem] {
        return map { (key: Key, value: AnyObject) in ("\(key)", value.description) }
            .map(NSURLQueryItem.init)
            .sort { $0.0.name < $0.1.name }
    }

    var percentEncodedQuery: String? {
        let components = NSURLComponents()
        components.queryItems = queryItems
        let percentEncodedQuery = components.percentEncodedQuery
        return percentEncodedQuery
    }
}
