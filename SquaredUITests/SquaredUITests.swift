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
        XCTAssertTrue(groupsTab.waitForExistence(timeout: 30), "Should reach the signed-in TabView with a Groups tab")
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
        XCTAssertTrue(groupRow.waitForExistence(timeout: 30), "Mock group should appear in the list")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "groups-list-populated"
        attachment.lifetime = .keepAlways
        add(attachment)

        app.swipeDown()
        Thread.sleep(forTimeInterval: 1.5)

        groupRow.tap()
        XCTAssertTrue(app.navigationBars["Trip to Lisbon"].waitForExistence(timeout: 30), "Tapping a group should push to its detail screen")
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

    /// Confirms Group Detail shows members/balances and the expense feed from mock
    /// data, newest first, and that both navigation actions (View Settlement push,
    /// + sheet) and the back button work.
    @MainActor
    func testGroupDetailShowsMembersExpensesAndNavigatesCorrectly() throws {
        let app = XCUIApplication()
        app.launch()

        let bypassButton = app.buttons["DEBUG: Skip Sign In"]
        XCTAssertTrue(bypassButton.waitForExistence(timeout: 10))
        bypassButton.tap()

        let groupRow = app.staticTexts["Trip to Lisbon"]
        XCTAssertTrue(groupRow.waitForExistence(timeout: 30))
        groupRow.tap()

        XCTAssertTrue(app.navigationBars["Trip to Lisbon"].waitForExistence(timeout: 30), "Group name should be the navigation title")

        // Members section: compact summary row, not the full inline list.
        XCTAssertTrue(app.staticTexts["5 Members"].waitForExistence(timeout: 10), "Members row should show a compact count summary")
        XCTAssertFalse(app.staticTexts["Sam Rivera"].exists, "Member names should no longer appear inline on Group Detail")

        // Expense feed: newest first (Groceries -2d, Taxi -5d, Dinner -7d, Hotel -9d),
        // each showing description/amount/payer.
        let expenseTitles = ["Groceries", "Taxi", "Dinner", "Hotel"]
        for title in expenseTitles {
            XCTAssertTrue(app.staticTexts[title].exists, "\(title) expense should appear in the feed")
        }
        let feedOrder = expenseTitles.map { app.staticTexts[$0].frame.minY }
        XCTAssertEqual(feedOrder, feedOrder.sorted(), "Expenses should be ordered newest first")
        XCTAssertTrue(app.staticTexts["Paid by Sam Rivera"].exists)
        XCTAssertTrue(app.staticTexts["$60.00"].exists, "Groceries amount should be shown")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "group-detail-populated"
        attachment.lifetime = .keepAlways
        add(attachment)

        // + presents Add Expense as a sheet.
        let addExpenseButton = app.navigationBars.buttons["Add Expense"]
        XCTAssertTrue(addExpenseButton.waitForExistence(timeout: 30))
        addExpenseButton.tap()
        let titleField = app.textFields["Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 30), "Add Expense sheet should appear")
        app.buttons["Cancel"].tap()
        XCTAssertTrue(titleField.waitForNonExistence(timeout: 20), "Sheet should dismiss on Cancel")

        // View Settlement pushes to the Settlement screen.
        let viewSettlementButton = app.buttons["View Settlement"]
        XCTAssertTrue(viewSettlementButton.waitForExistence(timeout: 30))
        viewSettlementButton.tap()
        XCTAssertTrue(app.navigationBars["Balances"].waitForExistence(timeout: 30), "View Settlement should push to the Settlement screen")

        // Back returns to Group Detail, then Groups list.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Trip to Lisbon"].waitForExistence(timeout: 30), "Back should return to Group Detail")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Groups"].waitForExistence(timeout: 30), "Back should return to the Groups list")
    }

    /// Confirms tapping an expense in Group Detail's feed pushes to ExpenseDetailView
    /// with the correct payer, split method, and per-participant breakdown, and that
    /// back returns to Group Detail.
    @MainActor
    func testExpenseRowPushesToDetailWithCorrectBreakdown() throws {
        let app = XCUIApplication()
        app.launch()

        let bypassButton = app.buttons["DEBUG: Skip Sign In"]
        XCTAssertTrue(bypassButton.waitForExistence(timeout: 10))
        bypassButton.tap()

        let groupRow = app.staticTexts["Trip to Lisbon"]
        XCTAssertTrue(groupRow.waitForExistence(timeout: 30))
        groupRow.tap()
        XCTAssertTrue(app.navigationBars["Trip to Lisbon"].waitForExistence(timeout: 30))

        // "Taxi" is a percentage-split expense (50% / 30% / 20% of $45), paid by Jordan Lee.
        let taxiRow = app.staticTexts["Taxi"]
        XCTAssertTrue(taxiRow.waitForExistence(timeout: 30))
        taxiRow.tap()

        XCTAssertTrue(app.navigationBars["Taxi"].waitForExistence(timeout: 30), "Tapping an expense should push to its detail screen")
        XCTAssertTrue(app.staticTexts["$45.00"].exists, "Total amount should be shown")
        XCTAssertTrue(app.staticTexts["Jordan Lee"].exists, "Payer should be shown")
        XCTAssertTrue(app.staticTexts["Percentage"].exists, "Split method should be shown")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "expense-detail-taxi"
        attachment.lifetime = .keepAlways
        add(attachment)

        XCTAssertTrue(app.staticTexts["You"].exists, "Current user's share should be shown")
        XCTAssertTrue(app.staticTexts["$22.50"].exists)
        XCTAssertTrue(app.staticTexts["Sam Rivera"].exists)
        XCTAssertTrue(app.staticTexts["$13.50"].exists)
        XCTAssertTrue(app.staticTexts["$9.00"].exists)

        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Trip to Lisbon"].waitForExistence(timeout: 30), "Back should return to Group Detail")
    }

    /// Confirms the Members summary row pushes to the full member list, adding a
    /// member there updates it immediately, and back navigation + Group Detail's
    /// own + (Add Expense) are unaffected by the change.
    @MainActor
    func testGroupMembersSummaryPushesAndAddMemberUpdatesImmediately() throws {
        let app = XCUIApplication()
        app.launch()

        let bypassButton = app.buttons["DEBUG: Skip Sign In"]
        XCTAssertTrue(bypassButton.waitForExistence(timeout: 10))
        bypassButton.tap()

        let groupRow = app.staticTexts["Trip to Lisbon"]
        XCTAssertTrue(groupRow.waitForExistence(timeout: 30))
        groupRow.tap()
        XCTAssertTrue(app.navigationBars["Trip to Lisbon"].waitForExistence(timeout: 30))

        let membersSummary = app.staticTexts["5 Members"]
        XCTAssertTrue(membersSummary.waitForExistence(timeout: 30))
        membersSummary.tap()

        XCTAssertTrue(app.navigationBars["Members"].waitForExistence(timeout: 30), "Tapping the summary row should push to GroupMembersView")
        XCTAssertTrue(app.staticTexts["You"].waitForExistence(timeout: 10), "Full member list should show the current user as 'You'")
        XCTAssertTrue(app.staticTexts["Sam Rivera"].exists)
        XCTAssertTrue(app.staticTexts["Jordan Lee"].exists)

        // + presents Add Member as a sheet.
        let addMemberButton = app.navigationBars.buttons["Add Member"]
        XCTAssertTrue(addMemberButton.waitForExistence(timeout: 10))
        addMemberButton.tap()

        let nameField = app.textFields["Member name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 30), "Add Member sheet should appear")
        let addButton = app.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        XCTAssertFalse(addButton.isEnabled, "Add should be disabled until a name is entered")

        nameField.tap()
        nameField.typeText("Taylor Kim")
        XCTAssertTrue(addButton.isEnabled)
        addButton.tap()

        XCTAssertTrue(nameField.waitForNonExistence(timeout: 20), "Sheet should dismiss after adding")
        XCTAssertTrue(app.staticTexts["Taylor Kim"].waitForExistence(timeout: 10), "New member should appear in the list immediately")

        // Back returns to Group Detail; its own + still opens Add Expense, unaffected.
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.navigationBars["Trip to Lisbon"].waitForExistence(timeout: 30), "Back should return to Group Detail")
        XCTAssertTrue(app.staticTexts["6 Members"].waitForExistence(timeout: 10), "Group Detail's summary should reflect the new member count")

        let addExpenseButton = app.navigationBars.buttons["Add Expense"]
        XCTAssertTrue(addExpenseButton.waitForExistence(timeout: 10))
        addExpenseButton.tap()
        XCTAssertTrue(app.textFields["Title"].waitForExistence(timeout: 30), "Group Detail's + should still open Add Expense, unaffected by this change")
    }

    /// Confirms the Settlement graph screen: the raw/simplified toggle exists and
    /// doesn't crash when switched, and tapping the graph's single edge (Apartment —
    /// SF has exactly one: You owe Sam Rivera $45 from the Wifi Bill) presents Record
    /// Payment with the correct from/to.
    @MainActor
    func testSettlementGraphTogglesAndTappingEdgeOpensRecordPayment() throws {
        let app = XCUIApplication()
        app.launch()

        let bypassButton = app.buttons["DEBUG: Skip Sign In"]
        XCTAssertTrue(bypassButton.waitForExistence(timeout: 10))
        bypassButton.tap()

        let groupRow = app.staticTexts["Apartment — SF"]
        XCTAssertTrue(groupRow.waitForExistence(timeout: 30))
        groupRow.tap()
        XCTAssertTrue(app.navigationBars["Apartment — SF"].waitForExistence(timeout: 30))

        let viewSettlementButton = app.buttons["View Settlement"]
        XCTAssertTrue(viewSettlementButton.waitForExistence(timeout: 30))
        viewSettlementButton.tap()
        XCTAssertTrue(app.navigationBars["Balances"].waitForExistence(timeout: 30))

        let simplifiedButton = app.buttons["Simplified"]
        XCTAssertTrue(simplifiedButton.waitForExistence(timeout: 10))
        simplifiedButton.tap()
        let rawButton = app.buttons["Who Owes What"]
        XCTAssertTrue(rawButton.waitForExistence(timeout: 10))
        rawButton.tap()

        let graph = app.otherElements["SettlementGraph"]
        XCTAssertTrue(graph.waitForExistence(timeout: 10))
        // Two members are laid out directly above/below center, so this edge is a
        // diametric chord: SettlementGraphView's controlPoint(from:to:center:radii:)
        // bows it purely leftward by ((radiusX + radiusY) / 2) * 0.55, and the curve's
        // actual midpoint (t=0.5 on the quad bezier) lands at half that distance left
        // of center — derive that from the graph's real on-screen size (mirroring
        // graphRadii's own margins) rather than guessing a fixed fraction.
        let graphFrame = graph.frame
        let radiusX = graphFrame.width / 2 - 55
        let radiusY = graphFrame.height / 2 - 45
        let controlDistance = ((radiusX + radiusY) / 2) * 0.55
        let curveXFraction = 0.5 - (0.5 * controlDistance) / graphFrame.width
        graph.coordinate(withNormalizedOffset: CGVector(dx: curveXFraction, dy: 0.5)).tap()

        XCTAssertTrue(app.navigationBars["Record Payment"].waitForExistence(timeout: 10), "Tapping the edge should present Record Payment")
        XCTAssertTrue(app.staticTexts["You"].exists, "From should be the current user")
        XCTAssertTrue(app.staticTexts["Sam Rivera"].exists, "To should be Sam Rivera")
        let amountField = app.textFields.matching(NSPredicate(format: "value CONTAINS[c] '45'")).firstMatch
        XCTAssertTrue(amountField.exists, "Amount should be pre-filled with the edge's $45")

        app.buttons["Cancel"].tap()
        XCTAssertTrue(app.navigationBars["Record Payment"].waitForNonExistence(timeout: 10))
        XCTAssertTrue(app.navigationBars["Balances"].waitForExistence(timeout: 10), "Cancel should return to the Settlement screen")
    }
}

private extension XCUIElement {
    func waitForNonExistence(timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: timeout) == .completed
    }
}
