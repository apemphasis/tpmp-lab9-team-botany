//
//  UnitTests.swift
//  FoodOrderAppTests
//
//  Created by Amir Sailaubaev on 26.05.26.
//

import XCTest
@testable import FoodOrderApp

final class FoodOrderAppUnitTests: XCTestCase {
    
    // MARK: - Dish Model Tests
    
    func testPizzaInitialization() {
        let pizza = Pizza(name: "Маргарита", price: 14.90, size: 20, pastry: "тонкое", spicy: true)
        
        XCTAssertEqual(pizza.name, "Маргарита")
        XCTAssertEqual(pizza.price, 14.90)
        XCTAssertEqual(pizza.size, 20)
        XCTAssertEqual(pizza.pastry, "тонкое")
        XCTAssertTrue(pizza.spicy)
    }
    
    func testBurgerInitialization() {
        let burger = Burger(name: "Чизбургер", price: 9.90, cheese: true, onion: false, cucumber: true, tomato: false)
        
        XCTAssertEqual(burger.name, "Чизбургер")
        XCTAssertEqual(burger.price, 9.90)
        XCTAssertTrue(burger.cheese)
        XCTAssertFalse(burger.onion)
        XCTAssertTrue(burger.cucumber)
        XCTAssertFalse(burger.tomato)
    }
    
    func testSnackInitialization() {
        let snack = Snack(name: "Картофель фри", price: 4.90, size: "большая")
        
        XCTAssertEqual(snack.name, "Картофель фри")
        XCTAssertEqual(snack.price, 4.90)
        XCTAssertEqual(snack.size, "большая")
    }
    
    func testDrinkInitialization() {
        let drink = Drink(name: "Кока-Кола", price: 2.90, volume: 0.5)
        
        XCTAssertEqual(drink.name, "Кока-Кола")
        XCTAssertEqual(drink.price, 2.90)
        XCTAssertEqual(drink.volume, 0.5)
    }
    
    func testPizzaToString() {
        let pizza = Pizza(name: "Пепперони", price: 18.90, size: 23, pastry: "обычное", spicy: true)
        let description = pizza.toString()
        
        XCTAssertTrue(description.contains("Пепперони"))
        XCTAssertTrue(description.contains("23см"))
        XCTAssertTrue(description.contains("обычное"))
        XCTAssertTrue(description.contains("Острое"))
    }
    
    func testBurgerToStringWithToppings() {
        let burger = Burger(name: "Гамбургер", price: 8.90, cheese: true, onion: true, cucumber: false, tomato: false)
        let description = burger.toString()
        
        XCTAssertTrue(description.contains("Гамбургер"))
        XCTAssertTrue(description.contains("сыр"))
        XCTAssertTrue(description.contains("лук"))
    }
    
    // MARK: - Order Tests
    
    func testOrderSumPriceCalculation() {
        let order = Order()
        let pizza = Pizza(name: "Маргарита", price: 14.90)
        let drink = Drink(name: "Кола", price: 2.90)
        
        order.addDish(pizza)
        order.addDish(drink)
        
        XCTAssertEqual(order.sumPrice, 17.80, accuracy: 0.01)
    }
    
    func testOrderSumPriceWithExcludedItems() {
        let order = Order()
        let pizza = Pizza(name: "Пепперони", price: 18.90)
        
        order.addDish(pizza)
        order.items[0].included = false
        
        XCTAssertEqual(order.sumPrice, 0)
    }
    
    func testOrderRemoveItem() {
        let order = Order()
        let pizza = Pizza(name: "Маргарита", price: 14.90)
        order.addDish(pizza)
        
        XCTAssertEqual(order.items.count, 1)
        
        let itemId = order.items[0].id
        order.removeItem(id: itemId)
        
        XCTAssertEqual(order.items.count, 0)
    }
    
    func testOrderReset() {
        let order = Order()
        order.addDish(Pizza(name: "Пицца", price: 10.0))
        order.address = "ул. Тестовая"
        order.payment = "Наличные"
        order.comment = "Тестовый комментарий"
        
        order.reset()
        
        XCTAssertTrue(order.items.isEmpty)
        XCTAssertEqual(order.address, "")
        XCTAssertEqual(order.payment, "Онлайн")
        XCTAssertEqual(order.comment, "")
    }
    
    // MARK: - AuthViewModel Validation Tests
    
    func testValidateLoginSuccess() {
        let authVM = AuthViewModel()
        let result = authVM.validateLogin(login: "user123", password: "pass1234")
        
        XCTAssertNil(result)
    }
    
    func testValidateLoginEmptyLogin() {
        let authVM = AuthViewModel()
        let result = authVM.validateLogin(login: "", password: "pass1234")
        
        XCTAssertEqual(result, "Логин не может быть пустым")
    }
    
    func testValidateLoginTooShort() {
        let authVM = AuthViewModel()
        let result = authVM.validateLogin(login: "ab", password: "pass1234")
        
        XCTAssertEqual(result, "Логин должен содержать минимум 3 символа")
    }
    
