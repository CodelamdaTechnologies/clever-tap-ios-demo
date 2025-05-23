//
//  AuthViewController.swift
//  clevertap-ios-demo
//
//  Created by user on 21/05/25.
//

import UIKit
import CleverTapSDK
import CoreLocation

class AuthViewController: UIViewController, CLLocationManagerDelegate {
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let formContainerView = UIView()
    
    // Input Fields
    private let nameField = UITextField()
    private let emailField = UITextField()
    private let phoneField = UITextField()
    private let ageField = UITextField()
    private let genderSegmentedControl = UISegmentedControl(items: ["Male", "Female", "Other"])
    private let cityField = UITextField()
    private let signupButton = UIButton(type: .system)
    
    // Location Manager
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupUI()
        setupConstraints()
        
        // Record page view event
        CleverTap.sharedInstance()?.recordEvent("Signup_Page_Viewed")
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Title Label
        titleLabel.text = "Welcome!"
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Subtitle Label
        subtitleLabel.text = "Create your account to get started"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Add title and subtitle to content view
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        // Form Container
        formContainerView.backgroundColor = .secondarySystemBackground
        formContainerView.layer.cornerRadius = 16
        formContainerView.layer.shadowColor = UIColor.black.cgColor
        formContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        formContainerView.layer.shadowOpacity = 0.1
        formContainerView.layer.shadowRadius = 8
        formContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(formContainerView)
        
        // Setup Input Fields
        setupTextField(nameField, placeholder: "Full Name", icon: "person.fill")
        setupTextField(emailField, placeholder: "Email Address", keyboardType: .emailAddress, icon: "envelope.fill")
        setupTextField(phoneField, placeholder: "Phone Number", keyboardType: .phonePad, icon: "phone.fill")
        setupTextField(ageField, placeholder: "Age", keyboardType: .numberPad, icon: "calendar")
        setupTextField(cityField, placeholder: "City", icon: "location.fill")
        
        // Gender Segmented Control
        genderSegmentedControl.selectedSegmentIndex = 0
        genderSegmentedControl.backgroundColor = .systemBackground
        genderSegmentedControl.selectedSegmentTintColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        genderSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        genderSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Create gender container
        let genderLabel = UILabel()
        genderLabel.text = "Gender"
        genderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        genderLabel.textColor = .label
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let genderContainer = UIView()
        genderContainer.backgroundColor = .systemBackground
        genderContainer.layer.cornerRadius = 12
        genderContainer.translatesAutoresizingMaskIntoConstraints = false
        genderContainer.addSubview(genderLabel)
        genderContainer.addSubview(genderSegmentedControl)
        
        NSLayoutConstraint.activate([
            genderLabel.topAnchor.constraint(equalTo: genderContainer.topAnchor, constant: 12),
            genderLabel.leadingAnchor.constraint(equalTo: genderContainer.leadingAnchor, constant: 16),
            
            genderSegmentedControl.topAnchor.constraint(equalTo: genderLabel.bottomAnchor, constant: 8),
            genderSegmentedControl.leadingAnchor.constraint(equalTo: genderContainer.leadingAnchor, constant: 16),
            genderSegmentedControl.trailingAnchor.constraint(equalTo: genderContainer.trailingAnchor, constant: -16),
            genderSegmentedControl.bottomAnchor.constraint(equalTo: genderContainer.bottomAnchor, constant: -12),
            genderSegmentedControl.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // Stack View for form fields
        let formStackView = UIStackView(arrangedSubviews: [
            nameField, emailField, phoneField, ageField, genderContainer, cityField
        ])
        formStackView.axis = .vertical
        formStackView.spacing = 16
        formStackView.distribution = .fill
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        formContainerView.addSubview(formStackView)
        
        // Signup Button
        signupButton.setTitle("Create Account", for: .normal)
        signupButton.backgroundColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        signupButton.layer.cornerRadius = 12
        signupButton.layer.shadowColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 0.3).cgColor
        signupButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        signupButton.layer.shadowOpacity = 1.0
        signupButton.layer.shadowRadius = 8
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.addTarget(self, action: #selector(signupButtonTapped), for: .touchUpInside)
        contentView.addSubview(signupButton)
        
        NSLayoutConstraint.activate([
            formStackView.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 24),
            formStackView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            formStackView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            formStackView.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -24)
        ])
        
