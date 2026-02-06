import CarPlay
import GoogleNavigation
import SnapKit
import UIKit
import google_navigation_flutter

class CarPlayOverlayLayout: UIView {
    // MARK: - Properties

    private(set) weak var navView: GoogleMapsNavigationView?

    // Custom overlay views
    private(set) var navigationInfoLayout: CarPlayNavigationInfoLayout!
    private(set) var travelEstimatedLayout: CarPlayTravelEstimatedLayout!

    private var sizeMultiplier: CGFloat {
        let screenHeight = bounds.height
        return min(max(screenHeight / 480.0, 0.7), 1.3)
    }

    // MARK: - Initialization

    init(navView: GoogleMapsNavigationView, frame: CGRect) {
        super.init(frame: frame)
        self.navView = navView
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout Setup

    private func setupLayout() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        setupNavigationInfoLayout()
        setupTravelEstimatedLayout()
    }

    private func setupNavigationInfoLayout() {
        navigationInfoLayout = CarPlayNavigationInfoLayout(sizeMultiplier: sizeMultiplier)
        navigationInfoLayout.translatesAutoresizingMaskIntoConstraints = false
        addSubview(navigationInfoLayout)

        let marginLeft: CGFloat = 10 * sizeMultiplier

        navigationInfoLayout.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(8)
            make.leading.equalTo(safeAreaLayoutGuide).offset(marginLeft)
            make.width.equalToSuperview().multipliedBy(0.45)
        }

        navigationInfoLayout.isHidden = true
    }

    private func setupTravelEstimatedLayout() {
        travelEstimatedLayout = CarPlayTravelEstimatedLayout(sizeMultiplier: sizeMultiplier)
        travelEstimatedLayout.translatesAutoresizingMaskIntoConstraints = false
        addSubview(travelEstimatedLayout)

        let marginLeft: CGFloat = 10 * sizeMultiplier

        travelEstimatedLayout.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-8)
            make.leading.equalTo(safeAreaLayoutGuide).offset(marginLeft)
            make.width.equalToSuperview().multipliedBy(0.45)
        }

        travelEstimatedLayout.isHidden = true
    }

    // MARK: - Public Methods

    func updateNavigationInfo(
        _ navInfo: GMSNavigationNavInfo, nextManeuver: GMSNavigationManeuver? = nil
    ) {
        guard let currentStep = navInfo.currentStep else {
            hideOverlays()
            return
        }

        showOverlays()

        // Get distance to current step (in meters)
        let distanceToStep = CLLocationDistance(navInfo.distanceToCurrentStepMeters)

        navigationInfoLayout.update(
            stepInfo: currentStep,
            distanceToStep: distanceToStep
        )

        let remainingTime = TimeInterval(navInfo.timeToFinalDestinationSeconds)
        let remainingDistance = CLLocationDistance(navInfo.distanceToFinalDestinationMeters)

        updateRemainingInfo(remainingTime: remainingTime, remainingDistance: remainingDistance)
    }

    func updateRemainingInfo(remainingTime: TimeInterval?, remainingDistance: CLLocationDistance?) {
        travelEstimatedLayout.update(
            remainingTime: remainingTime,
            remainingDistance: remainingDistance,
            eta: remainingTime.map { calculateETA($0) } ?? "--:--"
        )
    }

    func showOverlays() {
        NSLog("🟢 [CarPlayOverlayLayout] showOverlays() called")
        navigationInfoLayout.isHidden = false
        travelEstimatedLayout.isHidden = false
        navigationInfoLayout.setNeedsLayout()
        travelEstimatedLayout.setNeedsLayout()
        setNeedsLayout()
        layoutIfNeeded()
    }

    func hideOverlays() {
        navigationInfoLayout.isHidden = true
        travelEstimatedLayout.isHidden = true
    }

    func getOverlayWidth() -> CGFloat {
        let marginLeft: CGFloat = 10 * sizeMultiplier
        let overlayWidth = bounds.width * 0.45
        return overlayWidth + marginLeft
    }

    // MARK: - Formatting Helpers

    private func calculateETA(_ remainingSeconds: TimeInterval) -> String {
        let eta = Date().addingTimeInterval(remainingSeconds)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: eta)
    }
}
