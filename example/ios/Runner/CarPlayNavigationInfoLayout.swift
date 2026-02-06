import GoogleNavigation
import SnapKit
import UIKit
import google_navigation_flutter

// MARK: - NavigationInfoCarPlayLayout

class CarPlayNavigationInfoLayout: UIView {
    private let containerView = UIView()
    private let maneuverView: CustomManeuverView
    private let nextStepLayout: CarPlayNavigationInfoNextLayout
    private let sizeMultiplier: CGFloat

    init(sizeMultiplier: CGFloat = 1.0) {
        self.sizeMultiplier = sizeMultiplier
        self.maneuverView = CustomManeuverView(sizeMultiplier: sizeMultiplier)
        self.nextStepLayout = CarPlayNavigationInfoNextLayout(sizeMultiplier: sizeMultiplier)
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        containerView.backgroundColor = UIColor(red: 0.25, green: 0.42, blue: 0.38, alpha: 0.95)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 0
        containerView.clipsToBounds = true
        addSubview(containerView)

        maneuverView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(maneuverView)

        nextStepLayout.translatesAutoresizingMaskIntoConstraints = false
        addSubview(nextStepLayout)

        let height: CGFloat = 60 * sizeMultiplier
        let horizontalPadding: CGFloat = 12 * sizeMultiplier
        let nextStepHeight: CGFloat = 32 * sizeMultiplier
        let spacing: CGFloat = 4 * sizeMultiplier

        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(height)
        }

        maneuverView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(horizontalPadding)
        }

        nextStepLayout.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(spacing)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(nextStepHeight)
            make.bottom.equalToSuperview()
        }

        maneuverView.setWaitingText()
        nextStepLayout.hide()  // Disabled for now
    }

    func update(stepInfo: GMSNavigationStepInfo, distanceToStep: CLLocationDistance) {
        maneuverView.update(
            stepInfo: stepInfo,
            distanceToStep: distanceToStep,
            sizeMultiplier: sizeMultiplier
        )

        nextStepLayout.hide()
    }
}

// MARK: - CustomManeuverView

class CustomManeuverView: UIView {
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let instructionLabel = UILabel()
    private let distanceLabel = UILabel()
    private var instructionLeadingConstraint: NSLayoutConstraint!
    private var instructionLeadingFromIconConstraint: NSLayoutConstraint!
    private let sizeMultiplier: CGFloat

    init(sizeMultiplier: CGFloat = 1.0) {
        self.sizeMultiplier = sizeMultiplier
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.sizeMultiplier = 1.0
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconContainer)

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        let distanceFontSize: CGFloat = 11 * sizeMultiplier
        distanceLabel.font = .systemFont(ofSize: distanceFontSize, weight: .semibold)
        distanceLabel.textColor = .white
        distanceLabel.numberOfLines = 1
        distanceLabel.textAlignment = .center
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(distanceLabel)

        let instructionFontSize: CGFloat = 16 * sizeMultiplier
        instructionLabel.font = .systemFont(ofSize: instructionFontSize, weight: .regular)
        instructionLabel.textColor = .white
        instructionLabel.numberOfLines = 2
        instructionLabel.lineBreakMode = .byTruncatingTail
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(instructionLabel)