        // Handle keyboard dismissal
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupTextField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType = .default, icon: String? = nil) {
        textField.placeholder = placeholder
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.separator.cgColor
        textField.keyboardType = keyboardType
        textField.autocorrectionType = .no
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Add icon if provided
        if let iconName = icon {
            let iconImageView = UIImageView(image: UIImage(systemName: iconName))
            iconImageView.tintColor = .secondaryLabel
            iconImageView.contentMode = .scaleAspectFit
            
            let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            iconImageView.frame = CGRect(x: 12, y: 0, width: 16, height: 20)
            iconContainer.addSubview(iconImageView)
            
            textField.leftView = iconContainer
            textField.leftViewMode = .always
        } else {
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            textField.leftViewMode = .always
        }
        
        textField.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            formContainerView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            formContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            signupButton.topAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: 32),
            signupButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            signupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            signupButton.heightAnchor.constraint(equalToConstant: 56),
            signupButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func signupButtonTapped() {
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let phone = phoneField.text, !phone.isEmpty,
              let ageText = ageField.text, !ageText.isEmpty,
              let age = Int(ageText),
              let city = cityField.text, !city.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all required fields")
            return
        }
        
        // Generate UUID for internal tracking but use email as CleverTap identity
        let userUUID = UUID().uuidString
        let selectedGender = ["Male", "Female", "Other"][genderSegmentedControl.selectedSegmentIndex]
        
        // Get device information
        let deviceInfo = getDeviceInfo()
        
        // Save user data locally
        let userData = [
            "userName": name,
            "userEmail": email,
            "userPhone": phone,
            "userAge": ageText,
            "userGender": selectedGender,
            "userCity": city,
            "userUUID": userUUID
        ]
        
        for (key, value) in userData {
            UserDefaults.standard.set(value, forKey: key)
        }
        
        // Set session start time for logout tracking
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "sessionStartTime")
        
        // Set first app open date if not already set
        if UserDefaults.standard.object(forKey: "lastAppOpenDate") == nil {
            UserDefaults.standard.set(Date(), forKey: "lastAppOpenDate")
        }
        
        // Create comprehensive user profile for CleverTap - Using EMAIL as Identity
        var userProfile: [String: Any] = [
            // Primary Identity - Using EMAIL instead of UUID
            "Identity": email,  // CHANGED: Using email as the main identity
            "Name": name,
            "Email": email,
            "Phone": phone,
            "Age": age,
            "Gender": selectedGender,
            "City": city,
            
            // Keep UUID for internal reference
            "Internal_UUID": userUUID,
            
            // Device & System Info
            "Device_Type": deviceInfo["deviceType"] ?? "Unknown",
            "Device_Model": deviceInfo["deviceModel"] ?? "Unknown",
            "OS_Version": deviceInfo["osVersion"] ?? "Unknown",
            "App_Version": deviceInfo["appVersion"] ?? "1.0",
            
            // Tracking & Engagement
            "Signup_Date": Date(),
            "Signup_Method": "app_form",
            "First_Launch": true,
            "User_Type": "registered",
            "Registration_Status": "completed",
            
            // Marketing & Analytics
            "Customer_Segment": "new_user",
            "Onboarding_Complete": false,
            "Push_Enabled": false,
            "Email_Subscribed": true
        ]
        
        // Add location data if available
        if let location = currentLocation {
            userProfile["Latitude"] = location.coordinate.latitude
            userProfile["Longitude"] = location.coordinate.longitude
            userProfile["Location_Permission"] = "granted"
            
            let coordinate = location.coordinate
            CleverTap.sharedInstance()?.setLocation(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        } else {
            userProfile["Location_Permission"] = "denied"
        }
        
        // Register user with CleverTap using EMAIL as identity
        CleverTap.sharedInstance()?.onUserLogin(userProfile)
        
        // Record signup events with email as user identifier
        CleverTap.sharedInstance()?.recordEvent("User_Signed_Up", withProps: [
            "signup_method": "app_form",
            "user_email": email,  // CHANGED: Use email instead of UUID
            "user_uuid": userUUID,  // Keep UUID as additional reference
            "completion_time": Date(),
            "form_fields_filled": 6,
            "location_shared": currentLocation != nil
        ])
        
        // Record successful registration
        CleverTap.sharedInstance()?.recordEvent("Registration_Completed", withProps: [
            "user_email": email,  // CHANGED: Use email as primary identifier
            "user_uuid": userUUID,
            "user_age_group": getAgeGroup(age: age),
            "user_gender": selectedGender,
            "signup_source": "organic"
        ])
        
        showSuccessAndNavigate()
    }
    
    private func getDeviceInfo() -> [String: String] {
        let device = UIDevice.current
        let systemVersion = device.systemVersion
        let deviceModel = device.model
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        return [
            "deviceType": "iOS",
            "deviceModel": deviceModel,
            "osVersion": systemVersion,
            "appVersion": appVersion
        ]
    }
    
    private func getAgeGroup(age: Int) -> String {
        switch age {
        case 0...17: return "under_18"
        case 18...24: return "18_24"
        case 25...34: return "25_34"
        case 35...44: return "35_44"
        case 45...54: return "45_54"
        case 55...64: return "55_64"
        default: return "65_plus"
        }
    }
    
    private func showSuccessAndNavigate() {
        let alert = UIAlertController(title: "Welcome!", message: "Your account has been created successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.navigateToDashboard()
        })
        present(alert, animated: true)
    }
    
    private func navigateToDashboard() {
        let dashboardVC = DashboardViewController()
        dashboardVC.modalPresentationStyle = .fullScreen
        present(dashboardVC, animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
}
