import XCTest

class SetTimerViewUITests: XCTestCase {
    
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSelectASetButton() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        XCTAssert(app.navigationBars["Select a Set"].exists)
        app.navigationBars["Select a Set"].buttons["Back"].tap()
    }
    
    func testLockUI() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.tables.cells["Set0"].tap()

        XCTAssert(app.buttons["Lock"].exists)
        XCTAssert(app.buttons["Lock"].isEnabled)
        
        app.buttons["Lock"].tap()
        XCTAssert(app.buttons["Unlock"].exists)
        XCTAssertTrue(app.buttons["Unlock"].isEnabled)
        XCTAssertFalse(app.buttons["Start"].isEnabled)
        XCTAssertFalse(app.buttons["Reset"].isEnabled)
        XCTAssertFalse(app.buttons["SelectSet"].isEnabled)
        
        app.buttons["Unlock"].tap()
        XCTAssert(app.buttons["Lock"].exists)
        XCTAssert(app.buttons["Lock"].isEnabled)
        XCTAssert(app.buttons["Start"].isEnabled)
        XCTAssertFalse(app.buttons["Reset"].isEnabled)
        XCTAssert(app.buttons["SelectSet"].isEnabled)
    }
    
    func testStartPause() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.tables.cells["Set0"].tap()
        XCTAssert(app.buttons["Start"].isEnabled)
        XCTAssertFalse(app.buttons["Reset"].isEnabled)
        
        app.buttons["Start"].tap()
        XCTAssert(app.buttons["Pause"].exists)
        XCTAssert(app.buttons["Pause"].isEnabled)
        XCTAssertFalse(app.buttons["Reset"].isEnabled)
        
        app.buttons["Pause"].tap()
        XCTAssertFalse(app.buttons["Pause"].exists)
        XCTAssert(app.buttons["Continue"].exists)
        XCTAssert(app.buttons["Continue"].isEnabled)
        XCTAssert(app.buttons["Reset"].isEnabled)
        
        app.buttons["Reset"].tap()
        XCTAssertFalse(app.buttons["Reset"].isEnabled)
        XCTAssert(app.buttons["Start"].isEnabled)
    }
    
    func waitFor(element:XCUIElement, seconds waitSeconds:Double) {
        let exists = NSPredicate(format: "exists == 1")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: waitSeconds, handler: nil)
    }
    
    func testStartFinish() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.tables.cells["Short Set"].tap()
        app.buttons["Start"].tap()
        waitFor(element: app.buttons["Start"], seconds: 10)
    }
    
    func testStartPauseStart() {
        
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.tables.cells["Set0"].tap()
        app.buttons["Start"].tap()
        
        app.buttons["Pause"].tap()
        app.buttons["Continue"].tap()
    }
    
}
