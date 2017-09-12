import XCTest

class IntervalTableViewUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTypePicker() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.cells.element(boundBy: 0).tap()
        app.tables.cells.staticTexts["Intervals"].tap()
        app.cells.element(boundBy: 0).tap()
        let tables = XCUIApplication().tables
        let cell = tables.cells["Type"]
        let label = cell.staticTexts.element.label
        cell.tap()
        let picker = app.pickerWheels.element
        XCTAssertEqual(label, String(describing: picker.value!))
    }
    
    func testDurationMovePicker() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.cells.element(boundBy: 0).tap()
        app.tables.cells.staticTexts["Intervals"].tap()
        app.cells.element(boundBy: 0).tap()
        let tables = XCUIApplication().tables
        let cell = tables.cells["Duration"]
        cell.tap()
        let secPicker = app.pickerWheels.matching(NSPredicate(format: "value endswith 'sec'")).element
        let minPicker = app.pickerWheels.matching(NSPredicate(format: "value endswith 'min'")).element
        secPicker.adjust(toPickerWheelValue: "10 sec")
        minPicker.adjust(toPickerWheelValue: "10 min")
        XCTAssertEqual(String(describing: cell.staticTexts.element.label), "10 min, 10 sec")
    }
    
    func testMoveTypePicker() {
        let app = XCUIApplication()
        app.buttons["SelectSet"].tap()
        app.toolbars.buttons["Edit"].tap()
        app.cells.element(boundBy: 0).tap()
        app.tables.cells.staticTexts["Intervals"].tap()
        app.cells.element(boundBy: 0).tap()
        let tables = XCUIApplication().tables
        let cell = tables.cells["Type"]
        cell.tap()
        let picker = app.pickerWheels.element
        picker.adjust(toPickerWheelValue: "Cooldown")
        XCTAssertEqual(cell.staticTexts.element.label, "Cooldown")
    }
    
    
}