        let iconSize: CGFloat = 26 * sizeMultiplier
        let spacing: CGFloat = 12 * sizeMultiplier

        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(iconSize + 4)
            make.height.equalTo(40 * sizeMultiplier)
        }

        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(iconSize)
        }

        distanceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(2 * sizeMultiplier)
        }

        instructionLeadingConstraint = instructionLabel.leadingAnchor.constraint(
            equalTo: leadingAnchor)
        instructionLeadingFromIconConstraint = instructionLabel.leadingAnchor.constraint(
            equalTo: iconContainer.trailingAnchor, constant: spacing)

        instructionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        instructionLeadingConstraint.isActive = true
    }

    func update(
        stepInfo: GMSNavigationStepInfo, distanceToStep: CLLocationDistance, sizeMultiplier: CGFloat
    ) {
        let maneuver = stepInfo.maneuver
        let roadName = stepInfo.simpleRoadName ?? ""
        let instruction = stepInfo.fullInstructionText ?? ""

        NSLog(
            "🟦 [CustomManeuverView] update() - maneuver: \(maneuver.rawValue), roadName: \(roadName), instruction: \(instruction)"
        )

        let hasRealManeuver = maneuver != .straight && maneuver != .unknown

        if hasRealManeuver && distanceToStep > 0 {
            NSLog("🟦 [CustomManeuverView] hasRealManeuver = true, showing icon and distance")
            iconImageView.image = CarPlayManeuverIconConverter.image(
                from: stepInfo,
                pointSize: 24 * sizeMultiplier,
                tintColor: .white
            )
            iconContainer.isHidden = false
            iconImageView.isHidden = false
            instructionLeadingConstraint.isActive = false
            instructionLeadingFromIconConstraint.isActive = true

            distanceLabel.text = formatDistance(distanceToStep)
            distanceLabel.isHidden = false
        } else {
            NSLog("🟦 [CustomManeuverView] hasRealManeuver = false or distance <= 0, hiding icon")
            iconContainer.isHidden = true
            instructionLeadingFromIconConstraint.isActive = false
            instructionLeadingConstraint.isActive = true
        }

        if !roadName.isEmpty {
            let roadNameAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: 16 * sizeMultiplier, weight: .bold),
            ]
            instructionLabel.attributedText = NSAttributedString(
                string: roadName, attributes: roadNameAttributes)
        } else if !instruction.isEmpty {
            instructionLabel.text = instruction
        } else {
            instructionLabel.text = ""
        }

        instructionLabel.isHidden = false
    }

    private func formatDistance(_ distance: CLLocationDistance) -> String {
        let roundedDistance: Double

        if distance >= 100 {
            // Round to nearest 100 meters when >= 100
            roundedDistance = round(distance / 100.0) * 100.0
        } else {
            // Round to nearest 10 meters when < 100
            roundedDistance = round(distance / 10.0) * 10.0
        }

        if roundedDistance >= 1000 {
            let km = roundedDistance / 1000.0
            return String(format: "%.1f km", km)
        } else {
            return String(format: "%.0f m", roundedDistance)
        }
    }

    func setWaitingText() {
        iconContainer.isHidden = true
        instructionLeadingFromIconConstraint.isActive = false
        instructionLeadingConstraint.isActive = true

        instructionLabel.text = "Starting navigation..."
        instructionLabel.isHidden = false
    }
}

// MARK: - CarPlayNavigationInfoNextLayout

class CarPlayNavigationInfoNextLayout: UIView {
    private let iconImageView = UIImageView()
    private let instructionLabel = UILabel()
    private let sizeMultiplier: CGFloat

    init(sizeMultiplier: CGFloat = 1.0) {
        self.sizeMultiplier = sizeMultiplier
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.sizeMultiplier = 1.0
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.85)
        layer.cornerRadius = 12
        layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner,
        ]
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        clipsToBounds = true

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)

        instructionLabel.font = .systemFont(ofSize: 14 * sizeMultiplier, weight: .regular)
        instructionLabel.textColor = .white
        instructionLabel.numberOfLines = 1
        instructionLabel.lineBreakMode = .byTruncatingTail
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(instructionLabel)

        let padding: CGFloat = 8 * sizeMultiplier

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(padding)
            make.centerY.equalToSuperview()
            make.size.equalTo(24 * sizeMultiplier)
        }

        instructionLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(8 * sizeMultiplier)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-padding)
        }

        isHidden = true
    }

    func update(stepInfo: GMSNavigationStepInfo, sizeMultiplier: CGFloat) {
        iconImageView.image = CarPlayManeuverIconConverter.image(
            from: stepInfo,
            pointSize: 20 * sizeMultiplier,
            tintColor: .white
        )

        // Prefer road name over instruction
        let roadName = stepInfo.simpleRoadName ?? ""
        let instruction = stepInfo.fullInstructionText ?? ""
        instructionLabel.text = roadName.isEmpty ? instruction : roadName

        isHidden = false
    }

    func hide() {
        isHidden = true
    }
}
