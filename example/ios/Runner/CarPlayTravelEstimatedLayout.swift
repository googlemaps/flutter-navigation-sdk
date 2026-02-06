import GoogleNavigation
import SnapKit
import UIKit

// MARK: - TravelEstimatedCarPlayLayout

class CarPlayTravelEstimatedLayout: UIView {
    private let containerView = UIView()
    private let etaView: CustomETAView
    private let sizeMultiplier: CGFloat

    init(sizeMultiplier: CGFloat = 1.0) {
        self.sizeMultiplier = sizeMultiplier
        self.etaView = CustomETAView(sizeMultiplier: sizeMultiplier, isVertical: false)
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0
        containerView.clipsToBounds = true
        addSubview(containerView)

        etaView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(etaView)

        let height: CGFloat = 35 * sizeMultiplier
        let verticalPadding: CGFloat = 4 * sizeMultiplier
        let horizontalPaddingLeft: CGFloat = 16 * sizeMultiplier
        let horizontalPaddingRight: CGFloat = 16 * sizeMultiplier

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(height)
        }

        etaView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(verticalPadding)
            make.leading.equalToSuperview().inset(horizontalPaddingLeft)
            make.trailing.equalToSuperview().inset(horizontalPaddingRight)
        }

        etaView.update(
            remainingTime: nil,
            remainingDistance: nil,
            eta: "--:--"
        )
    }

    func update(remainingTime: TimeInterval?, remainingDistance: CLLocationDistance?, eta: String) {
        etaView.update(
            remainingTime: remainingTime,
            remainingDistance: remainingDistance,
            eta: eta
        )
    }
}

// MARK: - CustomETAView

class CustomETAView: UIView {
    // ETA column
    private let etaValueLabel = UILabel()
    private let etaTitleLabel = UILabel()

    // Remaining time column
    private let remainingTimeValueLabel = UILabel()
    private let remainingTimeUnitLabel = UILabel()

    // Remaining distance column
    private let remainingDistanceValueLabel = UILabel()
    private let remainingDistanceUnitLabel = UILabel()

    private let sizeMultiplier: CGFloat
    private let isVertical: Bool

