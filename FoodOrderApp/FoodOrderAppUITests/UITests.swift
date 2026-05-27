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
        
        // Добавляем задержку для стабильности
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    override func tearDownWithError() throws {
        // Очищаем состояние между тестами
        app.terminate()
    }
    
    // MARK: - Auth Screen Tests
    
    func testAuthScreenElements() {
        // Используем waitForExistence для каждого элемента
        let loginField = app.textFields["loginTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let authButton = app.buttons["authButton"]
        
        XCTAssertTrue(loginField.waitForExistence(timeout: 5))
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(authButton.exists)
    }
    
    func testSwitchToSignupMode() {
        let segmentControl = app.segmentedControls["authSegmentedControl"]
        XCTAssertTrue(segmentControl.waitForExistence(timeout: 5))
        segmentControl.buttons["Регистрация"].tap()
        
        // Даем время для анимации
        Thread.sleep(forTimeInterval: 0.5)
        
        // Address field should appear
        let addressField = app.textFields["addressTextField"]
        XCTAssertTrue(addressField.waitForExistence(timeout: 5))
    }
    
    func testLoginValidationShowsError() {
        // Нажимаем кнопку входа без ввода данных
        let authButton = app.buttons["authButton"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        // Ждем появления сообщения об ошибке
        let errorMessage = app.staticTexts["errorMessage"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 3))
        
        // Проверяем, что сообщение не пустое
        XCTAssertFalse(errorMessage.label.isEmpty)
    }
    
    func testSuccessfulRegistrationAndLogin() {
        let uniqueLogin = "testuser_\(Int(Date().timeIntervalSince1970))"
        
        // Switch to registration
        let segmentControl = app.segmentedControls["authSegmentedControl"]
        XCTAssertTrue(segmentControl.waitForExistence(timeout: 5))
        segmentControl.buttons["Регистрация"].tap()
        
        Thread.sleep(forTimeInterval: 0.5)
        
        // Fill fields
        let loginField = app.textFields["loginTextField"]
        XCTAssertTrue(loginField.waitForExistence(timeout: 5))
        loginField.tap()
        loginField.typeText(uniqueLogin)
        
        let passwordField = app.secureTextFields["passwordTextField"]
        passwordField.tap()
        passwordField.typeText("pass1234")
        
        let addressField = app.textFields["addressTextField"]
        XCTAssertTrue(addressField.waitForExistence(timeout: 5))
        addressField.tap()
        addressField.typeText("ул. Тестовая, д. 1")
        
        // Submit registration
        let authButton = app.buttons["authButton"]
        authButton.tap()
        
        // Should navigate to menu
        let menuTitle = app.navigationBars["Меню"]
        XCTAssertTrue(menuTitle.waitForExistence(timeout: 5))
    }
    
    // MARK: - Menu Screen Tests
    
    func testMenuCategoriesExist() {
        // First login
        performLogin()
        
        // Проверяем наличие категорий
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        // Скроллим вверх, чтобы увидеть все категории
        scrollView.swipeUp()
        Thread.sleep(forTimeInterval: 0.5)
        scrollView.swipeDown()
        Thread.sleep(forTimeInterval: 0.5)
        
        let pizzaCategory = app.staticTexts["Пицца"]
        let burgersCategory = app.staticTexts["Бургеры"]
        
        XCTAssertTrue(pizzaCategory.waitForExistence(timeout: 3))
        XCTAssertTrue(burgersCategory.exists)
    }
    
    func testLogoutButtonWorks() {
        performLogin()
        
        let logoutButton = app.buttons["logoutButton"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()
        
        // Should return to auth screen
        let loginField = app.textFields["loginTextField"]
        XCTAssertTrue(loginField.waitForExistence(timeout: 5))
    }
    
    func testCartButtonExists() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        XCTAssertTrue(cartButton.waitForExistence(timeout: 5))
    }
    
    // MARK: - Cart Screen Tests
    
    func testCartScreenOpens() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        XCTAssertTrue(cartButton.waitForExistence(timeout: 5))
        cartButton.tap()
        
        let cartTitle = app.navigationBars["Корзина"]
        XCTAssertTrue(cartTitle.waitForExistence(timeout: 5))
    }
    
    func testEmptyCartShowsMessage() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let emptyMessage = app.staticTexts["Корзина пуста"]
        XCTAssertTrue(emptyMessage.waitForExistence(timeout: 5))
    }
    
    // MARK: - Map Screen Tests
    
    func testMapButtonOpensMap() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let selectOnMapButton = app.buttons["selectOnMapButton"]
        XCTAssertTrue(selectOnMapButton.waitForExistence(timeout: 5))
        selectOnMapButton.tap()
        
        let mapTitle = app.navigationBars["Выбор ресторана"]
        XCTAssertTrue(mapTitle.waitForExistence(timeout: 5))
    }
    
    func testNearestRestaurantButtonExists() {
        performLogin()
        
        let cartButton = app.buttons["cartButton"]
        cartButton.tap()
        
        let selectOnMapButton = app.buttons["selectOnMapButton"]
        selectOnMapButton.tap()
        
        let nearestButton = app.buttons["nearestButton"]
        XCTAssertTrue(nearestButton.waitForExistence(timeout: 5))
    }
    
    // MARK: - Helper Methods
    
    func performLogin() {
        // Проверяем, уже залогинены ли мы
        if app.navigationBars["Меню"].exists {
            return
        }
        
        let loginField = app.textFields["loginTextField"]
        let passwordField = app.secureTextFields["passwordTextField"]
        let authButton = app.buttons["authButton"]
        
        // Ждем появления полей
        XCTAssertTrue(loginField.waitForExistence(timeout: 10))
        XCTAssertTrue(passwordField.waitForExistence(timeout: 5))
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        
        // Используем существующий тестовый аккаунт
        loginField.tap()
        loginField.typeText("testuser_123")
        
        passwordField.tap()
        passwordField.typeText("pass1234")
        
        authButton.tap()
        
        // Если логин не удался, создаем новый аккаунт
        if !app.navigationBars["Меню"].waitForExistence(timeout: 3) {
            let uniqueLogin = "testuser_\(Int(Date().timeIntervalSince1970))"
            let segmentControl = app.segmentedControls["authSegmentedControl"]
            XCTAssertTrue(segmentControl.waitForExistence(timeout: 5))
            segmentControl.buttons["Регистрация"].tap()
            
            Thread.sleep(forTimeInterval: 0.5)
            
            loginField.tap()
            loginField.clearText()
            loginField.typeText(uniqueLogin)
            
            passwordField.tap()
            passwordField.clearText()
            passwordField.typeText("pass1234")
            
            let addressField = app.textFields["addressTextField"]
            XCTAssertTrue(addressField.waitForExistence(timeout: 5))
            addressField.tap()
            addressField.typeText("ул. Тестовая, 1")
            
            authButton.tap()
        }
        
        // Ждем появления меню
        XCTAssertTrue(app.navigationBars["Меню"].waitForExistence(timeout: 10))
        
        // Даем время на полную загрузку
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    func addFirstDishToCart() {
        performLogin()
        
        // Открываем первое блюдо
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        // Находим первую карточку блюда
        let firstDish = scrollView.buttons.firstMatch
        XCTAssertTrue(firstDish.waitForExistence(timeout: 5))
        firstDish.tap()
        
        // Добавляем в корзину
        let addButton = app.buttons["addToCartButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // Даем время на добавление
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    func openFirstPizza() {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        // Ищем карточку пиццы
        let pizzaCard = app.buttons["dishCard_Маргарита"]
        if pizzaCard.exists {
            pizzaCard.tap()
        } else {
            // Если не нашли по имени, скроллим и ищем любую пиццу
            scrollView.swipeDown()
            Thread.sleep(forTimeInterval: 0.5)
            let firstCard = scrollView.buttons.firstMatch
            firstCard.tap()
        }
        
        // Ждем открытия детального экрана
        XCTAssertTrue(app.navigationBars["Детали блюда"].waitForExistence(timeout: 5))
    }
    
    func openFirstBurger() {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        
        // Скроллим до бургеров
        let burgersText = app.staticTexts["Бургеры"]
        if burgersText.exists {
            scrollView.scrollToElement(burgersText)
            Thread.sleep(forTimeInterval: 0.5)
        }
        
        // Ищем карточку бургера
        let burgerCard = app.buttons["dishCard_Чизбургер"]
        if burgerCard.exists {
            burgerCard.tap()
        } else {
            // Если не нашли, пытаемся найти любой бургер
            let burgerButton = app.buttons.containing(NSPredicate(format: "identifier CONTAINS 'бургер'")).firstMatch
            if burgerButton.exists {
                burgerButton.tap()
            }
        }
        
        // Ждем открытия детального экрана
        _ = app.navigationBars["Детали блюда"].waitForExistence(timeout: 5)
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.tap()
        self.typeText(deleteString)
    }
    
    func scrollToElement(_ element: XCUIElement) {
        while !element.isFullyVisibleOnScreen() && exists {
            swipeUp()
            Thread.sleep(forTimeInterval: 0.2)
        }
    }
    
    func isFullyVisibleOnScreen() -> Bool {
        guard exists && !frame.isEmpty else { return false }
        let window = XCUIApplication().windows.firstMatch
        return window.frame.contains(frame)
    }
}
