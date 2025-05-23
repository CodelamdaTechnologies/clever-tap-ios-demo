//
//  UpdateProfileViewController.swift
//  clevertap-ios-demo
//
//  Created by user on 21/05/25.
//

import UIKit
import CleverTapSDK
import CoreLocation

protocol UpdateProfileDelegate: AnyObject {
    func profileDidUpdate()
}

class UpdateProfileViewController: UIViewController, CLLocationManagerDelegate {
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
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
    private let occupationField = UITextField()
    private let interestsField = UITextField()
    
    // Buttons
    private let updateButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    // Location Manager
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    // Delegate
    weak var delegate: UpdateProfileDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupUI()
        setupConstraints()
        loadUserData()
        
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        
        // Record event
        CleverTap.sharedInstance()?.recordEvent("Profile_Update_Screen_Viewed", withProps: [
            "user_email": userEmail,  // CHANGED: Primary identifier
            "user_uuid": userUUID     // Keep UUID as secondary reference
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Navigation setup
        navigationItem.title = "Edit Profile"
        navigationItem.largeTitleDisplayMode = .never
        
        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Header View
        setupHeaderView()
        
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
        setupTextField(occupationField, placeholder: "Occupation", icon: "briefcase.fill")
        setupTextField(interestsField, placeholder: "Interests (comma separated)", icon: "heart.fill")
        
        // Gender Segmented Control
        setupGenderSegmentedControl()
        
        // Create form stack view
        let formStackView = UIStackView(arrangedSubviews: [
            nameField, emailField, phoneField, ageField, createGenderContainer(), cityField, occupationField, interestsField
        ])
        formStackView.axis = .vertical
        formStackView.spacing = 16
        formStackView.distribution = .fill
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        formContainerView.addSubview(formStackView)
        
        // Buttons
        setupButtons()
        
        NSLayoutConstraint.activate([
            formStackView.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 24),
            formStackView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            formStackView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            formStackView.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -24)
        ])
        
