import XCTest
@testable import PGNKit

class OutcomeTests: XCTestCase {   
    func testInitFromString() {
        XCTAssertEqual(Outcome(from: "1-0"), .decisive(winner: .white))
        XCTAssertEqual(Outcome(from: "0-1"), .decisive(winner: .black))
        XCTAssertEqual(Outcome(from: "1/2-1/2"), .draw)
        XCTAssertEqual(Outcome(from: "*"), .unknown)
        XCTAssertNil(Outcome(from: "invalid"))
    }
}
