//
//  NeopixelComponentSelectorViewController.swift
//  Bluefruit Connect
//
//  Created by Antonio García on 31/05/17.
//  Copyright © 2016 Adafruit. All rights reserved.
//

import UIKit

class NeopixelComponentSelectorViewController: UIViewController {

    // UI
    @IBOutlet weak var baseTableView: UITableView!

    // Params
    var selectedComponent: NeopixelModuleManager.Components?
    var is400HkzEnabled = false
    var onSetComponents: ((_ components: NeopixelModuleManager.Components, _ is400HkzEnabled: Bool) -> Void)?

    // Data
    fileprivate var components = NeopixelModuleManager.Components.all

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        //preferredContentSize = CGSize(width: preferredContentSize.width, height: baseTableView.contentSize.height)
    }
}

// MARK: - UITableViewDataSource
extension NeopixelComponentSelectorViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var titleId: String?
        switch section {
        case 0:
            titleId = "neopixelcomponentselector_speed_title"
        case 1:
            titleId = "neopixelcomponentselector_pixelorder_title"
        default:
            break
        }
        
        if let titleId = titleId {
            return LocalizationManager.shared.localizedString(titleId).uppercased()
        }
        else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return components.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reuseIdentifier: String
        if indexPath.section == 0 {
            reuseIdentifier = "SwitchCell"
        } else {
            reuseIdentifier = "TextCell"
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NeopixelComponentSelectorViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let uartCell = cell as? UartSettingTableViewCell else { return }

        if indexPath.section == 0 {
            uartCell.titleLabel?.text = LocalizationManager.shared.localizedString("neopixelcomponentselector_speed_400khz")
            uartCell.switchControl.isOn = is400HkzEnabled
            uartCell.onSwitchEnabled = { [unowned self] isEnabled in
                self.is400HkzEnabled = isEnabled
                if let selectedComponent = self.selectedComponent {
                    self.onSetComponents?(selectedComponent, self.is400HkzEnabled)
                }
            }
        } else {
            let component = components[indexPath.row]
            uartCell.titleLabel?.text = component.name
            uartCell.accessoryType = selectedComponent == component ? .checkmark:.none
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            tableView.deselectRow(at: indexPath, animated: indexPath.section == 0)

            let component = components[indexPath.row]

            selectedComponent = component
            baseTableView.reloadData()
            onSetComponents?(component, is400HkzEnabled)
            
            dismiss(animated: true, completion: nil)
        }
    }
}
