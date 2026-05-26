import SwiftUI

struct DishDetailView: View {
    let dish: Dish
    @Binding var selectedDish: Dish?
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.dismiss) var dismiss

    // Pizza state
    @State private var pizzaSizeIndex: Int = 1    // 0=15, 1=20, 2=23
    @State private var pizzaPastryIndex: Int = 1  // 0=Тонкое, 1=Обычное
    @State private var pizzaSpicyIndex: Int = 1   // 0=Острое, 1=Оригинальное

    // Burger state
    @State private var burgerCheese: Bool = false
    @State private var burgerOnion: Bool = false
    @State private var burgerCucumber: Bool = false
    @State private var burgerTomato: Bool = false

    // Snack state
    @State private var snackSizeIndex: Int = 1  // 0=Большая, 1=Средняя, 2=Маленькая

    // Drink state
    @State private var drinkVolumeIndex: Int = 1  // 0=0.3л, 1=0.5л

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Dish hero
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(heroGradient)
                                .frame(height: 200)
                            Image(dish.imageName)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(height: 150)
                                                            .shadow(radius: 8)
                        }
                        .padding(.horizontal, 20)

                        // Name + price
                        HStack {
                            Text(dish.name)
                                .font(.title)
                                .fontWeight(.black)
                            Spacer()
                            Text(String(format: "%.2f BYN", dish.price))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 20)

                        Divider().padding(.horizontal, 20)

                        // Category-specific options
                        Group {
                            if let pizza = dish as? Pizza {
                                pizzaOptions(pizza: pizza)
                            } else if let burger = dish as? Burger {
                                burgerOptions(burger: burger)
                            } else if let snack = dish as? Snack {
                                snackOptions(snack: snack)
                            } else if let drink = dish as? Drink {
                                drinkOptions(drink: drink)
                            }
                        }
                        .padding(.horizontal, 20)

                        Color.clear.frame(height: 90)
                    }
                    .padding(.top, 20)
                }

                // Add to cart button
                Button(action: addToCart) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 18))
                        Text("Добавить в корзину")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [Color.orange, Color.red.opacity(0.85)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(color: .orange.opacity(0.45), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Детали блюда")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Меню")
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
        }
    }

    // MARK: - Pizza Options
    @ViewBuilder
    func pizzaOptions(pizza: Pizza) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            OptionSection(title: "Размер") {
                Picker("Размер", selection: $pizzaSizeIndex) {
                    Text("15 см").tag(0)
                    Text("20 см").tag(1)
                    Text("23 см").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            OptionSection(title: "Тесто") {
                Picker("Тесто", selection: $pizzaPastryIndex) {
                    Text("Тонкое").tag(0)
                    Text("Обычное").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            OptionSection(title: "Вкус") {
                Picker("Вкус", selection: $pizzaSpicyIndex) {
                    Text("🌶 Острое").tag(0)
                    Text("😋 Оригинальное").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }

    // MARK: - Burger Options
    @ViewBuilder
    func burgerOptions(burger: Burger) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Топпинги")
                .font(.headline)
                .fontWeight(.semibold)

            CheckboxRow(label: "🧀 Сыр", isChecked: $burgerCheese)
            CheckboxRow(label: "🧅 Лук", isChecked: $burgerOnion)
            CheckboxRow(label: "🥒 Огурчик", isChecked: $burgerCucumber)
            CheckboxRow(label: "🍅 Помидор", isChecked: $burgerTomato)
        }
    }

    // MARK: - Snack Options
    @ViewBuilder
    func snackOptions(snack: Snack) -> some View {
        OptionSection(title: "Порция") {
            Picker("Порция", selection: $snackSizeIndex) {
                Text("Большая").tag(0)
                Text("Средняя").tag(1)
                Text("Маленькая").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    // MARK: - Drink Options
    @ViewBuilder
    func drinkOptions(drink: Drink) -> some View {
        OptionSection(title: "Объём") {
            Picker("Объём", selection: $drinkVolumeIndex) {
                Text("0.3 л").tag(0)
                Text("0.5 л").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    // MARK: - Build Dish & Add
    private func addToCart() {
        let configuredDish: Dish

        if let pizza = dish as? Pizza {
            let sizes = [15, 20, 23]
            let pastries = ["Тонкое", "Обычное"]
            let newPizza = Pizza(
                name: pizza.name, price: pizza.price,
                size: sizes[pizzaSizeIndex],
                pastry: pastries[pizzaPastryIndex],
                spicy: pizzaSpicyIndex == 0
            )
            configuredDish = newPizza
        } else if let burger = dish as? Burger {
            let newBurger = Burger(
                name: burger.name, price: burger.price,
                cheese: burgerCheese, onion: burgerOnion,
                cucumber: burgerCucumber, tomato: burgerTomato
            )
            configuredDish = newBurger
        } else if let snack = dish as? Snack {
            let sizes = ["Большая", "Средняя", "Маленькая"]
            let newSnack = Snack(name: snack.name, price: snack.price, size: sizes[snackSizeIndex])
            configuredDish = newSnack
        } else if let drink = dish as? Drink {
            let volumes = [0.3, 0.5]
            let newDrink = Drink(name: drink.name, price: drink.price, volume: volumes[drinkVolumeIndex])
            configuredDish = newDrink
        } else {
            configuredDish = dish
        }

        cartViewModel.addDish(configuredDish)
        dismiss()
    }

    var heroGradient: LinearGradient {
        switch dish {
        case is Pizza:  return LinearGradient(colors: [.orange.opacity(0.4), .red.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case is Burger: return LinearGradient(colors: [.yellow.opacity(0.4), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case is Snack:  return LinearGradient(colors: [.yellow.opacity(0.5), .brown.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case is Drink:  return LinearGradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:        return LinearGradient(colors: [.gray.opacity(0.2), .gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Helper Views
struct OptionSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            content
        }
    }
}

struct CheckboxRow: View {
    let label: String
    @Binding var isChecked: Bool

    var body: some View {
        Button(action: { isChecked.toggle() }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isChecked ? Color.orange : Color.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isChecked {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.orange)
                            .frame(width: 16, height: 16)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                Text(label)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
