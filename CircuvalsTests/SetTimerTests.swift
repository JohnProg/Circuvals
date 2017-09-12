import XCTest
import CoreData
@testable import Circuvals

class FakeTimerIntervalDelegate: SetTimerDelegate {
    var timerDidStartCalled = false
    func timerDidStart() {
        timerDidStartCalled = true
    }
    var timerDidPauseCalled = false
    func timerDidPause() {
        timerDidPauseCalled = true
    }
    var timerDidContinueCalled = false
    func timerDidContinue() {
        timerDidContinueCalled = true
    }
    var timerDidResetCalled = false
    func timerDidReset() {
        timerDidResetCalled = true
    }
    var timerDidUpdateTimeCalled = false
    func timerDidUpdateTime() {
        timerDidUpdateTimeCalled = true
    }
    var timerDidFinishIntervalCalled = false
    func timerDidFinishInterval() {
        timerDidFinishIntervalCalled = true
    }
    var timerDidStartIntervalCalled = false
    func timerDidStartInterval() {
        timerDidStartIntervalCalled = true
        
    }
    var timerDidUpdateStateCalled = false
    func timerDidUpdateState() {
        timerDidUpdateStateCalled = true
    }
    var timerDidFinishCalled = false
    func timerDidFinish() {
        timerDidFinishCalled = true
    }
    var timerDidChangeSetCalled = false
    func timerDidChangeSet() {
        timerDidChangeSetCalled = true
    }
    var timerDidFinish1stHalfCalled = false
    func timerDidFinish1stHalf() {
        timerDidFinish1stHalfCalled = true
    }
}

class SetTimerTests: XCTestCase {

    var setTimer: SetTimer!
    var set: Circuvals.Set!
    var timerDelegate: FakeTimerIntervalDelegate!
    
    let persistentContainer = TestHelper.persistentContainer
    
    override func setUp() {
        setTimer = SetTimer()
        self.set = Set(context: persistentContainer.viewContext)
        setTimer.set = self.set
        self.timerDelegate = FakeTimerIntervalDelegate()
        setTimer.delegate = self.timerDelegate
        let int1 = Interval(duration: 20, context: persistentContainer.viewContext)
        let int2 = Interval(duration: 20, context: persistentContainer.viewContext)
        set.addToIntervals(int1)
        set.addToIntervals(int2)
    }
    
    func testInit() {
        XCTAssertNotNil(SetTimer())
        let timer = SetTimer()
        XCTAssertEqual(timer.state, .empty)
        timer.set = Set(context: persistentContainer.viewContext)
        XCTAssertEqual(timer.state, .empty)
        timer.set = nil
        XCTAssertEqual(timer.state, .empty)
    }
    
    func testStart() {
        let timer = SetTimer()
        timer.start()
        XCTAssertEqual(timer.state, SetTimerState.empty)
        
        var delegate = FakeTimerIntervalDelegate()
        timer.delegate = delegate
        timer.state = SetTimerState.paused
        timer.start()
        XCTAssertEqual(timer.state, SetTimerState.started)
        XCTAssertTrue(delegate.timerDidContinueCalled)
        
        timer.state = SetTimerState.started
        timer.start()
        XCTAssertEqual(timer.state, SetTimerState.started)
        
        timer.state = SetTimerState.finished
        timer.start()
        XCTAssertEqual(timer.state, SetTimerState.finished)
        
        delegate = FakeTimerIntervalDelegate()
        timer.delegate = delegate
        timer.state = SetTimerState.reseted
        timer.start()
        XCTAssertEqual(timer.state, SetTimerState.started)
        XCTAssertTrue(delegate.timerDidStartCalled)
    }
    
    func testPause() {
        let timer = SetTimer()
        timer.pause()
        XCTAssertEqual(timer.state, SetTimerState.empty)
        
        timer.state = SetTimerState.paused
        timer.pause()
        XCTAssertEqual(timer.state, SetTimerState.paused)

        timer.state = SetTimerState.started
        timer.pause()
        XCTAssertEqual(timer.state, SetTimerState.paused)
        
        timer.state = SetTimerState.finished
        timer.pause()
        XCTAssertEqual(timer.state, SetTimerState.finished)
    }
    
