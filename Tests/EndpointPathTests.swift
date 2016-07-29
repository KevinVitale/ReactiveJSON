import Quick
import Nimble
import ReactiveJSON

class EndpointPathTests: QuickSpec {
    private enum Endpoint: String {
        case SomeEndpoint = "someEndpoint"
    }

    override func spec() {
        describe("endpoint path") {
            it("creates from string") {
                let string = "kevin"
                expect(string).to(equal(string))
            }

            it("creates from enum") {
                let endpoint: Endpoint = .SomeEndpoint
                expect(endpoint.rawValue).to(equal(endpoint.rawValue))
            }
        }
    }
}