    func testValidateLoginEmptyPassword() {
        let authVM = AuthViewModel()
        let result = authVM.validateLogin(login: "user123", password: "")
        
        XCTAssertEqual(result, "Пароль не может быть пустым")
    }
    
    func testValidateLoginShortPassword() {
        let authVM = AuthViewModel()
        let result = authVM.validateLogin(login: "user123", password: "123")
        
        XCTAssertEqual(result, "Пароль должен содержать минимум 4 символа")
    }
    
    func testValidateSignupSuccess() {
        let authVM = AuthViewModel()
        let result = authVM.validateSignup(login: "user123", password: "pass1234", address: "ул. Ленина, 10")
        
        XCTAssertNil(result)
    }
    
    func testValidateSignupEmptyAddress() {
        let authVM = AuthViewModel()
        let result = authVM.validateSignup(login: "user123", password: "pass1234", address: "")
        
        XCTAssertEqual(result, "Адрес не может быть пустым")
    }
    
    func testValidateSignupShortAddress() {
        let authVM = AuthViewModel()
        let result = authVM.validateSignup(login: "user123", password: "pass1234", address: "ул")
        
        XCTAssertEqual(result, "Введите корректный адрес доставки")
    }
    
    // MARK: - CartViewModel Tests
    
    func testAddDishToCart() {
        let cartVM = CartViewModel()
        let pizza = Pizza(name: "Маргарита", price: 14.90)
        
        cartVM.addDish(pizza)
        
        XCTAssertEqual(cartVM.order.items.count, 1)
        XCTAssertEqual(cartVM.itemCount, 1)
    }
    
    func testItemCountOnlyIncluded() {
        let cartVM = CartViewModel()
        let pizza = Pizza(name: "Пепперони", price: 18.90)
        let drink = Drink(name: "Кола", price: 2.90)
        
        cartVM.addDish(pizza)
        cartVM.addDish(drink)
        cartVM.order.items[0].included = false
        
        XCTAssertEqual(cartVM.itemCount, 1)
    }
    
    func testPlaceOrderResetsCart() {
        let cartVM = CartViewModel()
        cartVM.addDish(Pizza(name: "Маргарита", price: 14.90))
        
        cartVM.placeOrder(userAddress: "ул. Тестовая")
        
        XCTAssertTrue(cartVM.order.items.isEmpty)
    }
    
    // MARK: - DatabaseManager Tests
    
    func testDatabaseUserCreation() {
        let dbManager = DatabaseManager.shared
        dbManager.setupDatabase()
        
        let uniqueLogin = "test_user_\(UUID().uuidString.prefix(8))"
        let user = dbManager.createUser(login: uniqueLogin, pass: "password123", adress: "ул. Тестовая, 1")
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.login, uniqueLogin)
        XCTAssertEqual(user?.adress, "ул. Тестовая, 1")
    }
    
    func testDatabaseDuplicateUser() {
        let dbManager = DatabaseManager.shared
        dbManager.setupDatabase()
        
        let uniqueLogin = "duplicate_test_\(UUID().uuidString.prefix(8))"
        _ = dbManager.createUser(login: uniqueLogin, pass: "pass1", adress: "Адрес 1")
        let duplicateUser = dbManager.createUser(login: uniqueLogin, pass: "pass2", adress: "Адрес 2")
        
        XCTAssertNil(duplicateUser)
    }
    
    func testDatabaseLoginSuccess() {
        let dbManager = DatabaseManager.shared
        dbManager.setupDatabase()
        
        let uniqueLogin = "login_test_\(UUID().uuidString.prefix(8))"
        _ = dbManager.createUser(login: uniqueLogin, pass: "secret123", adress: "Адрес")
        
        let user = dbManager.loginUser(login: uniqueLogin, pass: "secret123")
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.login, uniqueLogin)
    }
    
    func testDatabaseLoginWrongPassword() {
        let dbManager = DatabaseManager.shared
        dbManager.setupDatabase()
        
        let uniqueLogin = "wrong_pass_\(UUID().uuidString.prefix(8))"
        _ = dbManager.createUser(login: uniqueLogin, pass: "correct", adress: "Адрес")
        
        let user = dbManager.loginUser(login: uniqueLogin, pass: "wrong")
        
        XCTAssertNil(user)
    }
    
    // MARK: - Restaurant Model Tests
    
    func testRestaurantsCount() {
        let restaurants = Restaurant.minskRestaurants
        XCTAssertEqual(restaurants.count, 5)
    }
    
    func testRestaurantCoordinates() {
        let restaurant = Restaurant.minskRestaurants[0]
        XCTAssertEqual(restaurant.adress, "пр. Независимости, 78, Минск")
        XCTAssertEqual(restaurant.lat, 53.9045)
        XCTAssertEqual(restaurant.long, 27.5615)
    }
}
