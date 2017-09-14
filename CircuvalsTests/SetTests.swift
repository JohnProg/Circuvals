import XCTest
import CoreData

@testable import Circuvals

class SetTests: XCTestCase {
    let persistentContainer = TestHelper.persistentContainer
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFetchRequest() {
        let request: NSFetchRequest<Circuvals.Set> = Circuvals.Set.fetchRequest()
        XCTAssertNotNil(request)
        XCTAssertEqual(request.entityName, "Set")
    }
    
    func testInterval() {
        XCTAssertNotNil(Interval(context: persistentContainer.viewContext))
        let interval = Interval(context: persistentContainer.viewContext)
        XCTAssertEqual(interval.duration, 1)
        interval.duration = 15
        XCTAssertEqual(interval.duration, 15)
    }
    
    func testIntervalDuration() {
        let interval = Interval(duration: 15, context: persistentContainer.viewContext)
        XCTAssertEqual(interval.duration, 15)
        XCTAssertEqual(interval.intervalType, IntervalType.high)
    }
    
    func testSetInit() {
        let moc = persistentContainer.viewContext
        let interval = Interval(context: moc)
        let set = Set(context: moc)
        interval.set = set
        XCTAssertEqual(set.intervals,  [interval])
    }

    func testSetAddToIntervals()  {
        let moc = persistentContainer.viewContext
        let interval1 = Interval(context: moc)
        let set1 = Set(context: moc)
        set1.addToIntervals(interval1)
        XCTAssertEqual(interval1.set, set1)
        
        let interval2 = Interval(context: moc)
        set1.addToIntervals(interval2)
        XCTAssertEqual(interval2.set, set1)
        XCTAssertEqual(set1.intervals, [interval1, interval2])
        
        let set2 = Set(context: moc)
        set2.addToIntervals([interval1, interval2])
        XCTAssertEqual(set2.intervals, [interval1, interval2])
    }
    
    func testSetAddToIntervalsOrder()  {
        let moc = persistentContainer.viewContext
        let interval1 = Interval(context: moc)
        let interval2 = Interval(context: moc)

        let set1 = Set(context: moc)
        set1.addToIntervals(interval1)
        XCTAssertEqual(interval1.set, set1)
        set1.addToIntervals(interval2)
        XCTAssertEqual(set1.intervalsArray, [interval1, interval2])
    }

    
    func testIntervalType()  {
        let moc = persistentContainer.viewContext
        let interval1 = Interval(context: moc)
        interval1.intervalType = .high
        interval1.type = "high"
        interval1.type = "low"
        interval1.intervalType = .low
    }
    
