import XCTest
import CoreData

@testable import Circuvals

class IntervalTypeTest: XCTestCase {
    func testReadable() {
        XCTAssertEqual(IntervalType.cooldown.readable(), "Cooldown")
        XCTAssertEqual(IntervalType.prepare.readable(), "Prepare")
    }
}

class IntervalTests: XCTestCase {

    let persistentContainer = TestHelper.persistentContainer
    
    func testFetchRequest() {
        let request: NSFetchRequest<Circuvals.Interval> = Circuvals.Interval.fetchRequest()
        XCTAssertNotNil(request)
        XCTAssertEqual(request.entityName, "Interval")
    }

    func testIsActive() {
        let moc = persistentContainer.viewContext
        XCTAssertTrue(Interval(duration: 10, type: .high, context: moc).isActive)
        XCTAssertTrue(Interval(duration: 10, type: .low, context: moc).isActive)
        XCTAssertFalse(Interval(duration: 10, type: .relax, context: moc).isActive)
        XCTAssertFalse(Interval(duration: 10, type: .prepare, context: moc).isActive)
        XCTAssertTrue(Interval(duration: 10, type: .warmup, context: moc).isActive)
        XCTAssertFalse(Interval(duration: 10, type: .cooldown, context: moc).isActive)
    }
    
}
