import SwiftUI

struct MenuView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var showCart: Bool = false
    @State private var selectedDish: Dish? = nil

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header greeting
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Добро пожаловать,")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(authViewModel.currentUser?.login ?? "Гость")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Button(action: { authViewModel.logout() }) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.secondary)
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                        // Category sections
                        ForEach(MenuData.allCategories, id: \.name) { category in
                            CategorySection(
                                name: category.name,
                                emoji: category.emoji,
                                dishes: category.dishes,
                                onSelectDish: { dish in
                                    selectedDish = dish
                                }
                            )
                        }

                        // Space for cart button
                        Color.clear.frame(height: 100)
                    }
                }

                // Fixed cart button
                CartButton(showCart: $showCart)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .navigationTitle("Меню")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCart) {
                CartView()
            }
            .sheet(item: $selectedDish) { dish in
                DishDetailView(dish: dish, selectedDish: $selectedDish)
            }
        }
    }
}

// MARK: - Category Section
struct CategorySection: View {
    let name: String
    let emoji: String
    let dishes: [Dish]
    let onSelectDish: (Dish) -> Void

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack(spacing: 8) {
                Text(emoji)
                    .font(.title2)
                Text(name)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 20)

            // Dishes grid
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(dishes) { dish in
                    DishCard(dish: dish)
                        .onTapGesture {
                            onSelectDish(dish)
                        }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 28)
    }
}

// MARK: - Dish Card
struct DishCard: View {
    let dish: Dish

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image area
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: dishGradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 110)
                Image(dish.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .shadow(radius: 4)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(dish.name)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)
                Text(String(format: "%.2f BYN", dish.price))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.orange)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 10)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 3)
    }

    var dishGradient: [Color] {
        switch dish {
        case is Pizza:  return [Color.orange.opacity(0.3), Color.red.opacity(0.2)]
        case is Burger: return [Color.yellow.opacity(0.3), Color.orange.opacity(0.2)]
        case is Snack:  return [Color.yellow.opacity(0.4), Color.brown.opacity(0.15)]
        case is Drink:  return [Color.blue.opacity(0.2), Color.cyan.opacity(0.15)]
        default:        return [Color.gray.opacity(0.2), Color.gray.opacity(0.1)]
        }
    }
}

// MARK: - Cart Button
struct CartButton: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @Binding var showCart: Bool

    var body: some View {
        Button(action: { showCart = true }) {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.system(size: 18))
                Text("Корзина")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                //if cartViewModel.itemCount > 0 {
                    //Text("\(cartViewModel.itemCount) блюд")
                    //    .font(.system(size: 14, weight: .medium))
                    //    .padding(.horizontal, 10)
                    //    .padding(.vertical, 4)
                    //    .background(Color.white.opacity(0.25))
                    //    .cornerRadius(12)
                //}
                //Text(String(format: "%.2f BYN", cartViewModel.order.sumPrice))
                //    .font(.system(size: 15, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.red.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(18)
            .shadow(color: .orange.opacity(0.5), radius: 12, x: 0, y: 6)
        }
    }
}
