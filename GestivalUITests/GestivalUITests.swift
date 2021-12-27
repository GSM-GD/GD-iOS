//
//  GestivalUITests.swift
//  GestivalUITests
//
//  Created by 최형우 on 2021/12/16.
//

import XCTest
@testable import Gestival

class GestivalUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        app.textFields["Your Email"].tap()
        app.typeText("email")
        
        app.textFields["Password"].tap()
        app.typeText("password")
        app/*@START_MENU_TOKEN@*/.buttons["로그인"].staticTexts["로그인"]/*[[".buttons[\"로그인\"].staticTexts[\"로그인\"]",".staticTexts[\"로그인\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.tap()
        
                
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
