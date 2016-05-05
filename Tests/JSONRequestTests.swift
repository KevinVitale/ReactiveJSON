import Quick
import Nimble
import Network
import ReactiveCocoa

// TODO: Delete Me
struct GW2API: JSONService, ServiceHostType {
    static let _sharedInstance = GW2API()
    typealias InstanceType = GW2API
    static func sharedInstance() -> InstanceType {
        return _sharedInstance
    }
    static var scheme: String { return "https" }
    static var host: String { return "api.guildwars2.com" }
    static var path: String? { return "v2" }
}


class JSONRequestTests: QuickSpec {
    override func spec() {
        describe("json request") {
            it("returns 'nil' with bad endpoint path") {
                let request: SignalProducer<Any, NetworkError> = GW2API.request(endpoint: "")
                var error: NetworkError? = nil
                request.startWithFailed {
                    error = $0
                }
                expect(error).toNotEventually(beNil(), timeout: 5)
            }

            it("handles request as 'dictionary'") {
                var colors: [[String:AnyObject]] = []
                GW2API.request(endpoint: "colors", parameters: ["id": 4])
                    .collect()
                    .startWithNext {
                        colors = $0
                }
                expect(colors.count).toEventually(equal(1), timeout: 5)
            }

            it("handles request as 'int' collection") {
                var colors = []
                GW2API.request(endpoint: "colors")
                    .collect()
                    .startWithNext { (colorIDs: [Int]) in
                        colors = colorIDs
                }
                expect(colors.count).toEventually(equal(501), timeout: 5)
            }
        }
    }
}