    func testSetDuration() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        let interval1 = Interval(context: moc)
        interval1.duration = 10
        set.addToIntervals(interval1)
        XCTAssertEqual(set.duration, 10)
        let interval2 = Interval(context: moc)
        interval2.duration = 15
        set.addToIntervals(interval2)
        XCTAssertEqual(set.duration, 25)
    }
    
    func testRemaining() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        let interval1 = Interval(context: moc)
        interval1.duration = 10
        XCTAssertEqual(set.elapsed, 0)
        set.addToIntervals(interval1)
        XCTAssertEqual(set.remaining, 10)
        set.elapsed = 8
        XCTAssertEqual(set.remaining, 2)
    }
    
    func testStopTimes() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        XCTAssertEqual(set.stopTimes, [])
        let interval1 = Interval(context: moc)
        interval1.duration = 10
        set.addToIntervals(interval1)
        let interval2 = Interval(context: moc)
        set.addToIntervals(interval2)
        interval2.duration = 15
        XCTAssertEqual(set.stopTimes, [10, 25])
    }
    
    func testStartTimes() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        XCTAssertEqual(set.startTimes, [0])
        let interval1 = Interval(context: moc)
        interval1.duration = 10
        set.addToIntervals(interval1)
        XCTAssertEqual(set.startTimes, [0])
        let interval2 = Interval(context: moc)
        set.addToIntervals(interval2)
        interval2.duration = 15
        XCTAssertEqual(set.startTimes, [0, 10])
        
    }
    
    func testIntervalIndex() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        XCTAssertNil(set.intervalIndex)
        let int1 = Interval(context: moc)
        int1.duration = 10
        set.addToIntervals(int1)
        XCTAssertEqual(set.intervalIndex, 0)
        
        set.elapsed = 10
        XCTAssertEqual(set.intervalIndex, 0)
        set.addToIntervals(Interval(duration: 15, type: .high, context: moc))
        set.elapsed = 15
        XCTAssertEqual(set.intervalIndex, 1)
    }
    
    func testCurrentInterval() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        XCTAssertNil(set.currentInterval)
        let int1 = Interval(context: moc)
        int1.duration = 10
        set.addToIntervals(int1)
        XCTAssertEqual(set.currentInterval, int1)
        let int2 = Interval(context: moc)
        int2.duration = 10
        set.addToIntervals(int2)
        XCTAssertEqual(set.currentInterval!, int1)
        set.elapsed = 15
        XCTAssertEqual(set.currentInterval!, int2)
    }
    
    func testElapsedInInterval() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        XCTAssertEqual(set.elapsedInInterval, 0)
        let int1 = Interval(context: moc)
        int1.duration = 10
        set.addToIntervals(int1)
        XCTAssertEqual(set.elapsedInInterval, 0)
        let int2 = Interval(context: moc)
        int2.duration = 10
        set.addToIntervals(int2)
        XCTAssertEqual(set.elapsedInInterval, 0)
        set.elapsed = 5
        XCTAssertEqual(set.elapsedInInterval, 5)
        set.elapsed = 10
        XCTAssertEqual(set.elapsedInInterval, 0)
        set.elapsed = 11
        XCTAssertEqual(set.elapsedInInterval, 1)
        set.elapsed = 20
        XCTAssertEqual(set.elapsedInInterval, 10)
    }
    
    func testRemainingInInterval() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        XCTAssertEqual(set.remainingInInterval, 0)
        let int1 = Interval(context: moc)
        int1.duration = 10
        set.addToIntervals(int1)
        XCTAssertEqual(set.remainingInInterval, 10)
        let int2 = Interval(context: moc)
        int2.duration = 10
        set.addToIntervals(int2)
        XCTAssertEqual(set.remainingInInterval, 10)
        set.elapsed = 4
        XCTAssertEqual(set.remainingInInterval, 6)
        set.elapsed = 10
        XCTAssertEqual(set.remainingInInterval, 10)
        set.elapsed = 11
        XCTAssertEqual(set.remainingInInterval, 9)
        set.elapsed = 20
        XCTAssertEqual(set.remainingInInterval, 0)
    }
    
    func testDurationOfInterval() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        XCTAssertNil(set.durationOfInterval)
        let int1 = Interval(context: moc)
        int1.duration = 10
        set.addToIntervals(int1)
        
        XCTAssertEqual(set.durationOfInterval, 10)
        let int2 = Interval(context: moc)
        int2.duration = 12
        set.addToIntervals(int2)
        set.elapsed = 5
        XCTAssertEqual(set.durationOfInterval, 10)
        set.elapsed = 10
        XCTAssertEqual(set.durationOfInterval, 12)
        set.elapsed = 11
        XCTAssertEqual(set.durationOfInterval, 12)
    }

    
    func testActiveIntervals() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        set.addToIntervals(Interval(duration: 10, type: .cooldown, context: moc))
        let i1 = Interval(duration: 10, type: .high, context: moc)
        set.addToIntervals(i1)
        let i2 = Interval(duration: 10, type: .low, context: moc)
        set.addToIntervals(i2)
        set.addToIntervals(Interval(duration: 10, type: .prepare, context: moc))
        set.addToIntervals(Interval(duration: 10, type: .prepare, context: moc))
        let i3 = Interval(duration: 10, type: .warmup, context: moc)
        set.addToIntervals(i3)
        XCTAssertEqual(set.activeIntervals, [i1, i2, i3])
    }
    
    func testCurrentActiveInterval() {
        let moc = persistentContainer.viewContext
        let set = Set(context: moc)
        XCTAssertNil(set.currentActiveInterval)
        set.addToIntervals(Interval(duration: 10, type: .cooldown, context: moc))
        set.addToIntervals(Interval(duration: 10, type: .high, context: moc))
        set.addToIntervals(Interval(duration: 10, type: .low, context: moc))
        set.addToIntervals(Interval(duration: 10, type: .prepare, context: moc))
        set.addToIntervals(Interval(duration: 10, type: .prepare, context: moc))
        set.addToIntervals(Interval(duration: 10, type: .warmup, context: moc))
        XCTAssertEqual(set.currentActiveInterval, 0)
        set.elapsed = 12
        XCTAssertEqual(set.currentActiveInterval, 1)
        set.elapsed = 22
        XCTAssertEqual(set.currentActiveInterval, 2)
    }
    
    func testActiveDuration() {
        let moc = persistentContainer.viewContext
        let set = SetFactory.tabataSet(context: moc)
        XCTAssertEqual(set.activeDuration, 1600)
    }
    
    func testActiveElapsed() {
        let moc = persistentContainer.viewContext
        let set = SetFactory.tabataSet(context: moc)
        set.elapsed = 80
        XCTAssertEqual(set.activeElapsed, 0)
        set.elapsed = 120
        XCTAssertEqual(set.activeElapsed, 20)
        set.elapsed = 320
        XCTAssertEqual(set.activeElapsed, 200)
        set.elapsed = 440
        XCTAssertEqual(set.activeElapsed, 240)
    }
}
