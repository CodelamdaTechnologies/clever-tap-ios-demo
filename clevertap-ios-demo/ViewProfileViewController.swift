//
//  ViewProfileViewController.swift
//  clevertap-ios-demo
//
//  Created by user on 21/05/25.
//

import UIKit
import CleverTapSDK

class ViewProfileViewController: UIViewController {
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let profileImageView = UIView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let profileDetailsContainer = UIView()
    private let systemInfoContainer = UIView()
    private let closeButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)
    
    // Profile data
    private var profileData: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadProfileData()

        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        
        // Record profile view event
        CleverTap.sharedInstance()?.recordEvent("Profile_Details_Viewed", withProps: [
            "view_timestamp": Date(),
            "user_email": userEmail,  // CHANGED: Primary identifier
            "user_uuid": userUUID     // Keep UUID as secondary reference
        ])
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Navigation setup
        navigationItem.title = "Profile"
        navigationItem.largeTitleDisplayMode = .never
        
        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        // Edit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editButtonTapped)
        )
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        
        // ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup header
        setupHeaderView()
        
        // Setup profile details container
        setupProfileDetailsContainer()
        
        // Setup system info container
        setupSystemInfoContainer()
        
        // Setup action buttons
        setupActionButtons()
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 0.1)
        headerView.layer.cornerRadius = 20
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        // Profile Image View (circular avatar)
        profileImageView.backgroundColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.shadowColor = UIColor.black.cgColor
        profileImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        profileImageView.layer.shadowOpacity = 0.1
        profileImageView.layer.shadowRadius = 8
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let profileIcon = UIImageView(image: UIImage(systemName: "person.fill"))
        profileIcon.tintColor = .white
        profileIcon.contentMode = .scaleAspectFit
        profileIcon.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.addSubview(profileIcon)
        
        headerView.addSubview(profileImageView)
        
        // Name Label
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(nameLabel)
        
        // Email Label
        emailLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        emailLabel.textColor = .secondaryLabel
        emailLabel.textAlignment = .center
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(emailLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            profileIcon.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            profileIcon.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            profileIcon.widthAnchor.constraint(equalToConstant: 50),
            profileIcon.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            emailLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupProfileDetailsContainer() {
        profileDetailsContainer.backgroundColor = .secondarySystemBackground
        profileDetailsContainer.layer.cornerRadius = 16
        profileDetailsContainer.layer.shadowColor = UIColor.black.cgColor
        profileDetailsContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        profileDetailsContainer.layer.shadowOpacity = 0.1
        profileDetailsContainer.layer.shadowRadius = 8
        profileDetailsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(profileDetailsContainer)
        
        // Title for profile details
        let profileTitle = UILabel()
        profileTitle.text = "Personal Information"
        profileTitle.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        profileTitle.textColor = .label
        profileTitle.translatesAutoresizingMaskIntoConstraints = false
        profileDetailsContainer.addSubview(profileTitle)
        
        // Profile details stack view
        let profileStackView = UIStackView()
        profileStackView.axis = .vertical
        profileStackView.spacing = 16
        profileStackView.distribution = .fill
        profileStackView.translatesAutoresizingMaskIntoConstraints = false
        profileDetailsContainer.addSubview(profileStackView)
        
        // Profile info rows
        let profileInfoRows = [
            ("phone.fill", "Phone", "userPhone"),
            ("calendar", "Age", "userAge"),
            ("person.2.fill", "Gender", "userGender"),
            ("location.fill", "City", "userCity"),
            ("briefcase.fill", "Occupation", "userOccupation"),
            ("heart.fill", "Interests", "userInterests")
        ]
        
        for (icon, title, key) in profileInfoRows {
            let infoRow = createInfoRow(icon: icon, title: title, key: key)
            profileStackView.addArrangedSubview(infoRow)
        }
        
        NSLayoutConstraint.activate([
            profileTitle.topAnchor.constraint(equalTo: profileDetailsContainer.topAnchor, constant: 20),
            profileTitle.leadingAnchor.constraint(equalTo: profileDetailsContainer.leadingAnchor, constant: 20),
            profileTitle.trailingAnchor.constraint(equalTo: profileDetailsContainer.trailingAnchor, constant: -20),
            
            profileStackView.topAnchor.constraint(equalTo: profileTitle.bottomAnchor, constant: 16),
            profileStackView.leadingAnchor.constraint(equalTo: profileDetailsContainer.leadingAnchor, constant: 20),
            profileStackView.trailingAnchor.constraint(equalTo: profileDetailsContainer.trailingAnchor, constant: -20),
            profileStackView.bottomAnchor.constraint(equalTo: profileDetailsContainer.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupSystemInfoContainer() {
        systemInfoContainer.backgroundColor = .secondarySystemBackground
        systemInfoContainer.layer.cornerRadius = 16
        systemInfoContainer.layer.shadowColor = UIColor.black.cgColor
        systemInfoContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        systemInfoContainer.layer.shadowOpacity = 0.1
        systemInfoContainer.layer.shadowRadius = 8
        systemInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(systemInfoContainer)
        
        // Title for system info
        let systemTitle = UILabel()
        systemTitle.text = "System Information"
        systemTitle.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        systemTitle.textColor = .label
        systemTitle.translatesAutoresizingMaskIntoConstraints = false
        systemInfoContainer.addSubview(systemTitle)
        
        // System info stack view
        let systemStackView = UIStackView()
        systemStackView.axis = .vertical
        systemStackView.spacing = 16
        systemStackView.distribution = .fill
        systemStackView.translatesAutoresizingMaskIntoConstraints = false
        systemInfoContainer.addSubview(systemStackView)
        
        // System info rows
        let systemInfoRows = [
            ("person.text.rectangle", "User ID", "userUUID"),
            ("iphone", "Device", "device_info"),
            ("gear", "App Version", "app_version"),
            ("location.circle", "Location", "location_info"),
            ("clock", "Member Since", "signup_date")
        ]
        
        for (icon, title, key) in systemInfoRows {
            let infoRow = createSystemInfoRow(icon: icon, title: title, key: key)
            systemStackView.addArrangedSubview(infoRow)
        }
        
        NSLayoutConstraint.activate([
            systemTitle.topAnchor.constraint(equalTo: systemInfoContainer.topAnchor, constant: 20),
            systemTitle.leadingAnchor.constraint(equalTo: systemInfoContainer.leadingAnchor, constant: 20),
            systemTitle.trailingAnchor.constraint(equalTo: systemInfoContainer.trailingAnchor, constant: -20),
            
            systemStackView.topAnchor.constraint(equalTo: systemTitle.bottomAnchor, constant: 16),
            systemStackView.leadingAnchor.constraint(equalTo: systemInfoContainer.leadingAnchor, constant: 20),
            systemStackView.trailingAnchor.constraint(equalTo: systemInfoContainer.trailingAnchor, constant: -20),
            systemStackView.bottomAnchor.constraint(equalTo: systemInfoContainer.bottomAnchor, constant: -20)
        ])
    }
    
    private func createInfoRow(icon: String, title: String, key: String) -> UIView {
        let rowView = UIView()
        rowView.backgroundColor = .systemBackground
        rowView.layer.cornerRadius = 12
        rowView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set value based on key
        let value = UserDefaults.standard.string(forKey: key) ?? "Not provided"
        valueLabel.text = value.isEmpty ? "Not provided" : value
        
        rowView.addSubview(iconImageView)
        rowView.addSubview(titleLabel)
        rowView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            rowView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            iconImageView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: rowView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: rowView.bottomAnchor, constant: -12)
        ])
        
        return rowView
    }
    
    private func createSystemInfoRow(icon: String, title: String, key: String) -> UIView {
        let rowView = UIView()
        rowView.backgroundColor = .systemBackground
        rowView.layer.cornerRadius = 12
        rowView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set value based on key
        var value = ""
        switch key {
        case "userUUID":
            let uuid = UserDefaults.standard.string(forKey: "userUUID") ?? "Not available"
            value = String(uuid.prefix(8)) + "..." // Show first 8 characters
        case "device_info":
            let device = UIDevice.current
            value = "\(device.model) - iOS \(device.systemVersion)"
        case "app_version":
            value = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        case "location_info":
            // This would be populated from CleverTap profile or location services
            value = "Location permissions granted"
        case "signup_date":
            // This would ideally come from CleverTap or stored signup date
            value = "Recently joined"
        default:
            value = "Not available"
        }
        
        valueLabel.text = value
        
        rowView.addSubview(iconImageView)
        rowView.addSubview(titleLabel)
        rowView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            rowView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            iconImageView.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: rowView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
            
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: rowView.bottomAnchor, constant: -12)
        ])
        
        return rowView
    }
    
    private func setupActionButtons() {
        // Edit Button
        editButton.setTitle("Edit Profile", for: .normal)
        editButton.backgroundColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        editButton.setTitleColor(.white, for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        editButton.layer.cornerRadius = 12
        editButton.layer.shadowColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 0.3).cgColor
        editButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        editButton.layer.shadowOpacity = 1.0
        editButton.layer.shadowRadius = 8
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        contentView.addSubview(editButton)
        
        // Close Button
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        closeButton.backgroundColor = .clear
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        contentView.addSubview(closeButton)
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
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            profileDetailsContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            profileDetailsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileDetailsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            systemInfoContainer.topAnchor.constraint(equalTo: profileDetailsContainer.bottomAnchor, constant: 24),
            systemInfoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            systemInfoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            editButton.topAnchor.constraint(equalTo: systemInfoContainer.bottomAnchor, constant: 32),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            editButton.heightAnchor.constraint(equalToConstant: 56),
            
            closeButton.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadProfileData() {
        // Load basic profile info
        let name = UserDefaults.standard.string(forKey: "userName") ?? "Anonymous User"
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? "No email provided"
        
        nameLabel.text = name
        emailLabel.text = email
        
        // Get CleverTap ID if available
        let cleverTapID = CleverTap.sharedInstance()?.profileGetID() ?? "Not available"
        profileData["cleverTapID"] = cleverTapID
        
        // Record profile completion for analytics
        let profileCompletion = calculateProfileCompletion()
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        CleverTap.sharedInstance()?.recordEvent("Profile_Viewed", withProps: [
            "profile_completion": profileCompletion,
            "has_name": !name.isEmpty && name != "Anonymous User",
            "has_email": !email.isEmpty && email != "No email provided",
            "user_email": userEmail,  // CHANGED: Primary identifier
            "user_uuid": userUUID
        ])
    }
    
    private func calculateProfileCompletion() -> Double {
        let fields = ["userName", "userEmail", "userPhone", "userAge", "userGender", "userCity", "userOccupation", "userInterests"]
        let filledFields = fields.filter {
            let value = UserDefaults.standard.string(forKey: $0)
            return !(value?.isEmpty ?? true)
        }.count
        return Double(filledFields) / Double(fields.count) * 100
    }
    
    @objc private func editButtonTapped() {
        // Record edit button tap
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        
        CleverTap.sharedInstance()?.recordEvent("Profile_Edit_Button_Tapped", withProps: [
            "user_email": userEmail,  // CHANGED: Primary identifier
            "user_uuid": userUUID     // Keep UUID as secondary reference
        ])
        
        let updateVC = UpdateProfileViewController()
        updateVC.delegate = self
        let navController = UINavigationController(rootViewController: updateVC)
        navController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        present(navController, animated: true)
    }
    
    @objc private func closeButtonTapped() {
        // Record close event
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        
        CleverTap.sharedInstance()?.recordEvent("Profile_View_Closed", withProps: [
            "user_email": userEmail,  // CHANGED: Primary identifier
            "user_uuid": userUUID     // Keep UUID as secondary reference
        ])
        dismiss(animated: true)
    }
}

// MARK: - UpdateProfileDelegate

extension ViewProfileViewController: UpdateProfileDelegate {
    func profileDidUpdate() {
        // Reload profile data when updated
        loadProfileData()
        
        // Record profile update completion
        CleverTap.sharedInstance()?.recordEvent("Profile_Updated_From_View", withProps: [
            "updated_from": "profile_view_screen",
            "profile_completion": calculateProfileCompletion()
        ])
    }
}
