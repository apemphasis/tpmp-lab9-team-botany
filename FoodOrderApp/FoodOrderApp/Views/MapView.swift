import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Binding var selectedAddress: String
    @Environment(\.dismiss) var dismiss

    @StateObject private var locationManager = LocationManager()
    @State private var selectedRestaurant: Restaurant? = nil
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.9045, longitude: 27.5615),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    let restaurants = Restaurant.minskRestaurants

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // Map
                Map(coordinateRegion: $region,
                    showsUserLocation: true,
                    annotationItems: restaurants) { restaurant in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: restaurant.lat,
                        longitude: restaurant.long
                    )) {
                        RestaurantPin(
                            restaurant: restaurant,
                            isSelected: selectedRestaurant?.id == restaurant.id
                        ) {
                            withAnimation(.spring()) {
                                selectedRestaurant = restaurant
                                region.center = CLLocationCoordinate2D(
                                    latitude: restaurant.lat,
                                    longitude: restaurant.long
                                )
                            }
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)

                // Bottom panel
                VStack(spacing: 12) {
                    // Selected restaurant info
                    if let r = selectedRestaurant {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Выбранный ресторан")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(r.adress)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .shadow(color: .black.opacity(0.1), radius: 6)
                    }

                    HStack(spacing: 12) {
                        // Nearest button
                        Button(action: selectNearest) {
                            HStack {
                                Image(systemName: "location.fill")
                                Text("Ближайший")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(14)
                        }
                        .accessibilityIdentifier("nearestButton")

                        // Confirm button
                        Button(action: confirmSelection) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Выбрать")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedRestaurant != nil ? Color.orange : Color.gray)
                            .cornerRadius(14)
                        }
                        .disabled(selectedRestaurant == nil)
                        .accessibilityIdentifier("confirmMapButton")
                    }
                }
                .padding(16)
                .background(
                    Color(.systemBackground)
                        .opacity(0.95)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: -5)
                )
                .padding(.horizontal, 0)
            }
            .navigationTitle("Выбор ресторана")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                            Text("Отмена")
                        }
                        .foregroundColor(.secondary)
                    }
                    .accessibilityIdentifier("cancelMapButton")
                }
            }
            .onAppear {
                locationManager.requestLocation()
            }
        }
    }

    private func selectNearest() {
        guard let userLocation = locationManager.location else {
            // No location - pick first
            withAnimation { selectedRestaurant = restaurants.first }
            return
        }

        let nearest = restaurants.min { a, b in
            let coordA = CLLocation(latitude: a.lat, longitude: a.long)
            let coordB = CLLocation(latitude: b.lat, longitude: b.long)
            return userLocation.distance(from: coordA) < userLocation.distance(from: coordB)
        }

        withAnimation(.spring()) {
            selectedRestaurant = nearest
            if let r = nearest {
                region.center = CLLocationCoordinate2D(latitude: r.lat, longitude: r.long)
            }
        }
    }

    private func confirmSelection() {
        if let r = selectedRestaurant {
            selectedAddress = r.adress
        }
        dismiss()
    }
}

// MARK: - Restaurant Pin
struct RestaurantPin: View {
    let restaurant: Restaurant
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.orange : Color.red)
                        .frame(width: isSelected ? 44 : 36, height: isSelected ? 44 : 36)
                        .shadow(color: (isSelected ? Color.orange : Color.red).opacity(0.5),
                                radius: 6, x: 0, y: 3)
                    Image(systemName: "fork.knife")
                        .font(.system(size: isSelected ? 18 : 14))
                        .foregroundColor(.white)
                }

                // Triangle
                Triangle()
                    .fill(isSelected ? Color.orange : Color.red)
                    .frame(width: 12, height: 8)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(), value: isSelected)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
