import XCTest

class SetListTableViewUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launchArguments.append("IS_RUNNING_UITEST")
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBackButton() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.navigationBars["Select a Set"].buttons["Back"].tap()
        XCTAssertTrue(app.buttons["Select a Set"].exists)
    }

    func testSelectSet() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        let cell = app.tables.cells.element(boundBy: 0)
        let label = cell.label
        cell.tap()
        let button = app.buttons[label]
        XCTAssertTrue(button.exists)
    }
    
    func testAddSetSheet() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.navigationBars["Select a Set"].buttons["Add"].tap()
        XCTAssert(app.otherElements.containing(.sheet, identifier:"Add New Set").element.exists)
    }

    func testAddSetCancelSheet() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        
        let cellCountBefore = app.tables.cells.count
        app.navigationBars["Select a Set"].buttons["Add"].tap()
        app.sheets["Add New Set"].buttons["Cancel"].tap()
        let cellCountAfter = app.tables.cells.count
        XCTAssertEqual(cellCountBefore, cellCountAfter)
    }
    
    func testAddSetCancel() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        
        let cellCountBefore = app.tables.cells.count
        app.navigationBars["Select a Set"].buttons["Add"].tap()
        app.sheets["Add New Set"].buttons.element(boundBy: 0).tap()
        app.navigationBars.element.buttons["Cancel"].tap()
        let cellCountAfter = app.tables.cells.count
        XCTAssertEqual(cellCountBefore, cellCountAfter)
    }
    
    func testAddSet() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        let cellCountBefore = app.tables.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Set'")).count
        app.navigationBars["Select a Set"].buttons["Add"].tap()
        app.sheets["Add New Set"].buttons.element(boundBy: 0).tap()
        app.navigationBars.element.buttons["Save"].tap()
        let cellCountAfter = app.tables.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Set'")).count
        XCTAssertEqual(cellCountBefore + 1, cellCountAfter)
    }
    
    func testDeleteSet0() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        
        let before = app.tables.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Set'")).count
        app.tables.cells["Set0"].swipeLeft()
        XCUIApplication().tables.buttons["Delete"].tap()
        sleep(1)
        let after = app.tables.cells.matching(NSPredicate(format: "identifier BEGINSWITH 'Set'")).count
        XCTAssertEqual(after, before - 1)
    }
    
    func testEdit() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        let cell = app.tables.cells.element(boundBy: 0)
        let label = cell.label
        cell.swipeLeft()
        cell.buttons["Edit"].tap()
        XCTAssert(app.navigationBars[label].exists)
    }
    
    func testEditCancel() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        
        let cell = app.tables.cells["Set0"]
        let titleBeforeChange = cell.label
        app.tables.cells["Set0"].swipeLeft()
        app.tables.cells["Set0"].buttons["Edit"].tap()
        app.tables.textFields["TitleField"].tap()
        app.tables.textFields["TitleField"].typeText(" changed")
        app.navigationBars.buttons["Cancel"].tap()
        let titleAfterChange = cell.label
        XCTAssertEqual(titleBeforeChange, titleAfterChange)
    }
    
    func testEditSave() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        
        let cell = app.tables.cells["Set0"]
        let titleBeforeChange = cell.label
        app.tables.cells["Set0"].swipeLeft()
        app.tables.cells["Set0"].buttons["Edit"].tap()
        app.tables.textFields["TitleField"].tap()
        let text = " changed"
        app.tables.textFields["TitleField"].typeText(text)
        app.navigationBars.buttons["Save"].tap()
        let titleAfterChange = cell.label
        XCTAssertEqual(titleBeforeChange + text, titleAfterChange)
    }
    
    func testEditMode() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        let cell = app.tables.cells["Set0"]
        XCTAssertFalse(cell.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Delete'")).element.exists)
        XCTAssertTrue(cell.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Reorder'")).element.exists)
        XCTAssertTrue(cell.buttons.matching(NSPredicate(format: "label BEGINSWITH 'More Info'")).element.exists)
    }
    
    func testEditModeReorder() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        let cell1 = app.tables.cells.element(boundBy: 0)
        let cell2 = app.tables.cells.element(boundBy: 2)
        let button1 = cell1.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Reorder'")).element
        let button2 = cell2.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Reorder'")).element
        button1.press(forDuration: 0.5, thenDragTo: button2)
        sleep(1)
        XCTAssertLessThanOrEqual(cell1.frame.maxY, cell2.frame.minY)
        app.navigationBars["Select a Set"].buttons["Back"].tap()
        app.buttons["SelectSet"].tap()
        XCTAssertLessThanOrEqual(cell1.frame.maxY, cell2.frame.minY)
    }
    
    func testEditMoreInfo() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        let cell = app.tables.cells.element(boundBy: 0)
        let label = cell.label
        XCTAssertTrue(cell.buttons["More Info"].exists)
        cell.buttons["More Info"].tap()
        XCTAssertTrue(app.navigationBars[label].exists)
    }
}
