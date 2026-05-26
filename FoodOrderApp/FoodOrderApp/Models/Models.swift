import Foundation

// MARK: - User Model
struct User: Identifiable {
    let id: String
    var login: String
    var pass: String
    var adress: String

    init(id: String = UUID().uuidString, login: String, pass: String, adress: String) {
        self.id = id
        self.login = login
        self.pass = pass
        self.adress = adress
    }
}

// MARK: - Dish Base Class
class Dish: Identifiable, ObservableObject {
    let id: String
    var name: String
    var price: Double

    init(id: String = UUID().uuidString, name: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
    }

    func toString() -> String {
        return "[\(name)] - \(String(format: "%.2f", price)) BYN"
    }

    var categoryName: String { "Блюдо" }
    var imageName: String {
            switch name {
            // Пиццы
            case "Пепперони": return "pepperoni"
            case "Маргарита": return "margarita"
            case "4 Сыра":    return "4cheese"
            case "Барбекю":   return "barbeque"
            // Бургеры
            case "Гамбургер":   return "hamburger"
            case "Чизбургер":   return "cheeseburger"
            case "Чикенбургер": return "chikenburger"
            // Закуски
            case "Картофель фри": return "free"
            case "Наггетсы":      return "nuggets"
            case "Крылышки":      return "wings"
            // Напитки
            case "Кока-Кола": return "cola"
            case "Фанта":     return "fanta"
            case "Спрайт":    return "sprite"
            case "Пиво":      return "beer"
                
            default: return "default_dish" // Картинка по умолчанию, если ничего не найдено
            }
        }
}

// MARK: - Pizza
class Pizza: Dish {
    var size: Int         // 15, 20, 23
    var pastry: String    // "Тонкое", "Обычное"
    var spicy: Bool       // true = Острое, false = Оригинальное

    init(id: String = UUID().uuidString, name: String, price: Double,
         size: Int = 20, pastry: String = "Обычное", spicy: Bool = false) {
        self.size = size
        self.pastry = pastry
        self.spicy = spicy
        super.init(id: id, name: name, price: price)
    }

    override func toString() -> String {
        return """
        🍕 \(name)
           Размер: \(size)см | Тесто: \(pastry) | \(spicy ? "Острое" : "Оригинальное")
           Цена: \(String(format: "%.2f", price)) BYN
        """
    }

    override var categoryName: String { "Пицца" }
    //override var imageName: String { "🍕" }
}

// MARK: - Burger
class Burger: Dish {
    var cheese: Bool
    var onion: Bool
    var cucumber: Bool
    var tomato: Bool

    init(id: String = UUID().uuidString, name: String, price: Double,
         cheese: Bool = false, onion: Bool = false,
         cucumber: Bool = false, tomato: Bool = false) {
        self.cheese = cheese
        self.onion = onion
        self.cucumber = cucumber
        self.tomato = tomato
        super.init(id: id, name: name, price: price)
    }

    override func toString() -> String {
        var toppings: [String] = []
        if cheese { toppings.append("сыр") }
        if onion { toppings.append("лук") }
        if cucumber { toppings.append("огурчик") }
        if tomato { toppings.append("помидор") }
        return """
        🍔 \(name)
           Добавки: \(toppings.isEmpty ? "без добавок" : toppings.joined(separator: ", "))
           Цена: \(String(format: "%.2f", price)) BYN
        """
    }

    override var categoryName: String { "Бургеры" }
    //override var imageName: String { "🍔" }
}

// MARK: - Snack
class Snack: Dish {
    var size: String  // "Большая", "Средняя", "Маленькая"

    init(id: String = UUID().uuidString, name: String, price: Double, size: String = "Средняя") {
        self.size = size
        super.init(id: id, name: name, price: price)
    }

    override func toString() -> String {
        return """
        🍟 \(name)
           Порция: \(size)
           Цена: \(String(format: "%.2f", price)) BYN
        """
    }

    override var categoryName: String { "Закуски" }
    //override var imageName: String { "🍟" }
}

// MARK: - Drink
class Drink: Dish {
    var volume: Double  // 0.3, 0.5

    init(id: String = UUID().uuidString, name: String, price: Double, volume: Double = 0.5) {
        self.volume = volume
        super.init(id: id, name: name, price: price)
    }

