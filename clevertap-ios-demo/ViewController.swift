//
//  ViewController.swift
//  clevertap-ios-demo
//
//  Created by user on 14/04/25.
//

import UIKit
import CleverTapSDK

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let tableView = UITableView()

    // Data for table
    private let sections = ["User Properties", "Events", "Campaigns"]
    private let userPropertyActions = ["Update User Profile", "Update Custom User Properties"]
    private let eventActions = [
        "App Opened", "Product Viewed", "Category Viewed", "Cart Viewed",
        "Checkout Started", "Payment Info Added", "Wishlist Product Added",
        "Search Performed", "Product Rated", "App Uninstalled"
    ]
    private let campaignActions = ["Purchase Completed", "Order Delivered", "First Purchase"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "CleverTap Demo"
        setupUI()
        
        // Record app launched event
        CleverTap.sharedInstance()?.recordEvent("App_Opened")
        
        // Schedule local notification after 5 seconds for testing
        scheduleLocalNotification()
    }
    private func setupUI() {
      view.backgroundColor = .systemBackground
      
      // Setup ScrollView
      scrollView.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(scrollView)
      
      // Setup ContentView
      contentView.translatesAutoresizingMaskIntoConstraints = false
      scrollView.addSubview(contentView)
      
      // Title Label
      titleLabel.text = "CleverTap Demo App"
      titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
      titleLabel.textAlignment = .center
      titleLabel.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(titleLabel)
      
      // Subtitle Label
      subtitleLabel.text = "Test various CleverTap features"
      subtitleLabel.font = UIFont.systemFont(ofSize: 18)
      subtitleLabel.textColor = .darkGray
      subtitleLabel.textAlignment = .center
      subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(subtitleLabel)
      
      // Setup TableView
      tableView.delegate = self
      tableView.dataSource = self
      tableView.translatesAutoresizingMaskIntoConstraints = false
      tableView.isScrollEnabled = false  // Disable scrolling as we're using a ScrollView
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
      contentView.addSubview(tableView)
      
      // Set up constraints
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
          
          titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
          titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
          titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
          
          subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
          subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
          subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
          
          tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
          tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
          tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
          tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
      ])
      
      // Calculate and set the table view height based on its content
      tableView.reloadData()
      tableView.layoutIfNeeded()
      
      // Get ID button
      let getIdButton = UIBarButtonItem(title: "Get ID", style: .plain, target: self, action: #selector(getCleverTapID))
      navigationItem.rightBarButtonItem = getIdButton
      
      // Add a height constraint for table view
      let tableViewHeight = CGFloat(sections.count) * 44 +
                           CGFloat(userPropertyActions.count + eventActions.count + campaignActions.count) * 44
      tableView.heightAnchor.constraint(equalToConstant: tableViewHeight).isActive = true
      
      // Add a height constraint for content view
      let contentViewHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
      contentViewHeightConstraint.priority = .defaultLow
      contentViewHeightConstraint.isActive = true
  }
  
  // MARK: - TableView DataSource & Delegate
  func numberOfSections(in tableView: UITableView) -> Int {
      return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      switch section {
      case 0: return userPropertyActions.count
      case 1: return eventActions.count
      case 2: return campaignActions.count
      default: return 0
      }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return sections[section]
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      
      switch indexPath.section {
      case 0:
          cell.textLabel?.text = userPropertyActions[indexPath.row]
      case 1:
          cell.textLabel?.text = eventActions[indexPath.row]
      case 2:
          cell.textLabel?.text = campaignActions[indexPath.row]
      default:
          cell.textLabel?.text = ""
      }
      
      return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      
      switch indexPath.section {
      case 0:
          switch indexPath.row {
          case 0:
              updateUserProfile()
          case 1:
              updateCustomUserProperties()
          default:
              break
          }
      case 1:
          recordEvent(eventActions[indexPath.row])
      case 2:
          switch indexPath.row {
          case 0:
              triggerPurchaseCompletedCampaign()
          case 1:
              triggerOrderDeliveredCampaign()
          case 2:
              triggerFirstPurchaseCampaign()
          default:
              break
          }
      default:
          break
      }
  }
  
  // MARK: - CleverTap Functions
  
  @objc private func getCleverTapID() {
      if let cleverTapID = CleverTap.sharedInstance()?.profileGetID() {
          showAlert(title: "CleverTap ID", message: cleverTapID)
      } else {
          showAlert(title: "Error", message: "Unable to fetch CleverTap ID.")
      }
  }
  
  private func updateUserProfile() {
      // Basic user profile
      let profile: [String: Any] = [
          "Name": "John Doe",
          "Email": "john.doe@example.com",
          "Phone": "+1234567890",
          "Identity": "user123",
          "Gender": "M",
          "DOB": NSDate(timeIntervalSince1970: 712800000), // Example date
          "Photo": "https://example.com/profile.jpg",
          "Address": "123 Main St",
          "Age": 30,
          "Education": "Graduate"
      ]
      
      CleverTap.sharedInstance()?.onUserLogin(profile)
      showAlert(title: "Success", message: "User profile updated")
  }
  
  private func updateCustomUserProperties() {
      // Custom user properties
      let customProps: [String: Any] = [
          "Premium_User": true,
          "Last_Purchase_Date": NSDate(),
          "Preferred_Language": "English",
          "Loyalty_Level": "Gold",
          "Subscription_Type": "Annual",
          "Account_Balance": 250.50,
          "Preferred_Payment": "Credit Card",
          "Interests": ["Technology", "Sports", "Travel"],
          "App_Version": "1.2.3",
          "Last_Login_Time": NSDate()
      ]
      
      CleverTap.sharedInstance()?.profilePush(customProps)
      showAlert(title: "Success", message: "Custom user properties updated")
  }
  
  private func recordEvent(_ eventName: String) {
      // Generate different properties based on event type
      var props: [String: Any] = [:]
      
      switch eventName {
      case "App Opened":
          props = [
              "Source": "Direct",
              "App_Version": "1.2.3",
              "Network_Type": "WiFi",
              "Device_Model": UIDevice.current.model,
              "OS_Version": UIDevice.current.systemVersion
          ]
      case "Product Viewed":
          props = [
              "Product_ID": "SKU123456",
              "Product_Name": "Smart Watch Pro",
              "Price": 199.99,
              "Currency": "USD",
              "Category": "Electronics",
              "Brand": "TechGear",
              "Discount": 10.0,
              "In_Stock": true
          ]
      case "Category Viewed":
          props = [
              "Category_Name": "Electronics",
              "Products_Count": 120,
              "Subcategories": ["Wearables", "Smartphones", "Laptops"],
              "Sort_By": "Popularity"
          ]
      case "Cart Viewed":
          props = [
              "Cart_ID": "CART987654",
              "Item_Count": 3,
              "Total_Amount": 399.99,
              "Currency": "USD",
              "Has_Discounted_Items": true,
              "Estimated_Shipping": 5.99
          ]
      case "Checkout Started":
          props = [
              "Cart_Value": 399.99,
              "Shipping_Method": "Standard",
              "Payment_Method": "Credit Card",
              "Coupon_Applied": "SUMMER10",
              "Checkout_Step": 1
          ]
      case "Payment Info Added":
          props = [
              "Payment_Type": "Credit Card",
              "Card_Type": "Visa",
              "Saved_For_Later": true,
              "Installment_Option": false
          ]
      case "Wishlist Product Added":
          props = [
              "Product_ID": "SKU789012",
              "Product_Name": "Premium Headphones",
              "Price": 149.99,
              "Wishlist_Count": 5,
              "Added_From": "Product Page"
          ]
      case "Search Performed":
          props = [
              "Search_Term": "wireless headphones",
              "Results_Count": 24,
              "Category_Filter": "Audio",
              "Sort_Method": "Price Low to High",
              "Search_Source": "Search Bar"
          ]
      case "Product Rated":
          props = [
              "Product_ID": "SKU123456",
              "Product_Name": "Smart Watch Pro",
              "Rating": 4.5,
              "Review_Added": true,
              "Purchase_Verified": true
          ]
      case "App Uninstalled":
          props = [
              "Days_Since_Install": 45,
              "Last_Used": NSDate().timeIntervalSince1970 - 86400, // 1 day ago
              "Reason_Known": "Performance Issues",
              "User_Type": "Free"
          ]
      default:
          props = [
              "Event_Time": NSDate(),
              "Custom_Property": "Value"
          ]
      }
      
      // Standardize the event name for CleverTap format
      let formattedEventName = eventName.replacingOccurrences(of: " ", with: "_")
      
      // Record the event
      CleverTap.sharedInstance()?.recordEvent(formattedEventName, withProps: props)
      showAlert(title: "Event Recorded", message: "\(eventName) event was recorded with \(props.count) properties")
  }
  
  // MARK: - Campaign Functions
  
  private func triggerPurchaseCompletedCampaign() {
      let purchaseProps: [String: Any] = [
          "Order_ID": "ORD-\(Int.random(in: 10000...99999))",
          "Amount": 249.99,
          "Currency": "USD",
          "Items": [
              ["id": "SKU123", "name": "Smart Watch Pro", "price": 199.99, "quantity": 1],
              ["id": "SKU456", "name": "Watch Strap", "price": 49.99, "quantity": 1]
          ],
          "Payment_Method": "Credit Card",
          "Shipping_Method": "Express",
          "Estimated_Delivery": NSDate().addingTimeInterval(86400 * 3), // 3 days later
          "First_Purchase": false
      ]
      
      CleverTap.sharedInstance()?.recordEvent("Purchase_Completed", withProps: purchaseProps)
      showAlert(title: "Campaign Triggered", message: "Purchase Completed campaign was triggered")
  }
  
  private func triggerOrderDeliveredCampaign() {
      let deliveryProps: [String: Any] = [
          "Order_ID": "ORD-\(Int.random(in: 10000...99999))",
          "Delivery_Date": NSDate(),
          "Delivery_Status": "Delivered",
          "Items_Count": 2,
          "Shipping_Address": "123 Main St, Anytown, USA",
          "Delivery_Person": "John Smith",
          "Contact_Number": "+123456789",
          "Rating_Requested": true
      ]
      
      CleverTap.sharedInstance()?.recordEvent("Order_Delivered", withProps: deliveryProps)
      showAlert(title: "Campaign Triggered", message: "Order Delivered campaign was triggered")
  }
  
  private func triggerFirstPurchaseCampaign() {
      let firstPurchaseProps: [String: Any] = [
          "Order_ID": "ORD-\(Int.random(in: 10000...99999))",
          "Amount": 99.99,
          "Currency": "USD",
          "Items": [
              ["id": "SKU789", "name": "Bluetooth Earbuds", "price": 79.99, "quantity": 1],
              ["id": "SKU101", "name": "Case Cover", "price": 19.99, "quantity": 1]
          ],
          "Payment_Method": "PayPal",
          "Coupon_Used": "WELCOME20",
          "Discount_Applied": 20.00,
          "First_Purchase": true
      ]
      
      CleverTap.sharedInstance()?.recordEvent("First_Purchase", withProps: firstPurchaseProps)
      showAlert(title: "Campaign Triggered", message: "First Purchase campaign was triggered")
  }
  
  // MARK: - Push Notification Test
  
  private func scheduleLocalNotification() {
      let center = UNUserNotificationCenter.current()
      
      let content = UNMutableNotificationContent()
      content.title = "CleverTap Demo"
      content.body = "Thank you for trying the CleverTap demo app!"
      content.sound = UNNotificationSound.default
      
      // Add custom data for CleverTap tracking
      content.userInfo = [
          "pt_id": "notification_test_\(Int.random(in: 1000...9999))",
          "pt_title": "CleverTap Demo",
          "pt_msg": "Thank you for trying the CleverTap demo app!",
          "pt_campaign_id": "local_notification_test",
          "ct_platform": "iOS"
      ]
      
      // Trigger the notification after 5 seconds
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
      
      let request = UNNotificationRequest(identifier: "local_notification", content: content, trigger: trigger)
      center.add(request) { (error) in
          if let error = error {
              print("Error scheduling notification: \(error)")
          }
      }
  }
  
  // MARK: - Helper Functions
  
  private func showAlert(title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      
      if title == "CleverTap ID" {
          // Add Copy button
          alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { _ in
              UIPasteboard.general.string = message
          }))
      }
      
      // Add OK button
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      
      DispatchQueue.main.async { [weak self] in
          self?.present(alert, animated: true, completion: nil)
      }
  }
}

//// MARK: - UIColor Extension
//extension UIColor {
//  convenience init(hexString: String) {
//      let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//      var int = UInt64()
//      Scanner(string: hex).scanHexInt64(&int)
//      let a, r, g, b: UInt64
//      switch hex.count {
//      case 3: // RGB (12-bit)
//          (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//      case 6: // RGB (24-bit)
//          (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//      case 8: // ARGB (32-bit)
//          (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//      default:
//          (a, r, g, b) = (255, 0, 0, 0)
//      }
//      self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
//  }
//
//}
