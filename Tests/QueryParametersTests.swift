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

            it("handles 'ids' parameter (comma-separated)") {
                let params: [String:AnyObject] = [ "ids" : "1,2,3,4,5" ]
                expect(params.percentEncodedQuery).to(equal("ids=1,2,3,4,5"))
            }

            it("handles url-encoding (special characters)") {
                let params: [String:AnyObject] = [
                    "email": "this+thing1@someplace.com",
                    "name": "Thing 1",
                    "password": "A12345!",
                    "username": "thing1",
                ]

                expect(params.percentEncodedQuery).to(equal("email=this+thing1@someplace.com&name=Thing%201&password=A12345!&username=thing1"))
            }
        }
    }
}
