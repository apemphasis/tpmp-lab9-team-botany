import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedSegment: Int = 0  // 0 = login, 1 = signup
    @State private var login: String = ""
    @State private var password: String = ""
    @State private var address: String = ""
    @State private var showPassword: Bool = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.orange.opacity(0.15), Color.white],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("🍕")
                            .font(.system(size: 64))
                            .padding(.top, 60)
                        Text("FoodOrder")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Доставка еды в Минске")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 40)

                    // Card
                    VStack(spacing: 24) {
                        // Segmented control
                        Picker("Режим", selection: $selectedSegment) {
                            Text("Вход").tag(0)
                            Text("Регистрация").tag(1)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedSegment) { _ in
                            authViewModel.errorMessage = ""
                            login = ""; password = ""; address = ""
                        }
                        .accessibilityIdentifier("authSegmentedControl")

                        // Fields
                        VStack(spacing: 16) {
                            AuthTextField(
                                title: "Логин",
                                placeholder: "Введите логин",
                                text: $login,
                                icon: "person.fill",
                                accessibilityId: "loginTextField"
                            )

                            AuthSecureField(
                                title: "Пароль",
                                placeholder: "Введите пароль",
                                text: $password,
                                showPassword: $showPassword,
                                accessibilityId: "passwordTextField"
                            )

                            if selectedSegment == 1 {
                                AuthTextField(
                                    title: "Адрес доставки",
                                    placeholder: "ул. Примерная, д. 1",
                                    text: $address,
                                    icon: "location.fill",
                                    accessibilityId: "addressTextField"
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }

                        // Error
                        if !authViewModel.errorMessage.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(authViewModel.errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(8)
                            .transition(.scale.combined(with: .opacity))
                        }

                        // Action button
                        Button(action: handleAction) {
                            Text(selectedSegment == 0 ? "Войти" : "Зарегистрироваться")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color.orange, Color.red.opacity(0.8)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .cornerRadius(14)
                                .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .accessibilityIdentifier("authButton")
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedSegment)
        .animation(.easeInOut(duration: 0.25), value: authViewModel.errorMessage)
    }

    private func handleAction() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation {
            if selectedSegment == 0 {
                authViewModel.login(login: login, password: password)
            } else {
                authViewModel.signup(login: login, password: password, address: address)
            }
        }
    }
}

// MARK: - Subcomponents
struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var accessibilityId: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.orange)
                    .frame(width: 20)
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .accessibilityIdentifier(accessibilityId)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct AuthSecureField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    var accessibilityId: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.orange)
                    .frame(width: 20)
                if showPassword {
                    TextField(placeholder, text: $text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .accessibilityIdentifier(accessibilityId)
                } else {
                    SecureField(placeholder, text: $text)
                        .accessibilityIdentifier(accessibilityId)
                }
                Button(action: { showPassword.toggle() }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}
