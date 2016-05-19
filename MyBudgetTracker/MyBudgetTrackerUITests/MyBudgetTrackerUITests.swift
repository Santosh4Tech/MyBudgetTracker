//
//  MyBudgetTrackerUITests.swift
//  MyBudgetTrackerUITests
//
//  Created by Santosh Kumar Sahoo on 3/25/16.
//  Copyright © 2016 Robosoft Technologies. All rights reserved.
//

import XCTest

class MyBudgetTrackerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        
        let app = XCUIApplication()
        let collectionViewsQuery = app.collectionViews
        let cellsQuery = collectionViewsQuery.cells
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Domestic").element.tap()
        collectionViewsQuery.staticTexts["Education"].tap()
        collectionViewsQuery.staticTexts["Domestic"].tap()
        cellsQuery.otherElements.containingType(.StaticText, identifier:"Banking").element.tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["loan"].tap()
        tablesQuery.buttons["More"].tap()
        tablesQuery.staticTexts["mca12.santosh@gmail.commca12.santosh@gmail.commcaRent for March.So, everything seems to be working great. From the change dictionary you can extract any value you want (if needed), but the most important of all is that it’s super-easy to be notified about changes in properties. If all these look new to you, don’t worry. It’s all just a matter of habit!"].tap()
        tablesQuery.buttons["Less"].tap()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
