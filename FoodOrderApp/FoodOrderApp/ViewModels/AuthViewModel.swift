import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""

    // MARK: - Validation
    func validateLogin(login: String, password: String) -> String? {
        if login.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Логин не может быть пустым"
        }
        if login.count < 3 {
            return "Логин должен содержать минимум 3 символа"
        }
        if password.isEmpty {
            return "Пароль не может быть пустым"
        }
        if password.count < 4 {
            return "Пароль должен содержать минимум 4 символа"
        }
        return nil
    }

    func validateSignup(login: String, password: String, address: String) -> String? {
        if let err = validateLogin(login: login, password: password) {
            return err
        }
        if address.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Адрес не может быть пустым"
        }
        if address.count < 5 {
            return "Введите корректный адрес доставки"
        }
        return nil
    }

    // MARK: - Actions
    func login(login: String, password: String) {
        if let err = validateLogin(login: login, password: password) {
            errorMessage = err; return
        }
        guard let user = DatabaseManager.shared.loginUser(login: login.trimmingCharacters(in: .whitespaces), pass: password) else {
            errorMessage = "Неверный логин или пароль"
            return
        }
        currentUser = user
        isLoggedIn = true
        errorMessage = ""
    }

    func signup(login: String, password: String, address: String) {
        if let err = validateSignup(login: login, password: password, address: address) {
            errorMessage = err; return
        }
        let cleanLogin = login.trimmingCharacters(in: .whitespaces)
        guard let user = DatabaseManager.shared.createUser(login: cleanLogin, pass: password, adress: address) else {
            errorMessage = "Пользователь с таким логином уже существует"
            return
        }
        currentUser = user
        isLoggedIn = true
        errorMessage = ""
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
        errorMessage = ""
    }
}
