import Foundation
import Combine

class CartViewModel: ObservableObject {
    @Published var order: Order = Order()

    func addDish(_ dish: Dish) {
        order.addDish(dish)
    }

    func placeOrder(userAddress: String) {
        if order.address.isEmpty {
            order.address = userAddress
        }
        print(order.toString())
        order.reset()
        objectWillChange.send()
    }

    var itemCount: Int {
        order.items.filter { $0.included }.count
    }
}
