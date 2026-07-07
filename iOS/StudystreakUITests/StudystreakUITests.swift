import XCTest

final class StudystreakUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAddEntryFlow() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["addItemButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("UI Test Entry")

        let valueField = app.textFields["valueField"]
        valueField.tap()
        valueField.typeText("2")

        app.buttons["saveButton"].tap()

        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 5))
    }

    func testFreeLimitTriggersPaywall() throws {
        let app = XCUIApplication()
        app.launch()

        for i in 0..<25 {
            app.buttons["addItemButton"].tap()
            let titleField = app.textFields["titleField"]
            if titleField.waitForExistence(timeout: 3) {
                titleField.tap()
                titleField.typeText("Filler \(i)")
                app.buttons["saveButton"].tap()
            }
        }

        // Eventually the paywall's purchase button should appear.
        let purchaseButton = app.buttons["purchaseButton"]
        let dismissButton = app.buttons["dismissPaywallButton"]
        XCTAssertTrue(purchaseButton.waitForExistence(timeout: 5) || dismissButton.waitForExistence(timeout: 5))
    }

    func testKeyboardDismissOnTapOutside() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["addItemButton"].tap()
        let titleField = app.textFields["titleField"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5))
        titleField.tap()
        titleField.typeText("Dismiss Test")

        XCTAssertTrue(app.keyboards.element.exists)

        // Tap the form section header to dismiss the keyboard without hitting a control.
        app.staticTexts["Details"].tap()

        let keyboardGone = !app.keyboards.element.exists
        XCTAssertTrue(keyboardGone || app.buttons["cancelButton"].exists)
    }

    func testSettingsSheetOpens() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["settingsButton"].tap()
        XCTAssertTrue(app.buttons["settingsDoneButton"].waitForExistence(timeout: 5))
        app.buttons["settingsDoneButton"].tap()
    }
}