        // Keyboard handling
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        // Profile Icon
        let profileIconView = UIView()
        profileIconView.backgroundColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 0.1)
        profileIconView.layer.cornerRadius = 35
        profileIconView.translatesAutoresizingMaskIntoConstraints = false
        
        let profileIcon = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        profileIcon.tintColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        profileIcon.contentMode = .scaleAspectFit
        profileIcon.translatesAutoresizingMaskIntoConstraints = false
        
        profileIconView.addSubview(profileIcon)
        headerView.addSubview(profileIconView)
        
        // Title Label
        titleLabel.text = "Update Your Profile"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        // Subtitle Label
        subtitleLabel.text = "Keep your information up to date"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            profileIconView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            profileIconView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileIconView.widthAnchor.constraint(equalToConstant: 70),
            profileIconView.heightAnchor.constraint(equalToConstant: 70),
            
            profileIcon.centerXAnchor.constraint(equalTo: profileIconView.centerXAnchor),
            profileIcon.centerYAnchor.constraint(equalTo: profileIconView.centerYAnchor),
            profileIcon.widthAnchor.constraint(equalToConstant: 40),
            profileIcon.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: profileIconView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
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
        
        // Add focus styling
        textField.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
    }
    
    private func setupGenderSegmentedControl() {
        genderSegmentedControl.selectedSegmentIndex = 0
        genderSegmentedControl.backgroundColor = .systemBackground
        genderSegmentedControl.selectedSegmentTintColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        genderSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        genderSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        genderSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func createGenderContainer() -> UIView {
        let genderLabel = UILabel()
        genderLabel.text = "Gender"
        genderLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        genderLabel.textColor = .label
        genderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let genderContainer = UIView()
        genderContainer.backgroundColor = .systemBackground
        genderContainer.layer.cornerRadius = 12
        genderContainer.layer.borderWidth = 1
        genderContainer.layer.borderColor = UIColor.separator.cgColor
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
        
        return genderContainer
    }
    
    private func setupButtons() {
        // Update Button
        updateButton.setTitle("Update Profile", for: .normal)
        updateButton.backgroundColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        updateButton.setTitleColor(.white, for: .normal)
        updateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        updateButton.layer.cornerRadius = 12
        updateButton.layer.shadowColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 0.3).cgColor
        updateButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        updateButton.layer.shadowOpacity = 1.0
        updateButton.layer.shadowRadius = 8
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.addTarget(self, action: #selector(updateProfile), for: .touchUpInside)
        contentView.addSubview(updateButton)
        
        // Cancel Button
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.backgroundColor = .clear
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        contentView.addSubview(cancelButton)
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
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            formContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            formContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            updateButton.topAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: 32),
            updateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            updateButton.heightAnchor.constraint(equalToConstant: 56),
            
            cancelButton.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 16),
            cancelButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadUserData() {
        // Load existing user data
        nameField.text = UserDefaults.standard.string(forKey: "userName") ?? ""
        emailField.text = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        phoneField.text = UserDefaults.standard.string(forKey: "userPhone") ?? ""
        ageField.text = UserDefaults.standard.string(forKey: "userAge") ?? ""
        cityField.text = UserDefaults.standard.string(forKey: "userCity") ?? ""
        occupationField.text = UserDefaults.standard.string(forKey: "userOccupation") ?? ""
        interestsField.text = UserDefaults.standard.string(forKey: "userInterests") ?? ""
        
        // Set gender selection
        if let gender = UserDefaults.standard.string(forKey: "userGender") {
            switch gender {
            case "Male": genderSegmentedControl.selectedSegmentIndex = 0
            case "Female": genderSegmentedControl.selectedSegmentIndex = 1
            case "Other": genderSegmentedControl.selectedSegmentIndex = 2
            default: genderSegmentedControl.selectedSegmentIndex = 0
            }
        }
    }
    
    @objc private func updateProfile() {
        // Validate required fields
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let phone = phoneField.text, !phone.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all required fields (Name, Email, Phone)")
            return
        }
        
        // Show loading state
        updateButton.isEnabled = false
        updateButton.setTitle("Updating...", for: .normal)
        
        // Get previous values for tracking changes
        let previousData = [
            "name": UserDefaults.standard.string(forKey: "userName") ?? "",
            "email": UserDefaults.standard.string(forKey: "userEmail") ?? "",
            "phone": UserDefaults.standard.string(forKey: "userPhone") ?? "",
            "city": UserDefaults.standard.string(forKey: "userCity") ?? ""
        ]
        
        // Get current values
        let selectedGender = ["Male", "Female", "Other"][genderSegmentedControl.selectedSegmentIndex]
        let age = ageField.text ?? ""
        let city = cityField.text ?? ""
        let occupation = occupationField.text ?? ""
        let interests = interestsField.text ?? ""
        
        // Get user UUID
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? UUID().uuidString
        let previousEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        
        let emailChanged = previousEmail != email
        if emailChanged {
            print("⚠️ Email changed from \(previousEmail) to \(email) - Identity will be updated")
        }
        
        // Save updated data locally
        let updatedData = [
            "userName": name,
            "userEmail": email,
            "userPhone": phone,
            "userAge": age,
            "userGender": selectedGender,
            "userCity": city,
            "userOccupation": occupation,
            "userInterests": interests,
            "userUUID": userUUID
        ]
        
        for (key, value) in updatedData {
            UserDefaults.standard.set(value, forKey: key)
        }
        
        // Get device information
        let deviceInfo = getDeviceInfo()
        
        // Create comprehensive profile update for CleverTap
        var profileUpdate: [String: Any] = [
            // Updated user info
            "Identity": email,
            "Name": name,
            "Email": email,
            "Phone": phone,
            "Gender": selectedGender,
            "City": city,
            "Occupation": occupation,
            "Interests": interests,
            
            // Keep UUID for internal reference
            "Internal_UUID": userUUID,
            
            // System info updates
            "Device_Type": deviceInfo["deviceType"] ?? "iOS",
            "Device_Model": deviceInfo["deviceModel"] ?? "Unknown",
            "OS_Version": deviceInfo["osVersion"] ?? "Unknown",
            "App_Version": deviceInfo["appVersion"] ?? "1.0",
            
            // Update tracking
            "Profile_Last_Updated": Date(),
            "Profile_Update_Count": (UserDefaults.standard.integer(forKey: "profileUpdateCount") + 1),
            "Profile_Completion": calculateProfileCompletion(),
            "Email_Changed": emailChanged
        ]
        
        // Add age if provided
        if !age.isEmpty, let ageInt = Int(age) {
            profileUpdate["Age"] = ageInt
            profileUpdate["Age_Group"] = getAgeGroup(age: ageInt)
        }
        
        // Add location if available
        if let location = currentLocation {
            profileUpdate["Latitude"] = location.coordinate.latitude
            profileUpdate["Longitude"] = location.coordinate.longitude
            profileUpdate["Location_Updated"] = Date()

            let coordinate = location.coordinate
            CleverTap.sharedInstance()?.setLocation(CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }
        
        // Update CleverTap profile
        CleverTap.sharedInstance()?.profilePush(profileUpdate)
        
        // Track what changed
        var changedFields: [String] = []
        if previousData["name"] != name { changedFields.append("name") }
        if previousData["email"] != email { changedFields.append("email") }
        if previousData["phone"] != phone { changedFields.append("phone") }
        if previousData["city"] != city { changedFields.append("city") }
        
        // Record profile update event
        CleverTap.sharedInstance()?.recordEvent("Profile_Updated", withProps: [
            "user_email": email,
            "user_uuid": userUUID,
            "fields_changed": changedFields,
            "fields_changed_count": changedFields.count,
            "profile_completion": calculateProfileCompletion(),
            "update_timestamp": Date(),
            "has_location": currentLocation != nil,
            "email_changed": emailChanged,
            "previous_email": emailChanged ? previousEmail : nil ?? ""
        ])
        
        // Update profile update count
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "profileUpdateCount") + 1, forKey: "profileUpdateCount")
        
        // Inform delegate
        delegate?.profileDidUpdate()
        
        // Show success and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showSuccessAndDismiss()
        }
    }
    
    private func calculateProfileCompletion() -> Double {
        let fields = [nameField.text, emailField.text, phoneField.text, ageField.text, cityField.text, occupationField.text, interestsField.text]
        let filledFields = fields.filter { !($0?.isEmpty ?? true) }.count
        return Double(filledFields) / Double(fields.count) * 100
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
    
    private func showSuccessAndDismiss() {
        updateButton.isEnabled = true
        updateButton.setTitle("Update Profile", for: .normal)
        
        let alert = UIAlertController(title: "Success!", message: "Your profile has been updated successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        // Record cancel event
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        CleverTap.sharedInstance()?.recordEvent("Profile_Update_Cancelled", withProps: [
            "user_email": userEmail,  // CHANGED: Primary identifier
            "user_uuid": userUUID     // Keep UUID as secondary reference
        ])
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0).cgColor
        textField.layer.borderWidth = 2
    }
    
    @objc private func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.separator.cgColor
        textField.layer.borderWidth = 1
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
            scrollView.scrollIndicatorInsets.bottom = keyboardSize.height
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
