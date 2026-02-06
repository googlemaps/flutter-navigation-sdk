import GoogleNavigation
import UIKit

/// Provides maneuver icons for CarPlay navigation using Google Maps Navigation SDK's native icons.
enum CarPlayManeuverIconConverter {

    /// Returns a maneuver image from the Google Maps Navigation SDK
    /// - Parameters:
    ///   - stepInfo: The navigation step info containing maneuver data
    ///   - pointSize: Desired size for the icon (default: 24)
    ///   - tintColor: Color to apply to the icon (default: white)
    /// - Returns: A UIImage with the maneuver icon, or nil if unavailable
    static func image(
        from stepInfo: GMSNavigationStepInfo,
        pointSize: CGFloat = 24,
        tintColor: UIColor = .white
    ) -> UIImage? {
        guard let maneuverImage = stepInfo.maneuverImage(with: nil) else {
            return UIImage(systemName: "arrow.up")?
                .withConfiguration(
                    UIImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
                )
                .withTintColor(tintColor, renderingMode: .alwaysOriginal)
        }

        let targetSize = CGSize(width: pointSize, height: pointSize)
        guard let resizedImage = resizeImage(image: maneuverImage, targetSize: targetSize) else {
            return maneuverImage
        }

        return resizedImage.withTintColor(tintColor, renderingMode: .alwaysTemplate)
    }

    // MARK: - Private Methods

    /// Resizes an image to fit within target size while maintaining aspect ratio
    private static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)

        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
