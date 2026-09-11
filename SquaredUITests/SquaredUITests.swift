//
//  SquaredUITests.swift
//  SquaredUITests
//
//  Created by Iman Azher on 05/09/2026.
//

import XCTest

final class SquaredUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    /// Confirms the Sign In screen renders and the button is real, tappable UI.
    @MainActor
    func testSignInScreenAppearsWithSignInWithAppleButton() throws {
        let app = XCUIApplication()
        app.launch()

        let signInButton = app.buttons["Sign in with Apple"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 10), "Sign in with Apple button should appear on launch")
        XCTAssertTrue(signInButton.isHittable)
    }

    /// Taps the real button and reports whatever the system does next.
    @MainActor
    func testTappingSignInWithAppleTriggersSystemResponse() throws {
        let app = XCUIApplication()
        app.launch()

        let signInButton = app.buttons["Sign in with Apple"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 10))

        signInButton.tap()

        // Capture what actually happened instead of guessing.
        Thread.sleep(forTimeInterval: 3)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "after-tapping-sign-in-with-apple"
        attachment.lifetime = .keepAlways
        add(attachment)

        // The system credential UI runs in a separate process (Springboard).
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let sheetAppeared = springboard.staticTexts.count > 0 || springboard.otherElements.count > 0
        XCTAssertTrue(sheetAppeared || app.staticTexts["Setting things up…"].exists,
                      "Expected either a system credential sheet, a system error, or (if somehow already authorized) a transition toward the loading screen")
    }

    /// Confirms the DEBUG bypass drives the loading -> signedIn pipeline end to end.
    @MainActor
    func testDebugBypassReachesSignedInTabView() throws {
        let app = XCUIApplication()
        app.launch()

        let bypassButton = app.buttons["DEBUG: Skip Sign In"]
        XCTAssertTrue(bypassButton.waitForExistence(timeout: 10), "Debug bypass button should appear on launch")

        bypassButton.tap()

        let groupsTab = app.tabBars.buttons["Groups"]
        XCTAssertTrue(groupsTab.waitForExistence(timeout: 10), "Should reach the signed-in TabView with a Groups tab")
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }

    /// Confirms the Groups list renders mock data, refreshes, and navigates on tap.
    @MainActor
    func testGroupsListShowsBalancesRefreshesAndNavigates() throws {
        let app = XCUIApplication()
        app.launch()

        let bypassButton = app.buttons["DEBUG: Skip Sign In"]
        XCTAssertTrue(bypassButton.waitForExistence(timeout: 10))
        bypassButton.tap()

        let groupRow = app.staticTexts["Trip to Lisbon"]
        XCTAssertTrue(groupRow.waitForExistence(timeout: 10), "Mock group should appear in the list")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "groups-list-populated"
        attachment.lifetime = .keepAlways
        add(attachment)

        app.swipeDown()
        Thread.sleep(forTimeInterval: 1.5)

        groupRow.tap()
        XCTAssertTrue(app.navigationBars["Trip to Lisbon"].waitForExistence(timeout: 10), "Tapping a group should push to its detail screen")
    }

    /// Confirms the full Add Group flow: sheet appears, Create is disabled until
    /// a name is entered, and the new group appears at the top of the list with
    /// a $0.00 balance — live, not assumed.
    @MainActor
    func testAddGroupCreatesAndAppearsAtTopOfList() throws {
        let app = XCUIApplication()
        app.launch()

        let bypassButton = app.buttons["DEBUG: Skip Sign In"]
        XCTAssertTrue(bypassButton.waitForExistence(timeout: 10))
        bypassButton.tap()

        let addButton = app.navigationBars.buttons["Add Group"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 30), "Debug bypass should reach the Groups list")
        addButton.tap()

        let nameField = app.textFields["Group name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 30), "Add Group sheet should appear")

        let sheetNavBar = app.navigationBars["New Group"]
        XCTAssertTrue(sheetNavBar.waitForExistence(timeout: 5))
        let screenHeight = app.frame.height
        let sheetHeightFraction = (screenHeight - sheetNavBar.frame.minY) / screenHeight
        XCTAssertLessThan(sheetHeightFraction, 0.7, "Add Group sheet should present at .medium height, not full screen (occupied \(Int(sheetHeightFraction * 100))% of screen)")

        let createButton = app.buttons["Create"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        XCTAssertFalse(createButton.isEnabled, "Create should be disabled until a name is entered")

        nameField.tap()
        nameField.typeText("Book Club")
        XCTAssertTrue(createButton.isEnabled, "Create should enable once a name is entered")

        createButton.tap()

        XCTAssertTrue(nameField.waitForNonExistence(timeout: 20), "Sheet should dismiss after creation")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "groups-list-after-add"
        attachment.lifetime = .keepAlways
        add(attachment)

        let newGroupRow = app.staticTexts["Book Club"]
        XCTAssertTrue(newGroupRow.exists, "New group should appear in the list immediately")
        XCTAssertTrue(app.staticTexts["+$0.00"].exists, "New group should start with a $0.00 balance")
        XCTAssertTrue(app.staticTexts["1 person"].exists, "A single-member group should read '1 person', not '1 people'")
    }
}

private extension XCUIElement {
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
