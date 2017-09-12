import XCTest
import CoreData

@testable import Circuvals

class SetFormatterTests: XCTestCase {
    
    var set: Circuvals.Set!
    var emptySet: Circuvals.Set!
    var decorator = SetFormatter()

    let persistentContainer = TestHelper.persistentContainer

    override func setUp() {
        super.setUp()
        set = Circuvals.Set(title: "Title", context: persistentContainer.viewContext)
        set.addToIntervals(Interval(duration: 100, context: persistentContainer.viewContext))
        set.addToIntervals(Interval(duration: 600, context: persistentContainer.viewContext))
        emptySet = Circuvals.Set(title: "Title", context: persistentContainer.viewContext)
        decorator.set = set
    }
    
    func testRemainingInInterval() {
        XCTAssertEqual(decorator.remainingInInterval, "00:10")
        decorator.set = nil
        XCTAssertEqual(decorator.remainingInInterval, "--:--")
    }
    
    func testRemaining() {
        XCTAssertEqual(decorator.remaining, "01:10")
    }
    
    func testElapsed() {
        XCTAssertEqual(decorator.elapsed, "00:00")
    }
    
    func testElapsedInInterval() {
        XCTAssertEqual(decorator.elapsedInInterval, "00:00")
    }
    
    func testCurrentIntervalType() {
        XCTAssertEqual(decorator.currentIntervalType, "High")
        decorator.set = nil
        XCTAssertEqual(decorator.remainingInInterval, "--:--")
    }
    
    func testIntervalOfIntervals() {
        XCTAssertEqual(decorator.intervalOfIntervals, "1/2")
        decorator.set = nil
        XCTAssertEqual(decorator.intervalOfIntervals, "-/-")
    }

    func testIntervalOfActiveIntervals() {
        XCTAssertEqual(decorator.intervalOfActiveIntervals, "1/2")
        decorator.set = nil
        XCTAssertEqual(decorator.intervalOfIntervals, "-/-")
    }

    
    func testIntervalOfIntervalsSpoken() {
        XCTAssertEqual(decorator.intervalOfActiveIntervalsSpoken, "1 of 2")
        decorator.set = nil
        XCTAssertEqual(decorator.intervalOfActiveIntervalsSpoken, "")
    }

    
    func testTitle() {
        XCTAssertEqual(decorator.title, "Title")
        decorator.set = nil
        XCTAssertEqual(decorator.title, "No Title")
    }
    
    func testDescription() {
        XCTAssertEqual(decorator.setDescription, "2 Intervals, 1 min, 10 sec")
        decorator.set = nil
        XCTAssertEqual(decorator.title, "No Title")
        
        set = Circuvals.Set(title: "Title", context: persistentContainer.viewContext)
        set.addToIntervals(Interval(duration: 100, context: persistentContainer.viewContext))
        decorator.set = set
        XCTAssertEqual(decorator.setDescription, "1 Interval, 10 sec")
        
        set.addToIntervals(Interval(duration: 100, type: .relax, context: persistentContainer.viewContext))
        XCTAssertEqual(decorator.setDescription, "1 Interval, 20 sec")
        
        decorator.set = emptySet
        XCTAssertEqual(decorator.setDescription, "0 Intervals, 0 sec")
        
        decorator.set = nil
        XCTAssertEqual(decorator.setDescription, "")
    }
    
    func testInterval() {
        XCTAssertEqual(decorator.interval(amount: 1), "Interval")
        XCTAssertEqual(decorator.interval(amount: 0), "Intervals")
        XCTAssertEqual(decorator.interval(amount: 3), "Intervals")
    }
    
    func testFormat() {
        
    }
}
