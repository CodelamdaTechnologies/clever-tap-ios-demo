//
//  GDPRConsentViewController.swift
//  clevertap-ios-demo
//
//  Created by user on 21/05/25.
//

import UIKit
import CleverTapSDK

class GDPRConsentViewController: UIViewController {
    
    // MARK: - UI Components
    private let mainStackView = UIStackView()
    private let contentStackView = UIStackView()
    private let headerStackView = UIStackView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let privacyCardView = UIView()
    private let privacyStackView = UIStackView()
    private let privacyTitleLabel = UILabel()
    private let privacyDescriptionLabel = UILabel()
    private let dataCollectionView = UIView()
    private let dataCollectionStackView = UIStackView()
    private let buttonStackView = UIStackView()
    private let acceptButton = UIButton(type: .system)
    private let declineButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateAppearance()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        setupMainStackView()
        setupHeader()
        setupPrivacyCard()
        setupButtons()
        setupConstraints()
    }
    
    private func setupMainStackView() {
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        mainStackView.distribution = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 32
        contentStackView.distribution = .fill
        contentStackView.layoutMargins = UIEdgeInsets(top: 40, left: 24, bottom: 24, right: 24)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.addArrangedSubview(contentStackView)
    }
    
    private func setupHeader() {
        headerStackView.axis = .vertical
        headerStackView.spacing = 16
        headerStackView.alignment = .center
        contentStackView.addArrangedSubview(headerStackView)
        
        // Privacy Icon
        iconImageView.image = UIImage(systemName: "hand.raised.fill")
        iconImageView.tintColor = .systemBlue
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        headerStackView.addArrangedSubview(iconImageView)
        
        // Title
        titleLabel.text = "Your Privacy Matters"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        headerStackView.addArrangedSubview(titleLabel)
        
        // Subtitle
        subtitleLabel.text = "Help us provide you with a better experience"
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        headerStackView.addArrangedSubview(subtitleLabel)
        
        // Icon constraints
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 48),
            iconImageView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupPrivacyCard() {
        // Main card container
        privacyCardView.backgroundColor = .secondarySystemGroupedBackground
        privacyCardView.layer.cornerRadius = 16
        privacyCardView.layer.cornerCurve = .continuous
        contentStackView.addArrangedSubview(privacyCardView)
        
        // Privacy content stack
        privacyStackView.axis = .vertical
        privacyStackView.spacing = 20
        privacyStackView.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        privacyStackView.isLayoutMarginsRelativeArrangement = true
        privacyStackView.translatesAutoresizingMaskIntoConstraints = false
        privacyCardView.addSubview(privacyStackView)
        
        // Privacy title
        privacyTitleLabel.text = "What we collect"
        privacyTitleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        privacyTitleLabel.textColor = .label
        privacyStackView.addArrangedSubview(privacyTitleLabel)
        
        // Privacy description
        privacyDescriptionLabel.text = "We use CleverTap to improve your app experience with analytics and personalized content."
        privacyDescriptionLabel.font = .systemFont(ofSize: 15, weight: .regular)
        privacyDescriptionLabel.textColor = .secondaryLabel
        privacyDescriptionLabel.numberOfLines = 0
        privacyStackView.addArrangedSubview(privacyDescriptionLabel)
        
        // Data collection info
        setupDataCollectionInfo()
        
        NSLayoutConstraint.activate([
            privacyStackView.topAnchor.constraint(equalTo: privacyCardView.topAnchor),
            privacyStackView.leadingAnchor.constraint(equalTo: privacyCardView.leadingAnchor),
            privacyStackView.trailingAnchor.constraint(equalTo: privacyCardView.trailingAnchor),
            privacyStackView.bottomAnchor.constraint(equalTo: privacyCardView.bottomAnchor)
        ])
    }
    
    private func setupDataCollectionInfo() {
        dataCollectionView.backgroundColor = .tertiarySystemGroupedBackground
        dataCollectionView.layer.cornerRadius = 12
        dataCollectionView.layer.cornerCurve = .continuous
        privacyStackView.addArrangedSubview(dataCollectionView)
        
        dataCollectionStackView.axis = .vertical
        dataCollectionStackView.spacing = 12
        dataCollectionStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        dataCollectionStackView.isLayoutMarginsRelativeArrangement = true
        dataCollectionStackView.translatesAutoresizingMaskIntoConstraints = false
        dataCollectionView.addSubview(dataCollectionStackView)
        
        let dataPoints = [
            ("Device & app information", "iphone"),
            ("Usage analytics", "chart.bar.fill"),
            ("App interactions", "hand.tap.fill"),
            ("Profile preferences", "person.fill")
        ]
        
        for (text, iconName) in dataPoints {
            let itemView = createDataPointView(text: text, iconName: iconName)
            dataCollectionStackView.addArrangedSubview(itemView)
        }
        
        NSLayoutConstraint.activate([
            dataCollectionStackView.topAnchor.constraint(equalTo: dataCollectionView.topAnchor),
            dataCollectionStackView.leadingAnchor.constraint(equalTo: dataCollectionView.leadingAnchor),
            dataCollectionStackView.trailingAnchor.constraint(equalTo: dataCollectionView.trailingAnchor),
            dataCollectionStackView.bottomAnchor.constraint(equalTo: dataCollectionView.bottomAnchor)
        ])
    }
    
    private func createDataPointView(text: String, iconName: String) -> UIView {
        let containerView = UIView()
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = .systemBlue
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(label)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return containerView
    }
    
    private func setupButtons() {
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 12
        buttonStackView.distribution = .fillEqually
        contentStackView.addArrangedSubview(buttonStackView)
        
        // Accept Button
        acceptButton.setTitle("Allow", for: .normal)
        acceptButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        acceptButton.backgroundColor = .systemBlue
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 14
        acceptButton.layer.cornerCurve = .continuous
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(acceptButton)
        
        // Decline Button
        declineButton.setTitle("Don't Allow", for: .normal)
        declineButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        declineButton.backgroundColor = .clear
        declineButton.setTitleColor(.systemBlue, for: .normal)
        declineButton.layer.cornerRadius = 14
        declineButton.layer.cornerCurve = .continuous
        declineButton.layer.borderWidth = 1
        declineButton.layer.borderColor = UIColor.systemBlue.cgColor
        declineButton.addTarget(self, action: #selector(declineButtonTapped), for: .touchUpInside)
        buttonStackView.addArrangedSubview(declineButton)
        
        // Button height constraints
        NSLayoutConstraint.activate([
            acceptButton.heightAnchor.constraint(equalToConstant: 50),
            declineButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureAccessibility() {
        titleLabel.accessibilityTraits = .header
        acceptButton.accessibilityLabel = "Allow data collection for better experience"
        declineButton.accessibilityLabel = "Decline data collection"
        privacyCardView.accessibilityLabel = "Privacy information card"
    }
    
    private func animateAppearance() {
        contentStackView.alpha = 0
        contentStackView.transform = CGAffineTransform(translationX: 0, y: 30)
        
        UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.contentStackView.alpha = 1
            self.contentStackView.transform = .identity
        }
    }
    
    // MARK: - Actions
    @objc private func acceptButtonTapped() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Animate button press
        animateButtonPress(acceptButton) { [weak self] in
            self?.handleAcceptConsent()
        }
    }
    
    @objc private func declineButtonTapped() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Animate button press
        animateButtonPress(declineButton) { [weak self] in
            self?.handleDeclineConsent()
        }
    }
    
    private func animateButtonPress(_ button: UIButton, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                button.transform = .identity
            }) { _ in
                completion()
            }
        }
    }
    
    private func handleAcceptConsent() {
        // Save consent status
        UserDefaults.standard.set(true, forKey: "userConsent")
        UserDefaults.standard.set(Date(), forKey: "consentDate")
        
        // Set CleverTap opt-in status
        CleverTap.sharedInstance()?.setOptOut(false)
        
        // Navigate to next screen
        let authVC = AuthViewController()
        navigateToNextScreen(authVC)
    }
    
    private func handleDeclineConsent() {
        // Save consent status
        UserDefaults.standard.set(false, forKey: "userConsent")
        UserDefaults.standard.set(Date(), forKey: "consentDate")
        
        // Set CleverTap opt-out
        CleverTap.sharedInstance()?.setOptOut(true)
        
        // Show system-style alert
        showLimitedFunctionalityAlert()
    }
    
    private func showLimitedFunctionalityAlert() {
        let alert = UIAlertController(
            title: "Limited Features",
            message: "Some personalization features won't be available. You can change this anytime in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let authVC = AuthViewController()
            self.navigateToNextScreen(authVC)
        }))
        
        alert.addAction(UIAlertAction(title: "Reconsider", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func navigateToNextScreen(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        
        // Add transition animation
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { _ in
            self.present(viewController, animated: false) {
                self.view.alpha = 1
            }
        }
    }
}

// MARK: - Dark Mode Support
extension GDPRConsentViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Update border colors for dark mode
            declineButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
}
