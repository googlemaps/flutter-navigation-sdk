import CarPlay
import UIKit

/// Manager for displaying and hiding the waiting overlay in CarPlay
class CarPlayWaitingOverlayManager {
    // MARK: - Properties
    
    private weak var carWindow: CPWindow?
    private weak var mapTemplate: CPMapTemplate?
    private var overlayView: UIView?
    private var savedTrailingButtons: [CPBarButton]?
    private var savedLeadingButtons: [CPBarButton]?
    
    // MARK: - Initialization
    
    init(carWindow: CPWindow?, mapTemplate: CPMapTemplate? = nil) {
        self.carWindow = carWindow
        self.mapTemplate = mapTemplate
    }
    
    // MARK: - Public Methods
    
    /// Show the waiting overlay with custom title and message
    /// - Parameters:
    ///   - mainTitle: The main title to display (default: "Navigation")
    ///   - title: The secondary title to display (default: "Waiting")
    ///   - message: The message to display (default: "Waiting for navigation session...")
    func show(
        mainTitle: String = "Navigation",
        title: String = "Waiting",
        message: String = "Waiting for navigation session..."
    ) {
        guard overlayView == nil else {
            NSLog("🟡 [WaitingOverlay] Already shown")
            return
        }
        
        guard let carWindow = carWindow else {
            NSLog("🟡 [WaitingOverlay] ❌ CarPlay window not available")
            return
        }
        
        NSLog("🟡 [WaitingOverlay] Showing overlay: \(mainTitle) - \(title) - \(message)")
        
        // Create overlay container
        let overlay = UIView(frame: carWindow.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Create gradient background (teal/blue gradient like in the image)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = carWindow.bounds
        gradientLayer.colors = [
            UIColor(red: 0.2, green: 0.5, blue: 0.5, alpha: 1.0).cgColor,  // Teal
            UIColor(red: 0.15, green: 0.2, blue: 0.35, alpha: 1.0).cgColor // Dark blue
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        overlay.layer.insertSublayer(gradientLayer, at: 0)
        
        // Create content container (top-left aligned like in the image)
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(contentView)
        
        // Create main title label (big "Navigation")
        let mainTitleLabel = UILabel()
        mainTitleLabel.text = mainTitle
        mainTitleLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        mainTitleLabel.textColor = .white
        mainTitleLabel.textAlignment = .left
        mainTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainTitleLabel)
        
        // Create secondary title label ("Waiting")
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Create message label
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        messageLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        messageLabel.textAlignment = .left
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        
        // Setup constraints with padding
        NSLayoutConstraint.activate([
            // Position content view with custom padding
            contentView.leadingAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            contentView.topAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.topAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            
            // Main title at top
            mainTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Secondary title below main title
            titleLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Message below secondary title
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
        
        // Add overlay to window
        carWindow.addSubview(overlay)
        overlayView = overlay
        
        // Hide ALL navigation bar buttons (both leading and trailing)
        // AND disable auto-hide during overlay
        if let template = mapTemplate {
            savedLeadingButtons = template.leadingNavigationBarButtons
            savedTrailingButtons = template.trailingNavigationBarButtons
            template.leadingNavigationBarButtons = []
            template.trailingNavigationBarButtons = []
            template.automaticallyHidesNavigationBar = false
            NSLog("🟡 [WaitingOverlay] Hidden \(savedLeadingButtons?.count ?? 0) leading + \(savedTrailingButtons?.count ?? 0) trailing buttons + disabled auto-hide")
        }
        
        NSLog("🟡 [WaitingOverlay] ✅ Overlay shown")
    }
    
    /// Hide the waiting overlay
    func hide() {
        guard let overlay = overlayView else {
            NSLog("🟢 [WaitingOverlay] No overlay to hide")
            return
        }
        
        NSLog("🟢 [WaitingOverlay] Hiding overlay...")
        
        // Mark as hidden immediately (before animation)
        overlayView = nil
        
        // Re-enable auto-hide for navigation bar
        if let template = mapTemplate {
            template.automaticallyHidesNavigationBar = true
            NSLog("🟢 [WaitingOverlay] Re-enabled auto-hide for navigation bar")
        }
        
        // Clear saved buttons (they will be recreated by updateTemplateButtons)
        savedLeadingButtons = nil
        savedTrailingButtons = nil
        
        NSLog("🟢 [WaitingOverlay] ✅ Overlay hidden, buttons will be restored by updateTemplateButtons()")
        
        // Animate fade out (just visual)
        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
            NSLog("🟢 [WaitingOverlay] Animation complete, overlay removed")
        })
    }
    
    /// Check if the overlay is currently shown
    var isShown: Bool {
        return overlayView != nil
    }
    
    /// Update references
    func updateReferences(carWindow: CPWindow?, mapTemplate: CPMapTemplate?) {
        self.carWindow = carWindow
        self.mapTemplate = mapTemplate
    }
    
    /// Cleanup resources
    func cleanup() {
        // If overlay is still shown, hide it first (which will handle buttons cleanup)
        if overlayView != nil {
            hide()
        }
        
        overlayView?.removeFromSuperview()
        overlayView = nil
        savedLeadingButtons = nil
        savedTrailingButtons = nil
        carWindow = nil
        mapTemplate = nil
    }
}
