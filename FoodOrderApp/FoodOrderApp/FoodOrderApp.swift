import SwiftUI

@main
struct FoodOrderApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var cartViewModel = CartViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(cartViewModel)
                .onAppear {
                    DatabaseManager.shared.setupDatabase()
                }
        }
    }
}