    init(sizeMultiplier: CGFloat = 1.0, isVertical: Bool = false) {
        self.sizeMultiplier = sizeMultiplier
        self.isVertical = isVertical
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.sizeMultiplier = 1.0
        self.isVertical = false
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        let valueFontSize: CGFloat = 16 * sizeMultiplier
        let valueFont = UIFont.systemFont(ofSize: valueFontSize, weight: .bold)

        let unitFontSize: CGFloat = 10 * sizeMultiplier
        let unitFont = UIFont.systemFont(ofSize: unitFontSize, weight: .regular)

        let etaContainer = UIView()
        etaContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(etaContainer)

        let timeContainer = UIView()
        timeContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(timeContainer)

        let distanceContainer = UIView()
        distanceContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(distanceContainer)

        etaValueLabel.font = valueFont
        etaValueLabel.textColor = .black
        etaValueLabel.textAlignment = .center
        etaValueLabel.adjustsFontSizeToFitWidth = false
        etaValueLabel.numberOfLines = 1
        etaValueLabel.translatesAutoresizingMaskIntoConstraints = false
        etaContainer.addSubview(etaValueLabel)

        etaTitleLabel.text = "arrival"
        etaTitleLabel.font = unitFont
        etaTitleLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        etaTitleLabel.textAlignment = .center
        etaTitleLabel.adjustsFontSizeToFitWidth = false
        etaTitleLabel.numberOfLines = 1
        etaTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        etaContainer.addSubview(etaTitleLabel)

        remainingTimeValueLabel.font = valueFont
        remainingTimeValueLabel.textColor = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        remainingTimeValueLabel.textAlignment = .center
        remainingTimeValueLabel.adjustsFontSizeToFitWidth = false
        remainingTimeValueLabel.numberOfLines = 1
        remainingTimeValueLabel.translatesAutoresizingMaskIntoConstraints = false
        timeContainer.addSubview(remainingTimeValueLabel)

        remainingTimeUnitLabel.font = unitFont
        remainingTimeUnitLabel.textColor = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        remainingTimeUnitLabel.textAlignment = .center
        remainingTimeUnitLabel.adjustsFontSizeToFitWidth = false
        remainingTimeUnitLabel.numberOfLines = 1
        remainingTimeUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        timeContainer.addSubview(remainingTimeUnitLabel)

        remainingDistanceValueLabel.font = valueFont
        remainingDistanceValueLabel.textColor = .black
        remainingDistanceValueLabel.textAlignment = .center
        remainingDistanceValueLabel.adjustsFontSizeToFitWidth = false
        remainingDistanceValueLabel.numberOfLines = 1
        remainingDistanceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceContainer.addSubview(remainingDistanceValueLabel)

        remainingDistanceUnitLabel.font = unitFont
        remainingDistanceUnitLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        remainingDistanceUnitLabel.textAlignment = .center
        remainingDistanceUnitLabel.adjustsFontSizeToFitWidth = false
        remainingDistanceUnitLabel.numberOfLines = 1
        remainingDistanceUnitLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceContainer.addSubview(remainingDistanceUnitLabel)

        etaContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.0 / 3.0)
        }

        timeContainer.snp.makeConstraints { make in
            make.leading.equalTo(etaContainer.snp.trailing)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.0 / 3.0)
        }

        distanceContainer.snp.makeConstraints { make in
            make.leading.equalTo(timeContainer.snp.trailing)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(1.0 / 3.0)
        }

        etaValueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-6 * sizeMultiplier)
        }

        etaTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(etaValueLabel.snp.bottom).offset(1 * sizeMultiplier)
        }

        remainingTimeValueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-6 * sizeMultiplier)
        }

        remainingTimeUnitLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(remainingTimeValueLabel.snp.bottom).offset(1 * sizeMultiplier)
        }

        remainingDistanceValueLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-6 * sizeMultiplier)
        }

        remainingDistanceUnitLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(remainingDistanceValueLabel.snp.bottom).offset(1 * sizeMultiplier)
        }
    }

    func update(remainingTime: TimeInterval?, remainingDistance: CLLocationDistance?, eta: String) {
        etaValueLabel.text = eta

        if let time = remainingTime, time > 0 {
            let totalSeconds = time
            let minutes = Int(totalSeconds / 60.0)
            let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))

            let roundedMinutes: Int
            if totalSeconds < 60 {
                // If < 1 min, display 1 min
                roundedMinutes = 1
            } else if seconds >= 30 {
                // If >= 30s, round up to next minute
                roundedMinutes = minutes + 1
            } else {
                // If < 30s, round down to current minute
                roundedMinutes = minutes
            }

            remainingTimeValueLabel.text = "\(roundedMinutes)"
            remainingTimeUnitLabel.text = "min"
        } else {
            remainingTimeValueLabel.text = "--"
            remainingTimeUnitLabel.text = "min"
        }

        if let distance = remainingDistance, distance > 0 {
            if distance >= 1000 {
                // Display in km with 1 decimal
                let km = distance / 1000.0
                remainingDistanceValueLabel.text = String(format: "%.1f", km)
                remainingDistanceUnitLabel.text = "km"
            } else if distance >= 100 {
                // >= 100m, round to nearest 50m
                let roundedDistance = round(distance / 50.0) * 50.0
                remainingDistanceValueLabel.text = String(format: "%.0f", roundedDistance)
                remainingDistanceUnitLabel.text = "m"
            } else {
                // < 100m, round to nearest 10m
                let roundedDistance = round(distance / 10.0) * 10.0
                remainingDistanceValueLabel.text = String(format: "%.0f", roundedDistance)
                remainingDistanceUnitLabel.text = "m"
            }
        } else {
            remainingDistanceValueLabel.text = "--"
            remainingDistanceUnitLabel.text = "m"
        }
    }
}
