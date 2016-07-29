import Quick
import Nimble
@testable import ReactiveJSON

class QueryParametersTests: QuickSpec {
    override func spec() {
        describe("query parameters") {
            it("handles 'nil' parameters") {
                let params: [String:AnyObject] = [:]
                expect(params).to(beEmpty())
            }

            it("handles 'id' parameter (single)") {
                let params = ["id":5].queryItems()
                expect(params.count).to(equal(1))

                let queryItem = params.first!
                expect(queryItem.name).to(equal("id"))
                expect(queryItem.value).to(equal("5"))
            }

            it("handles 'ids' parameter (comma-separated)") {
                let params = ["ids":"1,2,3,4,5"].queryItems()
                expect(params.count).to(equal(1))

                let queryItem = params.first!
                expect(queryItem.name).to(equal("ids"))
                expect(queryItem.value).to(equal("1,2,3,4,5"))
            }

            it("handles url-encoding (whitespace)") {
                let params = ["id":"kevin vitale"].queryItems()
                expect(params.count).to(equal(1))

                let queryItem = params.first!
                expect(queryItem.name).to(equal("id"))
                expect(queryItem.value).to(equal("kevin%20vitale"))
            }
        }
    }
}
