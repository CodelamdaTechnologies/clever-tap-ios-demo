//
//  LocationManager.swift
//  clevertap-ios-demo
//
//  Created by user on 22/05/25.
//

import CoreLocation
import CleverTapSDK

protocol LocationManagerDelegate: AnyObject {
    func locationDidUpdate(location: CLLocation, locationName: String)
    func locationDidFail(error: Error)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    weak var delegate: LocationManagerDelegate?
    
    var currentLocation: CLLocation?
    var currentLocationName: String = "Unknown"
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update only if moved 100 meters
    }
    
    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("Location access denied")
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func startLocationUpdates() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Reverse geocode to get location name
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                self.updateCleverTapLocation(latitude: latitude, longitude: longitude, locationName: "Unknown")
                return
            }
            
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""
                
                var locationComponents: [String] = []
                if !city.isEmpty { locationComponents.append(city) }
                if !state.isEmpty { locationComponents.append(state) }
                if !country.isEmpty { locationComponents.append(country) }
                
                let locationName = locationComponents.joined(separator: ", ")
                self.currentLocationName = locationName.isEmpty ? "Unknown" : locationName
                
                // Update CleverTap profile
                self.updateCleverTapLocation(latitude: latitude, longitude: longitude, locationName: self.currentLocationName)
                
                // Update UserDefaults
                self.updateUserDefaultsLocation(city: city, state: state, country: country, locationName: self.currentLocationName)
                
                // Notify delegate
                self.delegate?.locationDidUpdate(location: location, locationName: self.currentLocationName)
            }
        }
        
        // Stop updating after getting location (for battery optimization)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        delegate?.locationDidFail(error: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            break
        case .denied, .restricted:
            print("Location access denied")
            updateCleverTapLocationPermission(granted: false)
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
            updateCleverTapLocationPermission(granted: true)
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    // MARK: - Private Methods
    
    private func updateCleverTapLocation(latitude: Double, longitude: Double, locationName: String) {
        let locationProfile: [String: Any] = [
            "Latitude": latitude,
            "Longitude": longitude,
            "Location": locationName,
            "Location_Updated": Date(),
            "Location_Permission": "granted"
        ]
        
        CleverTap.sharedInstance()?.profilePush(locationProfile)
        
        // Record location event
        CleverTap.sharedInstance()?.recordEvent("Location_Updated", withProps: [
            "latitude": latitude,
            "longitude": longitude,
            "location_name": locationName,
            "update_timestamp": Date()
        ])
    }
    
    private func updateCleverTapLocationPermission(granted: Bool) {
        CleverTap.sharedInstance()?.profilePush([
            "Location_Permission": granted ? "granted" : "denied"
        ])
        
        CleverTap.sharedInstance()?.recordEvent("Location_Permission_Changed", withProps: [
            "permission_status": granted ? "granted" : "denied",
            "timestamp": Date()
        ])
    }
    
    private func updateUserDefaultsLocation(city: String, state: String, country: String, locationName: String) {
        UserDefaults.standard.set(city, forKey: "userCity")
        UserDefaults.standard.set(state, forKey: "userState")
        UserDefaults.standard.set(country, forKey: "userCountry")
        UserDefaults.standard.set(locationName, forKey: "userLocationName")
        UserDefaults.standard.set(Date(), forKey: "locationLastUpdated")
    }
}