    func testReset() {
        let timer = SetTimer()
        timer.reset()
        XCTAssertEqual(timer.state, SetTimerState.empty)
        
        timer.state = SetTimerState.paused
        timer.reset()
        XCTAssertEqual(timer.state, SetTimerState.reseted)
        
        timer.state = SetTimerState.started
        timer.reset()
        XCTAssertEqual(timer.state, SetTimerState.started)
        
        timer.state = SetTimerState.finished
        timer.reset()
        XCTAssertEqual(timer.state, SetTimerState.reseted)
    }
    
    func testToggle() {
        let timer = SetTimer()
        timer.toggle()
        XCTAssertEqual(timer.state, SetTimerState.empty)
    
        timer.state = .paused
        timer.toggle()
        XCTAssertEqual(timer.state, SetTimerState.started)
        
        timer.state = .started
        timer.toggle()
        XCTAssertEqual(timer.state, SetTimerState.paused)
        
        timer.state = .finished
        timer.toggle()
        XCTAssertEqual(timer.state, SetTimerState.finished)
    }
    
    func testTick() {
        let timer = SetTimer()
        let set = Set(context: persistentContainer.viewContext)
        timer.set = set
        XCTAssertEqual(set.elapsed, 0)
        XCTAssertEqual(set.duration, 0)
        XCTAssertNil(set.intervalIndex)
        timer.tick()
        XCTAssertEqual(set.elapsed, 0)
        
        let int1 = Interval(duration: 2, context: persistentContainer.viewContext)
        set.addToIntervals(int1)
        XCTAssertEqual(set.elapsed, 0)
        XCTAssertEqual(set.duration, 2)
        timer.tick()
        XCTAssertEqual(set.elapsed, 1)
        timer.tick()
        XCTAssertEqual(set.elapsed, 2)
        XCTAssertTrue(set.isFinished, "set should be finished")
        timer.tick()
        XCTAssertEqual(set.elapsed, 2)
    }
    
    func testTickTimerDidUpdateTime() {
        XCTAssertNotNil(timerDelegate)
        XCTAssertFalse(timerDelegate.timerDidUpdateTimeCalled)
        setTimer.tick()
        XCTAssertTrue(timerDelegate.timerDidUpdateTimeCalled)
        setTimer.set?.elapsed = 9
        setTimer.tick()
        XCTAssertTrue(timerDelegate.timerDidUpdateTimeCalled)
        setTimer.set?.elapsed = 20
        timerDelegate.timerDidStartIntervalCalled = false
        setTimer.tick()
        XCTAssertTrue(timerDelegate.timerDidFinishIntervalCalled)
        XCTAssertTrue(timerDelegate.timerDidStartIntervalCalled)

    }
    
    func testTickIntervalStartEnd() {
        setTimer.set?.elapsed = 20
        XCTAssertFalse(timerDelegate.timerDidStartIntervalCalled)
        setTimer.tick()
        XCTAssertTrue(timerDelegate.timerDidStartIntervalCalled)
        XCTAssertTrue(timerDelegate.timerDidFinishIntervalCalled)
    }
    
    func testTickHalfTime() {
        setTimer.set?.elapsed = 9
        setTimer.tick()
        XCTAssertFalse(timerDelegate.timerDidFinish1stHalfCalled)
        setTimer.tick()
        XCTAssertTrue(timerDelegate.timerDidFinish1stHalfCalled)
    }

    func testTickFinish() {
        setTimer.set?.elapsed = 39
        setTimer.tick()
        XCTAssertFalse(timerDelegate.timerDidFinishCalled)
        setTimer.tick()
        XCTAssertTrue(timerDelegate.timerDidFinishCalled)
    }
    
    func testEnterBackground() {
        setTimer.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                              selector: #selector(self.fake), userInfo: nil, repeats: true)
        setTimer.enterBackground()
        XCTAssertNotNil(setTimer.timer)
        XCTAssertFalse(setTimer.timer!.isValid)
        XCTAssertNotNil(setTimer.timeEnteredBackground)
    }
    
    func fake() {
    }
    
    func testEnterForeground() {
        setTimer.timeEnteredBackground = Date()
        setTimer.enterForground()
        XCTAssertNil(setTimer.timeEnteredBackground)
        XCTAssertNotNil(setTimer.timer)
        XCTAssert(setTimer.timer!.isValid)
    }
}
