//
//  UITests.swift
//  FoodOrderAppUITests
//
//  Created by Amir Sailaubaev on 26.05.26.
//

import XCTest

final class FoodOrderAppUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    // MARK: - Auth Screen Tests
    
    func testAuthScreenElements() {
        let loginField = app.textFields["loginTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let authButton = app.buttons["authButton"]
        
        XCTAssertTrue(loginField.exists)
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(authButton.exists)
    }
    
    func testSwitchToSignupMode() {
        let segmentControl = app.segmentedControls["authSegmentedControl"]
        segmentControl.buttons["Регистрация"].tap()
        
        // Address field should appear
        let addressField = app.textFields["addressTextField"]
        XCTAssertTrue(addressField.exists)
    }
    
    func testLoginValidationShowsError() {
        let authButton = app.buttons["authButton"]
        authButton.tap()
        
        // Should show error message
        let errorMessage = app.staticTexts.element(matching: .any, identifier: "errorMessage")
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 2))
    }
    
    func testSuccessfulRegistrationAndLogin() {
        let uniqueLogin = "testuser_\(Int(Date().timeIntervalSince1970))"
        
        // Switch to registration
        let segmentControl = app.segmentedControls["authSegmentedControl"]
        segmentControl.buttons["Регистрация"].tap()
        
        // Fill fields
        let loginField = app.textFields["loginTextField"]
        loginField.tap()
        loginField.typeText(uniqueLogin)
        
        let passwordField = app.secureTextFields["passwordTextField"]
        passwordField.tap()
        passwordField.typeText("pass1234")
        
        let addressField = app.textFields["addressTextField"]
        addressField.tap()
        addressField.typeText("ул. Тестовая, д. 1")
        
        // Submit registration
        let authButton = app.buttons["authButton"]
        authButton.tap()
        
        // Should navigate to menu
        let menuTitle = app.navigationBars["Меню"]
        XCTAssertTrue(menuTitle.waitForExistence(timeout: 3))
    }
    
    // MARK: - Menu Screen Tests
    
    func testMenuCategoriesExist() {
        // First login
        performLogin()
        
        let pizzaCategory = app.staticTexts["Пицца"]
        let burgersCategory = app.staticTexts["Бургеры"]
        let snacksCategory = app.staticTexts["Закуски"]
        let drinksCategory = app.staticTexts["Напитки"]
        
        XCTAssertTrue(pizzaCategory.exists)
        XCTAssertTrue(burgersCategory.exists)
        XCTAssertTrue(snacksCategory.exists)
        XCTAssertTrue(drinksCategory.exists)
    }
    
    func testLogoutButtonWorks() {
        performLogin()
        
        let logoutButton = app.buttons["logoutButton"]
        logoutButton.tap()
        
        // Should return to auth screen
        let loginField = app.textFields["loginTextField"]
        XCTAssertTrue(loginField.waitForExistence(timeout: 2))
    }
    
    func testCartButtonExists() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        XCTAssertTrue(cartButton.exists)
    }
    
    func testTapOnDishOpensDetail() {
        performLogin()
        
        // Tap on first dish card
        let firstDish = app.scrollViews.buttons.firstMatch
        firstDish.tap()
        
        let detailView = app.navigationBars["Детали блюда"]
        XCTAssertTrue(detailView.waitForExistence(timeout: 2))
    }
    
    // MARK: - Dish Detail Tests
    
    func testAddPizzaToCart() {
        performLogin()
        
        // Navigate to pizza detail
        let pizzaCard = app.scrollViews.buttons.element(boundBy: 0)
        pizzaCard.tap()
        
        // Add to cart
        let addButton = app.buttons["addToCartButton"]
        addButton.tap()
        
        // Should return to menu
        let menuTitle = app.navigationBars["Меню"]
        XCTAssertTrue(menuTitle.waitForExistence(timeout: 2))
    }
    
    func testPizzaOptionsExist() {
        performLogin()
        
        // Open pizza detail
        let pizzaCard = app.scrollViews.buttons.element(boundBy: 0)
        pizzaCard.tap()
        
        // Check for option pickers
        let sizePicker = app.segmentedControls.element(boundBy: 0)
        let pastryPicker = app.segmentedControls.element(boundBy: 1)
        let spicyPicker = app.segmentedControls.element(boundBy: 2)
        
        XCTAssertTrue(sizePicker.exists)
        XCTAssertTrue(pastryPicker.exists)
        XCTAssertTrue(spicyPicker.exists)
    }
    
    func testBurgerToppingsExist() {
        performLogin()
        
        // Scroll to burger section
        let scrollView = app.scrollViews.firstMatch
        scrollView.swipeUp()
        
        // Open first burger
        let burgerCard = app.buttons.element(boundBy: 4)
        burgerCard.tap()
        
        // Check for toppings checkboxes
        let cheeseCheckbox = app.buttons["cheeseCheckbox"]
        let onionCheckbox = app.buttons["onionCheckbox"]
        
        // They might exist
        XCTAssertTrue(cheeseCheckbox.exists || onionCheckbox.exists)
    }
    
    // MARK: - Cart Screen Tests
    
    func testCartScreenOpens() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let cartTitle = app.navigationBars["Корзина"]
        XCTAssertTrue(cartTitle.waitForExistence(timeout: 2))
    }
    
    func testEmptyCartShowsMessage() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let emptyMessage = app.staticTexts["Корзина пуста"]
        XCTAssertTrue(emptyMessage.waitForExistence(timeout: 2))
    }
    
    func testCartShowsAddedItems() {
        performLogin()
        addFirstDishToCart()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        // Should have at least one item
        let cartItem = app.scrollViews.buttons.firstMatch
        XCTAssertTrue(cartItem.waitForExistence(timeout: 2))
    }
    
    func testPaymentMethodSelection() {
        performLogin()
        addFirstDishToCart()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let paymentPicker = app.segmentedControls.firstMatch
        paymentPicker.buttons["Онлайн"].tap()
        paymentPicker.buttons["Наличные"].tap()
        
        XCTAssertTrue(paymentPicker.exists)
    }
    
    func testPlaceOrderButtonDisabledWhenCartEmpty() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let placeOrderButton = app.buttons["placeOrderButton"]
        XCTAssertFalse(placeOrderButton.isEnabled)
    }
    
    func testPlaceOrderButtonEnabledWhenCartHasItems() {
        performLogin()
        addFirstDishToCart()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let placeOrderButton = app.buttons["placeOrderButton"]
        XCTAssertTrue(placeOrderButton.isEnabled)
    }
    
    // MARK: - Map Screen Tests
    
    func testMapButtonOpensMap() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let selectOnMapButton = app.buttons["Выбрать на карте"]
        selectOnMapButton.tap()
        
        let mapTitle = app.navigationBars["Выбор ресторана"]
        XCTAssertTrue(mapTitle.waitForExistence(timeout: 3))
    }
    
    func testNearestRestaurantButtonExists() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let selectOnMapButton = app.buttons["Выбрать на карте"]
        selectOnMapButton.tap()
        
        let nearestButton = app.buttons["Ближайший"]
        XCTAssertTrue(nearestButton.exists)
    }
    
    // MARK: - Helper Methods
    
    func performLogin() {
        // Check if already logged in
        if app.navigationBars["Меню"].exists {
            return
        }
        
        let loginField = app.textFields["loginTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let authButton = app.buttons["authButton"]
        
        // Use a test account that exists
        loginField.tap()
        loginField.typeText("testuser_123")
        
        passwordField.tap()
        passwordField.typeText("pass1234")
        
        authButton.tap()
        
        // If login fails, create account
        if !app.navigationBars["Меню"].waitForExistence(timeout: 2) {
            let uniqueLogin = "testuser_\(Int(Date().timeIntervalSince1970))"
            let segmentControl = app.segmentedControls["authSegmentedControl"]
            segmentControl.buttons["Регистрация"].tap()
            
            loginField.tap()
            loginField.clearText()
            loginField.typeText(uniqueLogin)
            
            passwordField.tap()
            passwordField.clearText()
            passwordField.typeText("pass1234")
            
            let addressField = app.textFields["addressTextField"]
            addressField.tap()
            addressField.typeText("ул. Тестовая, 1")
            
            authButton.tap()
        }
        
        _ = app.navigationBars["Меню"].waitForExistence(timeout: 5)
    }
    
    func addFirstDishToCart() {
        performLogin()
        
        // Open first dish
        let firstDish = app.scrollViews.buttons.firstMatch
        firstDish.tap()
        
        // Add to cart
        let addButton = app.buttons["addToCartButton"]
        addButton.tap()
    }
}

// MARK: - Helper Extension
extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.tap()
        self.typeText(deleteString)
    }
}
