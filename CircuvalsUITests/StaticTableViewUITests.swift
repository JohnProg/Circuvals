import XCTest

class StaticTableViewUITests: XCTestCase {
    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTransitionToIntervals() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()

        app.tables.cells.element(boundBy: 1).tap()
        XCTAssertTrue(app.navigationBars.matching(identifier: "Intervals").firstMatch.exists)
    }
    
    func testEditTitleSave() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()
        
        let field = app.tables.textFields["TitleField"]
        field.tap()
        let textBeforeChange = field.value as! String
        let text = " change"
        field.typeText(text)
        app.navigationBars.buttons["Save"].tap()
        app.tables.cells["Set0"].tap()
        XCTAssertEqual(textBeforeChange + text, app.tables.textFields["TitleField"].value as! String)
    }
    
    func testEditFeedbackSwitch() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()
        let id = "feedbackSwitch"
        let fswitch = app.switches[id]
        let before = fswitch.value as! String
        fswitch.tap()
        let after = fswitch.value as! String
        XCTAssertNotEqual(before, after)
        app.navigationBars.buttons["Save"].tap()
        app.tables.cells["Set0"].tap()
        XCTAssertEqual(after, app.switches[id].value as! String)
    }
    
    func testEditCountdownSwitch() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()
        let id = "countdownSwitch"
        let fswitch = app.switches[id]
        let before = fswitch.value as! String
        fswitch.tap()
        let after = fswitch.value as! String
        XCTAssertNotEqual(before, after)
        app.navigationBars.buttons["Save"].tap()
        app.tables.cells["Set0"].tap()
        XCTAssertEqual(after, app.switches[id].value as! String)
    }

    func testEditHalftimeSwitch() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()
        let id = "halftimeSwitch"
        let fswitch = app.switches[id]
        let before = fswitch.value as! String
        fswitch.tap()
        let after = fswitch.value as! String
        XCTAssertNotEqual(before, after)
        app.navigationBars.buttons["Save"].tap()
        app.tables.cells["Set0"].tap()
        XCTAssertEqual(after, app.switches[id].value as! String)
    }
    
    func testEditIntervalSwitch() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()
        let id = "intervalSwitch"
        let fswitch = app.switches[id]
        let before = fswitch.value as! String
        fswitch.tap()
        let after = fswitch.value as! String
        XCTAssertNotEqual(before, after)
        app.navigationBars.buttons["Save"].tap()
        app.tables.cells["Set0"].tap()
        XCTAssertEqual(after, app.switches[id].value as! String)
    }

}