    override func toString() -> String {
        return """
        🥤 \(name)
           Объём: \(volume)л
           Цена: \(String(format: "%.2f", price)) BYN
        """
    }

    override var categoryName: String { "Напитки" }
    //override var imageName: String { "🥤" }
}

// MARK: - Restaurant
struct Restaurant: Identifiable {
    let id: String
    var adress: String
    var lat: Double
    var long: Double

    init(id: String = UUID().uuidString, adress: String, lat: Double, long: Double) {
        self.id = id
        self.adress = adress
        self.lat = lat
        self.long = long
    }

    static let minskRestaurants: [Restaurant] = [
        Restaurant(adress: "пр. Независимости, 78, Минск", lat: 53.9045, long: 27.5615),
        Restaurant(adress: "ул. Немига, 5, Минск",          lat: 53.9068, long: 27.5503),
        Restaurant(adress: "пр. Победителей, 9, Минск",     lat: 53.9120, long: 27.5430),
        Restaurant(adress: "ул. Притыцкого, 29, Минск",     lat: 53.9200, long: 27.4900),
        Restaurant(adress: "пр. Дзержинского, 104, Минск",  lat: 53.8720, long: 27.4980)
    ]
}

// MARK: - Order Item (dish + included flag)
struct OrderItem: Identifiable {
    let id: String
    let dish: Dish
    var included: Bool

    init(dish: Dish, included: Bool = true) {
        self.id = UUID().uuidString
        self.dish = dish
        self.included = included
    }
}

// MARK: - Order
class Order: ObservableObject {
    var number: Int
    @Published var items: [OrderItem] = []
    var address: String = ""
    var payment: String = "Онлайн"
    var comment: String = ""

    init(number: Int = Int.random(in: 1000...9999)) {
        self.number = number
    }

    var sumPrice: Double {
        items.filter { $0.included }.reduce(0) { $0 + $1.dish.price }
    }

    var includedDishes: [Dish] {
        items.filter { $0.included }.map { $0.dish }
    }

    func addDish(_ dish: Dish) {
        items.append(OrderItem(dish: dish))
    }

    func removeItem(id: String) {
        items.removeAll { $0.id == id }
    }

    func reset() {
        items = []
        address = ""
        payment = "Онлайн"
        comment = ""
        number = Int.random(in: 1000...9999)
    }

    func toString() -> String {
        let dishes = includedDishes.map { $0.toString() }.joined(separator: "\n")
        return """
        ╔══════════════════════════════════════╗
        ║         НОВЫЙ ЗАКАЗ #\(number)           ║
        ╠══════════════════════════════════════╣
        ║ Адрес доставки: \(address)
        ║ Способ оплаты: \(payment)
        ║ Комментарий: \(comment.isEmpty ? "—" : comment)
        ║ Сумма: \(String(format: "%.2f", sumPrice)) BYN
        ╠══════════════════════════════════════╣
        ║ СОСТАВ ЗАКАЗА:
        \(dishes)
        ╚══════════════════════════════════════╝
        """
    }
}

// MARK: - Menu Data
struct MenuData {
    static let pizzas: [Pizza] = [
        Pizza(name: "Пепперони", price: 18.90),
        Pizza(name: "Маргарита", price: 14.90),
        Pizza(name: "4 Сыра",   price: 17.90),
        Pizza(name: "Барбекю",  price: 19.90)
    ]

    static let burgers: [Burger] = [
        Burger(name: "Гамбургер",    price: 8.90),
        Burger(name: "Чизбургер",    price: 9.90),
        Burger(name: "Чикенбургер", price: 10.90)
    ]

    static let snacks: [Snack] = [
        Snack(name: "Картофель фри", price: 4.90),
        Snack(name: "Наггетсы",      price: 6.90),
        Snack(name: "Крылышки",      price: 8.90)
    ]

    static let drinks: [Drink] = [
        Drink(name: "Кока-Кола", price: 2.90),
        Drink(name: "Фанта",     price: 2.90),
        Drink(name: "Спрайт",    price: 2.90),
        Drink(name: "Пиво",      price: 3.90)
    ]

    static var allCategories: [(name: String, emoji: String, dishes: [Dish])] {
        [
            ("Пицца",   "🍕", pizzas),
            ("Бургеры", "🍔", burgers),
            ("Закуски", "🍟", snacks),
            ("Напитки", "🥤", drinks)
        ]
    }
}
