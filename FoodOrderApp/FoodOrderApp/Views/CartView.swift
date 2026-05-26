import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var paymentIndex: Int = 0
    @State private var comment: String = ""
    @State private var showMap: Bool = false
    @State private var deliveryAddress: String = ""
    @State private var showOrderSuccess: Bool = false

    let paymentMethods = ["Онлайн", "ЕРИП", "Терминал", "Наличные"]

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Dishes list
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Список блюд")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)

                            if cartViewModel.order.items.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 12) {
                                        Text("🛒")
                                            .font(.system(size: 50))
                                        Text("Корзина пуста")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                        Text("Добавьте блюда из меню")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 40)
                                    Spacer()
                                }
                                .accessibilityIdentifier("emptyCartView")
                            } else {
                                ForEach($cartViewModel.order.items) { $item in
                                    CartItemRow(item: $item) {
                                        print(item.id)
                                        cartViewModel.order.removeItem(id: item.id)
                                    }
                                    .padding(.horizontal, 16)
                                    .accessibilityIdentifier("cartItem_\(item.dish.name)")
                                }
                            }
                        }

                        Divider().padding(.horizontal, 20)

                        // Sum
                        HStack {
                            Text("Сумма:")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.2f BYN", cartViewModel.order.sumPrice))
                                .font(.title3)
                                .fontWeight(.black)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4)

                        Divider().padding(.horizontal, 20)

                        // Payment
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Способ оплаты")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)

                            Picker("Оплата", selection: $paymentIndex) {
                                ForEach(0..<paymentMethods.count, id: \.self) { i in
                                    Text(paymentMethods[i]).tag(i)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal, 20)
                            .accessibilityIdentifier("paymentPicker")
                        }

                        Divider().padding(.horizontal, 20)

                        // Address
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Адрес доставки")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)

                            HStack(spacing: 10) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.orange)
                                Text(deliveryAddress.isEmpty
                                     ? (authViewModel.currentUser?.adress ?? "Не указан")
                                     : deliveryAddress)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                Spacer()
                            }
                            .padding(14)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)

                            Button(action: { showMap = true }) {
                                HStack {
                                    Image(systemName: "map.fill")
                                    Text("Выбрать на карте")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .cornerRadius(14)
                            }
                            .padding(.horizontal, 20)
                            .accessibilityIdentifier("selectOnMapButton")
                        }

                        Divider().padding(.horizontal, 20)

                        // Comment
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Комментарий к заказу")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)

                            TextEditor(text: $comment)
                                .frame(height: 100)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2))
                                )
                                .padding(.horizontal, 20)
                                .overlay(alignment: .topLeading) {
                                    if comment.isEmpty {
                                        Text("Например: позвонить в дверь...")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 30)
                                            .padding(.top, 18)
                                            .allowsHitTesting(false)
                                    }
                                }
                        }

                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 16)
                }

                // Place order button
                Button(action: placeOrder) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                        Text("Заказать")
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                        if cartViewModel.order.sumPrice > 0 {
                            Text(String(format: "%.2f BYN", cartViewModel.order.sumPrice))
                                .font(.system(size: 16, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        cartViewModel.order.items.isEmpty
                            ? AnyShapeStyle(Color.gray)
                            : AnyShapeStyle(LinearGradient(
                                colors: [Color.orange, Color.red.opacity(0.85)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                    )
                    .cornerRadius(18)
                    .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .disabled(cartViewModel.order.items.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .accessibilityIdentifier("placeOrderButton")
            }
            .navigationTitle("Корзина")
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
            .sheet(isPresented: $showMap) {
                MapView(selectedAddress: $deliveryAddress)
            }
            .alert("Заказ оформлен! 🎉", isPresented: $showOrderSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("Ваш заказ #\(cartViewModel.order.number) принят. Ожидайте доставку!")
            }
        }
    }

    private func placeOrder() {
        let finalAddress = deliveryAddress.isEmpty
            ? (authViewModel.currentUser?.adress ?? "")
            : deliveryAddress

        cartViewModel.order.payment = paymentMethods[paymentIndex]
        cartViewModel.order.comment = comment
        cartViewModel.order.address = finalAddress
        cartViewModel.placeOrder(userAddress: finalAddress)
        showOrderSuccess = true
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    @Binding var item: OrderItem
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { item.included.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(item.included ? Color.orange : Color.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 26, height: 26)
                    if item.included {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.orange)
                            .frame(width: 18, height: 18)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())

            // Emoji
            //Text(item.dish.imageName)
            //.font(.title2)

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(item.dish.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .strikethrough(!item.included, color: .gray)
                    .foregroundColor(item.included ? .primary : .secondary)
                Text(String(format: "%.2f BYN", item.dish.price))
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            Spacer()

            // Delete
            //Button(action: onDelete) {
            //    Image(systemName: "trash")
            //        .foregroundColor(.red.opacity(0.7))
            //    .padding(8)
            //        .background(Color.red.opacity(0.08))
            //        .clipShape(Circle())
            //}
            //.buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .opacity(item.included ? 1.0 : 0.6)
    }
}
