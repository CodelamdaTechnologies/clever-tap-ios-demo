//
//  DashboardViewController.swift
//  clevertap-ios-demo
//
//  Created by user on 21/05/25.
//

import UIKit
import CleverTapSDK

class DashboardViewController: UIViewController {
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView = UIView()
    private let welcomeLabel = UILabel()
    private let userInfoLabel = UILabel()
    private let profileImageView = UIView()
    
    // Main Content Containers
    private let quickActionsContainer = UIView()
    private let eventTrackingContainer = UIView()
    private let campaignContainer = UIView()
    private let systemInfoContainer = UIView()
    
    // Quick Action Buttons
    private let viewProfileButton = UIButton(type: .system)
    private let updateProfileButton = UIButton(type: .system)
    private let getIdButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)
    
    // Event Tracking Actions
    private let eventActions = [
        ("cart.fill", "Product Viewed", "Product_Viewed"),
        ("list.bullet", "Category Viewed", "Category_Viewed"),
        ("cart.badge.plus", "Cart Viewed", "Cart_Viewed"),
        ("creditcard.fill", "Checkout Started", "Checkout_Started"),
        ("person.crop.circle.badge.plus", "Payment Info Added", "Payment_Info_Added"),
        ("heart.fill", "Wishlist Added", "Wishlist_Product_Added"),
        ("magnifyingglass", "Search Performed", "Search_Performed"),
        ("star.fill", "Product Rated", "Product_Rated")
    ]
    
    // Campaign Actions
    private let campaignActions = [
        ("bag.fill", "Purchase Completed", "Purchase_Completed"),
        ("shippingbox.fill", "Order Delivered", "Order_Delivered"),
        ("gift.fill", "First Purchase", "First_Purchase")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        updateUserInfo()
        
        // Record dashboard view event
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        
        CleverTap.sharedInstance()?.recordEvent("Dashboard_Viewed", withProps: [
            "user_email": userEmail,  // CHANGED: Primary identifier
            "user_uuid": userUUID,    // Keep UUID as secondary reference
            "session_start": Date(),
            "platform": "iOS"
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserInfo()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .automatic
        view.addSubview(scrollView)
        
        // ContentView
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup all components
        setupHeaderView()
        setupQuickActionsContainer()
        setupEventTrackingContainer()
        setupCampaignContainer()
        setupSystemInfoContainer()
    }
    
    private func setupHeaderView() {
        headerView.backgroundColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        headerView.layer.cornerRadius = 20
        headerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        headerView.layer.shadowOpacity = 0.1
        headerView.layer.shadowRadius = 8
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        // Profile Image View
        profileImageView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        profileImageView.layer.cornerRadius = 35
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let profileIcon = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
        profileIcon.tintColor = .white
        profileIcon.contentMode = .scaleAspectFit
        profileIcon.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.addSubview(profileIcon)
        
        headerView.addSubview(profileImageView)
        
        // Welcome Label
        welcomeLabel.text = "Welcome back!"
        welcomeLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        welcomeLabel.textColor = .white
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(welcomeLabel)
        
        // User Info Label
        userInfoLabel.text = "Loading user information..."
        userInfoLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        userInfoLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        userInfoLabel.numberOfLines = 0
        userInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(userInfoLabel)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            
            profileIcon.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            profileIcon.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            profileIcon.widthAnchor.constraint(equalToConstant: 40),
            profileIcon.heightAnchor.constraint(equalToConstant: 40),
            
            welcomeLabel.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 30),
            welcomeLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            welcomeLabel.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -16),
            
            userInfoLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            userInfoLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            userInfoLabel.trailingAnchor.constraint(equalTo: profileImageView.leadingAnchor, constant: -16),
            userInfoLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupQuickActionsContainer() {
        quickActionsContainer.backgroundColor = .secondarySystemBackground
        quickActionsContainer.layer.cornerRadius = 16
        quickActionsContainer.layer.shadowColor = UIColor.black.cgColor
        quickActionsContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        quickActionsContainer.layer.shadowOpacity = 0.1
        quickActionsContainer.layer.shadowRadius = 8
        quickActionsContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quickActionsContainer)
        
        let titleLabel = createSectionTitle("Quick Actions")
        quickActionsContainer.addSubview(titleLabel)
        
        // Setup quick action buttons
        setupQuickActionButton(viewProfileButton, title: "View Profile", icon: "person.crop.circle", color: .systemBlue)
        setupQuickActionButton(updateProfileButton, title: "Update Profile", icon: "person.crop.circle.badge.plus", color: UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0))
        setupQuickActionButton(getIdButton, title: "Get CleverTap ID", icon: "doc.text", color: .systemOrange)
        setupQuickActionButton(logoutButton, title: "Logout", icon: "rectangle.portrait.and.arrow.right", color: .systemRed)
        
        // Add button actions
        viewProfileButton.addTarget(self, action: #selector(viewProfileTapped), for: .touchUpInside)
        updateProfileButton.addTarget(self, action: #selector(updateProfileTapped), for: .touchUpInside)
        getIdButton.addTarget(self, action: #selector(getCleverTapIDTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        // Create button grid
        let topRow = UIStackView(arrangedSubviews: [viewProfileButton, updateProfileButton])
        topRow.axis = .horizontal
        topRow.distribution = .fillEqually
        topRow.spacing = 12
        topRow.translatesAutoresizingMaskIntoConstraints = false
        
        let bottomRow = UIStackView(arrangedSubviews: [getIdButton, logoutButton])
        bottomRow.axis = .horizontal
        bottomRow.distribution = .fillEqually
        bottomRow.spacing = 12
        bottomRow.translatesAutoresizingMaskIntoConstraints = false
        
        quickActionsContainer.addSubview(topRow)
        quickActionsContainer.addSubview(bottomRow)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: quickActionsContainer.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: quickActionsContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: quickActionsContainer.trailingAnchor, constant: -20),
            
            topRow.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            topRow.leadingAnchor.constraint(equalTo: quickActionsContainer.leadingAnchor, constant: 20),
            topRow.trailingAnchor.constraint(equalTo: quickActionsContainer.trailingAnchor, constant: -20),
            topRow.heightAnchor.constraint(equalToConstant: 80),
            
            bottomRow.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 12),
            bottomRow.leadingAnchor.constraint(equalTo: quickActionsContainer.leadingAnchor, constant: 20),
            bottomRow.trailingAnchor.constraint(equalTo: quickActionsContainer.trailingAnchor, constant: -20),
            bottomRow.heightAnchor.constraint(equalToConstant: 80),
            bottomRow.bottomAnchor.constraint(equalTo: quickActionsContainer.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupEventTrackingContainer() {
        eventTrackingContainer.backgroundColor = .secondarySystemBackground
        eventTrackingContainer.layer.cornerRadius = 16
        eventTrackingContainer.layer.shadowColor = UIColor.black.cgColor
        eventTrackingContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        eventTrackingContainer.layer.shadowOpacity = 0.1
        eventTrackingContainer.layer.shadowRadius = 8
        eventTrackingContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eventTrackingContainer)
        
        let titleLabel = createSectionTitle("Event Tracking")
        eventTrackingContainer.addSubview(titleLabel)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        eventTrackingContainer.addSubview(stackView)
        
        // Create event tracking buttons
        for (icon, title, eventName) in eventActions {
            let button = createEventButton(icon: icon, title: title, eventName: eventName)
            stackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: eventTrackingContainer.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: eventTrackingContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: eventTrackingContainer.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: eventTrackingContainer.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: eventTrackingContainer.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: eventTrackingContainer.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupCampaignContainer() {
        campaignContainer.backgroundColor = .secondarySystemBackground
        campaignContainer.layer.cornerRadius = 16
        campaignContainer.layer.shadowColor = UIColor.black.cgColor
        campaignContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        campaignContainer.layer.shadowOpacity = 0.1
        campaignContainer.layer.shadowRadius = 8
        campaignContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(campaignContainer)
        
        let titleLabel = createSectionTitle("Campaign Triggers")
        campaignContainer.addSubview(titleLabel)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        campaignContainer.addSubview(stackView)
        
        // Create campaign buttons
        for (icon, title, eventName) in campaignActions {
            let button = createCampaignButton(icon: icon, title: title, eventName: eventName)
            stackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: campaignContainer.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: campaignContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: campaignContainer.trailingAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: campaignContainer.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: campaignContainer.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: campaignContainer.bottomAnchor, constant: -20)
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
        
        let titleLabel = createSectionTitle("System Information")
        systemInfoContainer.addSubview(titleLabel)
        
        // Device info
        let device = UIDevice.current
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let cleverTapID = CleverTap.sharedInstance()?.profileGetID() ?? "Not available"
        
        let deviceInfoLabel = UILabel()
        deviceInfoLabel.text = "Device: \(device.model)\nOS: iOS \(device.systemVersion)\nApp Version: \(appVersion)\nCleverTap ID: \(String(cleverTapID.prefix(12)))..."
        deviceInfoLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        deviceInfoLabel.textColor = .secondaryLabel
        deviceInfoLabel.numberOfLines = 0
        deviceInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        systemInfoContainer.addSubview(deviceInfoLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: systemInfoContainer.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: systemInfoContainer.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: systemInfoContainer.trailingAnchor, constant: -20),
            
            deviceInfoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            deviceInfoLabel.leadingAnchor.constraint(equalTo: systemInfoContainer.leadingAnchor, constant: 20),
            deviceInfoLabel.trailingAnchor.constraint(equalTo: systemInfoContainer.trailingAnchor, constant: -20),
            deviceInfoLabel.bottomAnchor.constraint(equalTo: systemInfoContainer.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
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
            
            quickActionsContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            quickActionsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            quickActionsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            eventTrackingContainer.topAnchor.constraint(equalTo: quickActionsContainer.bottomAnchor, constant: 20),
            eventTrackingContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            eventTrackingContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            campaignContainer.topAnchor.constraint(equalTo: eventTrackingContainer.bottomAnchor, constant: 20),
            campaignContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            campaignContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            systemInfoContainer.topAnchor.constraint(equalTo: campaignContainer.bottomAnchor, constant: 20),
            systemInfoContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            systemInfoContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            systemInfoContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Helper Methods
    
    private func createSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func setupQuickActionButton(_ button: UIButton, title: String, icon: String, color: UIColor) {
        // Use UIButton.Configuration (iOS 15+)
           if #available(iOS 15.0, *) {
               var config = UIButton.Configuration.plain()
               config.title = title
               config.image = UIImage(systemName: icon)
               config.imagePlacement = .top
               config.imagePadding = 6
               config.baseForegroundColor = .white
               config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)
               config.titleAlignment = .center
               button.configuration = config

               // Font must still be set on titleLabel
               button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
           } else {
               // Fallback for iOS < 15 (if needed)
               button.setTitle(title, for: .normal)
               button.setTitleColor(.white, for: .normal)
               button.setImage(UIImage(systemName: icon), for: .normal)
               button.titleLabel?.numberOfLines = 2
               button.titleLabel?.textAlignment = .center
               button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
               button.tintColor = .white
               button.imageView?.contentMode = .scaleAspectFit
               button.contentVerticalAlignment = .center
           }

           // Common styling (both paths)
           button.backgroundColor = color
           button.layer.cornerRadius = 12
           button.layer.shadowColor = color.cgColor
           button.layer.shadowOffset = CGSize(width: 0, height: 4)
           button.layer.shadowOpacity = 0.3
           button.layer.shadowRadius = 8
           button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func createEventButton(icon: String, title: String, eventName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = UIColor(red: 0.43, green: 0.78, blue: 0.66, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.tintColor = .secondaryLabel
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(iconImageView)
        button.addSubview(titleLabel)
        button.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            
            chevronImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        button.addTarget(self, action: #selector(eventButtonTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = eventName
        
        return button
    }
    
    private func createCampaignButton(icon: String, title: String, eventName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = .systemPurple
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.tintColor = .secondaryLabel
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        button.addSubview(iconImageView)
        button.addSubview(titleLabel)
        button.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -16),
            
            chevronImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        button.addTarget(self, action: #selector(campaignButtonTapped(_:)), for: .touchUpInside)
        button.accessibilityIdentifier = eventName
        
        return button
    }
    
    private func updateUserInfo() {
        let name = UserDefaults.standard.string(forKey: "userName") ?? "Anonymous User"
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? "No email provided"
        
        if name != "Anonymous User" && email != "No email provided" {
            userInfoLabel.text = "\(name)\n\(email)"
        } else {
            userInfoLabel.text = "Anonymous User\nTap 'Update Profile' to personalize your experience"
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func viewProfileTapped() {
        CleverTap.sharedInstance()?.recordEvent("Profile_View_Selected", withProps: [
            "source": "dashboard_quick_actions"
        ])
        showViewProfileScreen()
    }
    
    @objc private func updateProfileTapped() {
        CleverTap.sharedInstance()?.recordEvent("Profile_Update_Selected", withProps: [
            "source": "dashboard_quick_actions"
        ])
        showUpdateProfileScreen()
    }
    
    @objc private func getCleverTapIDTapped() {
        if let cleverTapID = CleverTap.sharedInstance()?.profileGetID() {
            CleverTap.sharedInstance()?.recordEvent("CleverTap_ID_Requested")
            showAlert(title: "CleverTap ID", message: cleverTapID, showCopy: true)
        } else {
            showAlert(title: "Error", message: "Unable to fetch CleverTap ID.", showCopy: false)
        }
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func eventButtonTapped(_ sender: UIButton) {
        guard let eventName = sender.accessibilityIdentifier else { return }
        recordEventAction(eventName)
    }
    
    @objc private func campaignButtonTapped(_ sender: UIButton) {
        guard let campaignName = sender.accessibilityIdentifier else { return }
        triggerCampaignAction(campaignName)
    }
    
    // MARK: - CleverTap Event Recording
    
    private func recordEventAction(_ eventName: String) {
        var props: [String: Any] = [:]
        
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        
        switch eventName {
        case "Product_Viewed":
            props = [
                "Product_ID": "SKU\(Int.random(in: 100000...999999))",
                "Product_Name": ["Smart Watch Pro", "Wireless Headphones", "Bluetooth Speaker", "Fitness Tracker"].randomElement()!,
                "Price": Double.random(in: 29.99...299.99).rounded(toPlaces: 2),
                "Currency": "USD",
                "Category": ["Electronics", "Wearables", "Audio", "Fitness"].randomElement()!,
                "Brand": ["TechGear", "SoundMax", "FitPro", "GadgetZone"].randomElement()!,
                "Discount": Double.random(in: 0...25).rounded(toPlaces: 0),
                "In_Stock": Bool.random(),
                "View_Source": "dashboard_demo"
            ]
        case "Category_Viewed":
            props = [
                "Category_Name": ["Electronics", "Fashion", "Home & Garden", "Sports"].randomElement()!,
                "Products_Count": Int.random(in: 50...500),
                "Subcategories_Count": Int.random(in: 3...15),
                "Sort_By": ["Popularity", "Price Low to High", "Price High to Low", "Newest"].randomElement()!,
                "Filter_Applied": Bool.random()
            ]
        case "Cart_Viewed":
            props = [
                "Cart_ID": "CART\(Int.random(in: 100000...999999))",
                "Item_Count": Int.random(in: 1...10),
                "Total_Amount": Double.random(in: 50...1000).rounded(toPlaces: 2),
                "Currency": "USD",
                "Has_Discounted_Items": Bool.random(),
                "Estimated_Shipping": Double.random(in: 0...15.99).rounded(toPlaces: 2),
                "Abandoned_Previously": Bool.random()
            ]
        case "Checkout_Started":
            props = [
                "Cart_Value": Double.random(in: 100...800).rounded(toPlaces: 2),
                "Item_Count": Int.random(in: 1...8),
                "Shipping_Method": ["Standard", "Express", "Next Day", "Free"].randomElement()!,
                "Payment_Method_Available": ["Credit Card", "PayPal", "Apple Pay", "Google Pay"],
                "Coupon_Applied": Bool.random() ? "SAVE\(Int.random(in: 10...30))" : nil,
                "Checkout_Step": 1,
                "Guest_Checkout": Bool.random()
            ]
        case "Payment_Info_Added":
            props = [
                "Payment_Type": ["Credit Card", "Debit Card", "PayPal", "Apple Pay", "Google Pay"].randomElement()!,
                "Card_Type": ["Visa", "Mastercard", "American Express", "Discover"].randomElement()!,
                "Saved_For_Later": Bool.random(),
                "Installment_Option": Bool.random(),
                "Billing_Same_As_Shipping": Bool.random()
            ]
        case "Wishlist_Product_Added":
            props = [
                "Product_ID": "SKU\(Int.random(in: 100000...999999))",
                "Product_Name": ["Premium Headphones", "Smart TV", "Laptop Stand", "Wireless Charger"].randomElement()!,
                "Price": Double.random(in: 25...500).rounded(toPlaces: 2),
                "Wishlist_Count": Int.random(in: 1...20),
                "Added_From": ["Product Page", "Search Results", "Category Page", "Recommendations"].randomElement()!,
                "Previously_Viewed": Bool.random()
            ]
        case "Search_Performed":
            props = [
                "Search_Term": ["wireless headphones", "smart watch", "laptop", "phone case", "charger"].randomElement()!,
                "Results_Count": Int.random(in: 0...100),
                "Category_Filter": Bool.random() ? ["Electronics", "Accessories", "Audio"].randomElement() : nil,
                "Sort_Method": ["Relevance", "Price Low to High", "Price High to Low", "Customer Rating"].randomElement()!,
                "Search_Source": "dashboard_demo",
                "Auto_Complete_Used": Bool.random()
            ]
        case "Product_Rated":
            props = [
                "Product_ID": "SKU\(Int.random(in: 100000...999999))",
                "Product_Name": ["Smart Watch Pro", "Bluetooth Earbuds", "Phone Case", "Tablet Stand"].randomElement()!,
                "Rating": Double.random(in: 1...5).rounded(toPlaces: 1),
                "Review_Added": Bool.random(),
                "Purchase_Verified": Bool.random(),
                "Photos_Added": Bool.random(),
                "Helpful_Votes": Int.random(in: 0...50)
            ]
        default:
            props = [
                "Event_Time": Date(),
                "Source": "dashboard_demo",
                "Platform": "iOS"
            ]
        }
        
        // Add common properties
        props["User_Email"] = userEmail
        props["User_ID"] = userUUID
        props["Session_ID"] = "session_\(Int.random(in: 100000...999999))"
        props["Timestamp"] = Date()
        
        CleverTap.sharedInstance()?.recordEvent(eventName, withProps: props)
        
        // Show success feedback
        let eventTitle = eventName.replacingOccurrences(of: "_", with: " ").capitalized
        showSuccessAlert(title: "Event Recorded", message: "\(eventTitle) event recorded successfully with \(props.count) properties")
    }
    
    private func triggerCampaignAction(_ campaignName: String) {
        switch campaignName {
        case "Purchase_Completed":
            triggerPurchaseCompletedCampaign()
        case "Order_Delivered":
            triggerOrderDeliveredCampaign()
        case "First_Purchase":
            triggerFirstPurchaseCampaign()
        default:
            break
        }
    }
    
    private func triggerPurchaseCompletedCampaign() {
        let orderID = "ORD-\(Int.random(in: 10000...99999))"
        let amount = Double.random(in: 50...500).rounded(toPlaces: 2)
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
            let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "unknown"
        
        let purchaseProps: [String: Any] = [
            "Order_ID": orderID,
            "Amount": amount,
            "Currency": "USD",
            "Items": [
                [
                    "id": "SKU\(Int.random(in: 100000...999999))",
                    "name": ["Smart Watch Pro", "Wireless Headphones", "Bluetooth Speaker"].randomElement()!,
                    "price": Double.random(in: 99...199).rounded(toPlaces: 2),
                    "quantity": Int.random(in: 1...3),
                    "category": "Electronics"
                ],
                [
                    "id": "SKU\(Int.random(in: 100000...999999))",
                    "name": ["Phone Case", "Screen Protector", "Charging Cable"].randomElement()!,
                    "price": Double.random(in: 9.99...49.99).rounded(toPlaces: 2),
                    "quantity": Int.random(in: 1...2),
                    "category": "Accessories"
                ]
            ],
            "Payment_Method": ["Credit Card", "PayPal", "Apple Pay", "Google Pay"].randomElement()!,
            "Shipping_Method": ["Standard", "Express", "Next Day"].randomElement()!,
            "Shipping_Cost": Double.random(in: 0...15.99).rounded(toPlaces: 2),
            "Tax_Amount": (amount * 0.08).rounded(toPlaces: 2),
            "Discount_Amount": Double.random(in: 0...50).rounded(toPlaces: 2),
            "Coupon_Code": Bool.random() ? "SAVE\(Int.random(in: 10...30))" : nil,
            "Estimated_Delivery": Calendar.current.date(byAdding: .day, value: Int.random(in: 2...7), to: Date())!,
            "First_Purchase": Bool.random(),
            "User_UUID": userUUID,
            "User_Email": userEmail,
            "Platform": "iOS"
        ]
        
        CleverTap.sharedInstance()?.recordEvent("Purchase_Completed", withProps: purchaseProps)
        showSuccessAlert(title: "Campaign Triggered", message: "Purchase Completed campaign triggered\nOrder ID: \(orderID)")
    }
    
    private func triggerOrderDeliveredCampaign() {
        let orderID = "ORD-\(Int.random(in: 10000...99999))"
        
        let deliveryProps: [String: Any] = [
            "Order_ID": orderID,
            "Delivery_Date": Date(),
            "Delivery_Status": "Delivered",
            "Items_Count": Int.random(in: 1...5),
            "Order_Value": Double.random(in: 75...300).rounded(toPlaces: 2),
            "Shipping_Address": [
                "street": "123 Main Street",
                "city": ["New York", "Los Angeles", "Chicago", "Houston"].randomElement()!,
                "state": ["NY", "CA", "IL", "TX"].randomElement()!,
                "zip": "\(Int.random(in: 10000...99999))"
            ],
            "Delivery_Time": ["Morning", "Afternoon", "Evening"].randomElement()!,
            "Delivery_Method": ["Standard", "Express", "Contactless"].randomElement()!,
            "Signature_Required": Bool.random(),
            "Package_Condition": "Good",
            "Delivery_Attempts": Int.random(in: 1...2),
            "Rating_Requested": true,
            "User_ID": UserDefaults.standard.string(forKey: "userUUID") ?? "anonymous",
            "Platform": "iOS"
        ]
        
        CleverTap.sharedInstance()?.recordEvent("Order_Delivered", withProps: deliveryProps)
        showSuccessAlert(title: "Campaign Triggered", message: "Order Delivered campaign triggered\nOrder ID: \(orderID)")
    }
    
    private func triggerFirstPurchaseCampaign() {
        let orderID = "ORD-\(Int.random(in: 10000...99999))"
        let amount = Double.random(in: 25...150).rounded(toPlaces: 2)
        let discount = amount * 0.2 // 20% first purchase discount
        
        let firstPurchaseProps: [String: Any] = [
            "Order_ID": orderID,
            "Amount": amount,
            "Original_Amount": amount + discount,
            "Discount_Amount": discount.rounded(toPlaces: 2),
            "Currency": "USD",
            "Items": [
                [
                    "id": "SKU\(Int.random(in: 100000...999999))",
                    "name": ["Bluetooth Earbuds", "Phone Stand", "Portable Charger"].randomElement()!,
                    "price": amount,
                    "quantity": 1,
                    "category": ["Audio", "Accessories", "Power"].randomElement()!
                ]
            ],
            "Payment_Method": ["Credit Card", "PayPal", "Apple Pay"].randomElement()!,
            "Coupon_Used": "WELCOME20",
            "Discount_Percentage": 20,
            "First_Purchase": true,
            "Welcome_Email_Sent": true,
            "Loyalty_Points_Earned": Int(amount * 0.1),
            "Next_Purchase_Incentive": "10% off next order",
            "User_Segment": "new_customer",
            "Registration_Date": Calendar.current.date(byAdding: .day, value: -Int.random(in: 1...30), to: Date())!,
            "User_ID": UserDefaults.standard.string(forKey: "userUUID") ?? "anonymous",
            "Platform": "iOS"
        ]
        
        CleverTap.sharedInstance()?.recordEvent("First_Purchase", withProps: firstPurchaseProps)
        showSuccessAlert(title: "Campaign Triggered", message: "First Purchase campaign triggered\nOrder ID: \(orderID)\n20% Welcome discount applied!")
    }
    
    // MARK: - Navigation Methods
    
    private func showViewProfileScreen() {
        let viewProfileVC = ViewProfileViewController()
        let navController = UINavigationController(rootViewController: viewProfileVC)
        navController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        present(navController, animated: true)
    }
    
    private func showUpdateProfileScreen() {
        let updateProfileVC = UpdateProfileViewController()
        updateProfileVC.delegate = self
        let navController = UINavigationController(rootViewController: updateProfileVC)
        navController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        present(navController, animated: true)
    }
    
    private func performLogout() {
        // Show loading indicator
        let loadingAlert = UIAlertController(title: "Logging out...", message: nil, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        
        loadingAlert.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: loadingAlert.view.bottomAnchor, constant: -50)
        ])
        
        present(loadingAlert, animated: true)
        
        // Calculate session duration
        let sessionStartTime = UserDefaults.standard.double(forKey: "sessionStartTime")
        let sessionDuration = Date().timeIntervalSince1970 - sessionStartTime
        let userUUID = UserDefaults.standard.string(forKey: "userUUID") ?? "anonymous"
        let userEmail = UserDefaults.standard.string(forKey: "userEmail") ?? "anonymous"
        
        // Gather logout analytics data
        let logoutProps: [String: Any] = [
            "user_email": userEmail,
            "user_id": userUUID,
            "session_duration_seconds": sessionDuration,
            "session_duration_minutes": (sessionDuration / 60).rounded(toPlaces: 2),
            "logout_source": "dashboard",
            "logout_method": "user_initiated",
            "timestamp": Date(),
            "platform": "iOS",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            "device_model": UIDevice.current.model,
            "os_version": UIDevice.current.systemVersion
        ]
        
        // Record logout event with comprehensive data
        CleverTap.sharedInstance()?.recordEvent("User_Logged_Out", withProps: logoutProps)
        
        // Record session end event
        CleverTap.sharedInstance()?.recordEvent("Session_Ended", withProps: [
            "user_id": userUUID,
            "session_start": Date(timeIntervalSince1970: sessionStartTime),
            "session_end": Date(),
            "session_duration": sessionDuration,
            "end_reason": "user_logout"
        ])
        
        // Delay to allow CleverTap events to be sent
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.clearUserData()
            self?.returnToAuthScreen()
            
            // Dismiss loading alert
            loadingAlert.dismiss(animated: true)
        }
    }
    
    private func clearUserData() {
        // Define all keys that need to be removed
        let userDataKeys = [
            // User Profile Data
            "userName",
            "userEmail",
            "userPhone",
            "userAge",
            "userGender",
            "userCity",
            "userOccupation",
            "userInterests",
            "userUUID",
            "anonymousUUID",
            
            // Session Data
            "sessionStartTime",
            "sessionId",
            "lastAppOpenDate",
            "appOpenCount",
            
            // Settings & Preferences
            "userPreferences",
            "notificationSettings",
            "privacySettings",
            "appSettings",
            
            // Consent & Legal
            "userConsent",
            "consentDate",
            "termsAccepted",
            "privacyPolicyAccepted",
            
            // Analytics & Tracking
            "lastEventTime",
            "eventCount",
            "userSegment",
            "customerLifetimeValue",
            
            // App State
            "onboardingComplete",
            "tutorialComplete",
            "firstTimeUser",
            "lastAppVersion",
            
            // Cached Data
            "cachedUserProfile",
            "cachedPreferences",
            "temporaryData"
        ]
        
        // Remove all user-related data from UserDefaults
        for key in userDataKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        
        // Synchronize UserDefaults to ensure data is immediately written
        UserDefaults.standard.synchronize()
        
        // Clear CleverTap profile data
        clearCleverTapProfile()
        
        // Clear any cached data or temporary files if needed
        clearCachedData()
        
        print("✅ User data cleared successfully")
    }
    
    private func clearCleverTapProfile() {
        // Remove CleverTap profile identity
        CleverTap.sharedInstance()?.profileRemoveValue(forKey: "Identity")
        
        // Clear other profile properties
        let profilePropertiesToClear = [
            "Name", "Email", "Phone", "Age", "Gender", "City",
            "User_Type", "Registration_Status", "Customer_Segment",
            "Device_Type", "Device_Model", "OS_Version", "App_Version",
            "Signup_Date", "Signup_Method", "Onboarding_Complete",
            "Push_Enabled", "Email_Subscribed", "Location_Permission",
            "Internal_UUID"
        ]
        
        for property in profilePropertiesToClear {
            CleverTap.sharedInstance()?.profileRemoveValue(forKey: property)
        }
        
        // Reset CleverTap to anonymous state
        CleverTap.sharedInstance()?.profilePush([
            "User_Type": "anonymous",
            "Registration_Status": "logged_out",
            "Last_Logout": Date()
        ])
        
        print("✅ CleverTap profile cleared successfully")
    }
    
    private func clearCachedData() {
        // Clear any cached images, files, or temporary data
        let fileManager = FileManager.default
        
        // Clear caches directory if needed
        if let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let appCacheDirectory = cachesDirectory.appendingPathComponent(Bundle.main.bundleIdentifier ?? "app")
            
            do {
                if fileManager.fileExists(atPath: appCacheDirectory.path) {
                    try fileManager.removeItem(at: appCacheDirectory)
                    print("✅ Cached data cleared successfully")
                }
            } catch {
                print("⚠️ Error clearing cached data: \(error.localizedDescription)")
            }
        }
        
        // Clear any in-memory caches if you have them
        // Example: ImageCache.shared.clearAll()
        // Example: DataCache.shared.clearAll()
    }
    
    private func returnToAuthScreen() {
        // Create a fresh auth screen
        let authVC = AuthViewController()
        
        // Set up the transition
        authVC.modalPresentationStyle = .fullScreen
        authVC.modalTransitionStyle = .crossDissolve
        
        // Add custom transition animation
        UIView.transition(with: view.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {
            // Present the auth screen
            self.view.window?.rootViewController = authVC
        }) { _ in
            // Additional cleanup after transition
            print("✅ Successfully returned to auth screen")
            
            // Show success message (optional)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showLogoutSuccessMessage()
            }
        }
    }
    
    private func showLogoutSuccessMessage() {
        // Create a toast-like message
        let alertController = UIAlertController(
            title: "Logged Out",
            message: "You have been successfully logged out.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Present on the current root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            
            rootVC.present(alertController, animated: true)

            // Auto-dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                alertController.dismiss(animated: true)
            }
        }
    }
    
    // MARK: - Utility Methods
    
    private func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.string(forKey: "userUUID") != nil &&
               UserDefaults.standard.string(forKey: "userName") != nil
    }
    
    private func getCurrentSessionDuration() -> TimeInterval {
        let sessionStartTime = UserDefaults.standard.double(forKey: "sessionStartTime")
        return Date().timeIntervalSince1970 - sessionStartTime
    }
    
    // Emergency logout function that can be called from anywhere
    static func performEmergencyLogout() {
        // Clear all user defaults
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
            UserDefaults.standard.synchronize()
        }
        
        // Clear CleverTap
        CleverTap.sharedInstance()?.profileRemoveValue(forKey: "Identity")
        
        // Navigate to auth screen
        let authVC = AuthViewController()
        authVC.modalPresentationStyle = .fullScreen
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = authVC
            window.makeKeyAndVisible()
        }
    }
    
    // MARK: - Alert Methods
    
    private func showAlert(title: String, message: String, showCopy: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if showCopy {
            alert.addAction(UIAlertAction(title: "Copy", style: .default) { _ in
                UIPasteboard.general.string = message
                let copyAlert = UIAlertController(title: "Copied", message: "ID copied to clipboard", preferredStyle: .alert)
                copyAlert.addAction(UIAlertAction(title: "OK", style: .default))
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.present(copyAlert, animated: true)
                }
            })
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        present(alert, animated: true)
    }
}

// MARK: - Extensions

extension DashboardViewController: UpdateProfileDelegate {
    func profileDidUpdate() {
        updateUserInfo()
        
        // Record profile update completion from dashboard
        CleverTap.sharedInstance()?.recordEvent("Profile_Updated_From_Dashboard", withProps: [
            "updated_from": "dashboard_flow",
            "timestamp": Date()
        ])
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - UIColor Extension (if not already present)
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
