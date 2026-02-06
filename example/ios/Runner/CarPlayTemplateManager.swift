import CarPlay
import UIKit

protocol CarPlayTemplateManagerDelegate: AnyObject {
    func templateManagerDidRequestNavigationReady()
}

class CarPlayTemplateManager {
    // MARK: - Properties

    weak var delegate: CarPlayTemplateManagerDelegate?
    private weak var interfaceController: CPInterfaceController?
    private weak var currentMapTemplate: CPMapTemplate?
    private var waitingTemplate: CPInformationTemplate?
    private var mapTemplateForRestore: CPMapTemplate?

    // MARK: - Initialization

    init(interfaceController: CPInterfaceController?) {
        self.interfaceController = interfaceController
    }

    func updateInterfaceController(_ interfaceController: CPInterfaceController?) {
        self.interfaceController = interfaceController
    }

    // MARK: - Template Creation

    func createInitialMapTemplate() -> CPMapTemplate {
        NSLog("🔵 [TemplateManager] createInitialMapTemplate() called")
        let template = CPMapTemplate()
        template.dismissPanningInterface(animated: false)
        template.automaticallyHidesNavigationBar = true
        currentMapTemplate = template
        return template
    }

    // MARK: - Template Switching

    func showWaitingTemplate() {
        NSLog("🟡 [TemplateManager] showWaitingTemplate() called")

        guard let interfaceController = interfaceController else {
            NSLog("🟡 [TemplateManager] showWaitingTemplate() - no interfaceController yet")
            return
        }

        if waitingTemplate != nil {
            NSLog("🟡 [TemplateManager] showWaitingTemplate() - already showing, skipping")
            return
        }

        NSLog("🟡 [TemplateManager] showWaitingTemplate() - creating and showing waiting template")
        let informationItem = CPInformationItem(
            title: "Waiting",
            detail: "Waiting for navigation session..."
        )

        waitingTemplate = CPInformationTemplate(
            title: "Navigation",
            layout: .leading,
            items: [informationItem],
            actions: []
        )

        if let waitingTemplate = waitingTemplate, let currentTemplate = currentMapTemplate {
            mapTemplateForRestore = currentTemplate

            interfaceController.setRootTemplate(waitingTemplate, animated: true) {
                [weak self] success, error in
                if let error = error {
                    NSLog("🟡 [TemplateManager] showWaitingTemplate() - error: \(error)")
                } else {
                    NSLog("🟡 [TemplateManager] showWaitingTemplate() - success")
                }
            }
        }
    }

    func switchToMapTemplate() {
        NSLog("🟢 [TemplateManager] switchToMapTemplate() called")
        guard let interfaceController = interfaceController else {
            NSLog("🟢 [TemplateManager] switchToMapTemplate() - no interfaceController")
            return
        }

        guard waitingTemplate != nil else {
            NSLog("🟢 [TemplateManager] switchToMapTemplate() - no waiting template, skipping")
            return
        }

        NSLog("🟢 [TemplateManager] switchToMapTemplate() - switching from waiting to map template")
        let mapTemplate =
            mapTemplateForRestore
            ?? {
                let template = CPMapTemplate()
                template.dismissPanningInterface(animated: false)
                template.automaticallyHidesNavigationBar = true
                return template
            }()

        currentMapTemplate = mapTemplate
        mapTemplateForRestore = nil

        interfaceController.setRootTemplate(mapTemplate, animated: true) {
            [weak self] success, error in
            if let error = error {
                NSLog("🟢 [TemplateManager] switchToMapTemplate() - error: \(error)")
            } else {
                NSLog("🟢 [TemplateManager] switchToMapTemplate() - success")
                self?.waitingTemplate = nil
            }
        }
    }

    func isShowingWaitingTemplate() -> Bool {
        return waitingTemplate != nil
    }

    func getCurrentMapTemplate() -> CPMapTemplate? {
        return currentMapTemplate
    }

    // MARK: - Cleanup

    func cleanup() {
        NSLog("🔴 [TemplateManager] cleanup() called")
        waitingTemplate = nil
        mapTemplateForRestore = nil
        currentMapTemplate = nil
    }
}
