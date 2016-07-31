public protocol EndpointResourceable: CollectionType, ArrayLiteralConvertible {
    init<S: SequenceType where S.Generator.Element == [String:AnyObject]>(_ s: S)
}
