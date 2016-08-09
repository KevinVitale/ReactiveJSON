import Quick
import Nimble
@testable import ReactiveJSON

class ServiceHostTypeTests: QuickSpec {
    override func spec() {
        describe("protocol conformance") {
            it("has proper scheme") {
                expect(GW2API.scheme).to(equal("https"))
            }

            it("has proper host") {
                expect(GW2API.host).to(equal("api.guildwars2.com"))
            }

            it("has proper path") {
                expect(GW2API.path).to(equal(GW2API.path))
            }
        }

        describe("URL extensions") {
            it("has correct base URL string") {
                let expectedBaseURLString = "https://api.guildwars2.com/v2"
                expect(GW2API.baseURLString).to(equal(expectedBaseURLString))
            }

            it("generates non-nil URL") {
                let endpointPath = "colors"
                let url = GW2API.URLString(with: endpointPath)
                expect(url).toNot(beNil())
            }

            it("generates URL request from endpoint path") {
                let endpointPath = "colors"
                let request = GW2API.URLRequest(endpointPath)
                expect(request).toNot(beNil())
            }

            it("generates URL request from endpoint path, with parameters") {
                let endpointPath = "colors"
                let request = GW2API.URLRequest(endpointPath, parameters: ["kevin": "true"])
                let components = NSURLComponents(URL: request!.URL!, resolvingAgainstBaseURL: true)
                expect(components?.queryItems).toNot(beNil())
            }

            it("generates URL request from endpoint path, with 'POST' method") {
                let endpointPath = "colors"
                let request = GW2API.URLRequest(endpointPath, method: .Post)
                expect(request?.HTTPMethod).to(equal(RequestMethod.Post.rawValue))
            }
        }
    }
}
