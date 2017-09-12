import XCTest

class IntervalListTableViewUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testAddInterval() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()
        app.tables.cells.staticTexts["Intervals"].tap()
        let countBeforeAdd = app.tables.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Interval'")).count
        app.navigationBars["Intervals"].buttons["Add"].tap()
        let countAfterAdd = app.tables.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Interval'")).count
        XCTAssertEqual(countAfterAdd, (countBeforeAdd + 1))
    }

    func testDeleteInterval() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()
        app.tables.cells.staticTexts["Intervals"].tap()
                let countBeforeDelete = app.tables.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Interval'")).count
        
        app.cells.element(boundBy: 0).swipeLeft()
        app.cells.element(boundBy: 0).buttons["Delete"].tap()
        let countAfterDelete = app.tables.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Interval'")).count
        XCTAssertEqual(countAfterDelete, countBeforeDelete - 1)
    }
    
    func testReorderView() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()
        app.tables.cells.staticTexts["Intervals"].tap()
        XCUIApplication().toolbars.buttons["Edit"].tap()
        let label = app.tables.cells.element(boundBy: 0).label
        app.cells["Interval0"].swipeDown()
        XCTAssertEqual(label, app.tables.cells.element(boundBy: 1).label)
    }
    
    func testTranistionToIntervalView() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.tables.cells["Set0"].tap()
        app.tables.cells.staticTexts["Intervals"].tap()
        let cell = app.cells.element(boundBy: 0)
        let label = cell.label
        cell.tap()
        XCTAssertTrue(app.navigationBars.matching(identifier: label).firstMatch.exists)
    }

}
