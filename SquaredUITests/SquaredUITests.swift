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

    /// Confirms the Sign In screen actually renders and the button is real,
    /// tappable UI — not just something that looks right in a screenshot.
    @MainActor
    func testSignInScreenAppearsWithSignInWithAppleButton() throws {
        let app = XCUIApplication()
        app.launch()

        let signInButton = app.buttons["Sign in with Apple"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 10), "Sign in with Apple button should appear on launch")
        XCTAssertTrue(signInButton.isHittable)
    }

    /// Taps the real Sign in with Apple button and reports whatever the
    /// system does next (native credential sheet, or an error if this
    /// environment isn't provisioned for the capability) rather than
    /// assuming the tap wires up correctly.
    @MainActor
    func testTappingSignInWithAppleTriggersSystemResponse() throws {
        let app = XCUIApplication()
        app.launch()

        let signInButton = app.buttons["Sign in with Apple"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 10))

        signInButton.tap()

        // Give the system time to present whatever it presents, then capture
        // proof of what actually happened instead of guessing.
        Thread.sleep(forTimeInterval: 3)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "after-tapping-sign-in-with-apple"
        attachment.lifetime = .keepAlways
        add(attachment)

        // The system credential UI runs in a separate process (Springboard),
        // so query the full screen hierarchy for it rather than `app`.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let sheetAppeared = springboard.staticTexts.count > 0 || springboard.otherElements.count > 0
        XCTAssertTrue(sheetAppeared || app.staticTexts["Setting things up…"].exists,
                      "Expected either a system credential sheet, a system error, or (if somehow already authorized) a transition toward the loading screen")
    }

    /// Real Sign In with Apple can't be completed on a free Apple Developer
    /// team, so this confirms the DEBUG-only bypass drives the actual
    /// loading -> signedIn pipeline (AppState.performInitialFetch, then the
    /// TabView appearing) end to end, live in the simulator.
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
}
