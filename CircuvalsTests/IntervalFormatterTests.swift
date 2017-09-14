import XCTest
import CoreData

@testable import Circuvals

class IntervalFormatterTests: XCTestCase {
    
    let persistentContainer = TestHelper.persistentContainer

    func testType() {
        let int1 = Interval(duration: 100, type: .cooldown, context: persistentContainer.viewContext)
        let fmt1 = IntervalFormatter(interval: int1)
        XCTAssertEqual(fmt1.type, "Cooldown")
        
        let int2 = Interval(duration: 100, type: .high, context: persistentContainer.viewContext)
        let fmt2 = IntervalFormatter(interval: int2)
        XCTAssertEqual(fmt2.type, "High")
    }
    
    func testDuration() {
        let int1 = Interval(duration: 100, type: .cooldown, context: persistentContainer.viewContext)
        let fmt1 = IntervalFormatter(interval: int1)
        XCTAssertEqual(fmt1.duration, "10 sec")
    }
    
    
}
