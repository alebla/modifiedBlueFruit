//
//  ControllerPadViewController.swift
//  Bluefruit Connect
//
//  Created by Antonio García on 12/02/16.
//  Copyright © 2016 Adafruit. All rights reserved.
//

import UIKit
import Foundation
import GameController
import CoreMotion

protocol ControllerPadViewControllerDelegate: class {
    func onSendControllerPadButtonStatus(tag: Int, isPressed: Bool)
}

class ControllerPadViewController: UIViewController {

    // UI
    @IBOutlet weak var coreMotionSwitch: UISwitch!
    @IBOutlet weak var directionsView: UIView!
    @IBOutlet weak var numbersView: UIView!
//    @IBOutlet weak var uartTextView: UITextView!
//    @IBOutlet weak var uartView: UIView!
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    // Data
    weak var delegate: ControllerPadViewControllerDelegate?
    var playerIndex = GCControllerPlayerIndex.index1
    var userController = GCController()
    var directions = [UIButton]()
    var numbers = [UIButton]()
    var parentControllerModuleManager: ControllerModuleManager!
    
    // Core Motion
    var coreMotionManager = gCoreMotionManager

    override func viewDidLoad() {
        super.viewDidLoad()
        // UI
        
        if coreMotionManager.isAccelerometerActive {
            coreMotionSwitch.setOn(true, animated: false)
        } else {
            coreMotionSwitch.setOn(false, animated: false)
        }
//        uartView.layer.cornerRadius = 4
//        uartView.layer.masksToBounds = true
        
        // Locks the interface to the right
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
       
        // Setup buttons targets
        for subview in directionsView.subviews {
            if let button = subview as? UIButton {
                directions.append(button)
                setupButton(button)
            }
        }

        for subview in numbersView.subviews {
            if let button = subview as? UIButton {
                numbers.append(button)
                setupButton(button)
            }
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        startWatchingForControllers()
        checkForConnectedControllers()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startWatchingForControllers()
        checkForConnectedControllers()


        // Fix: remove the UINavigationController pop gesture to avoid problems with the arrows left button
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.interactivePopGestureRecognizer?.delaysTouchesBegan = false
            self.navigationController?.interactivePopGestureRecognizer?.delaysTouchesEnded = false
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopWatchingForControllers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    // MARK: - UI
    // Here we can make some UI changes to the game pad buttons
    fileprivate func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.masksToBounds = true

        button.setTitleColor(UIColor.lightGray, for: .highlighted)

        let hightlightedImage = UIImage(color: UIColor.darkGray)
        button.setBackgroundImage(hightlightedImage, for: .highlighted)

        button.addTarget(self, action: #selector(onTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(onTouchUp(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(onTouchUp(_:)), for: .touchDragExit)
        button.addTarget(self, action: #selector(onTouchUp(_:)), for: .touchCancel)
    }

//    func setUartText(_ text: String) {
//
//        // Remove the last character if is a newline character
//        let lastCharacter = text.last
//        let shouldRemoveTrailingNewline = lastCharacter == "\n" || lastCharacter == "\r" //|| lastCharacter == "\r\n"
//        //let formattedText = shouldRemoveTrailingNewline ? text.substring(to: text.index(before: text.endIndex)) : text
//        let formattedText = shouldRemoveTrailingNewline ? String(text[..<text.index(before: text.endIndex)]) : text
//        
//        //
//        //uartTextView.text = formattedText
//
//        // Scroll to bottom
//        let bottom = max(0, uartTextView.contentSize.height - uartTextView.bounds.size.height)
//        //uartTextView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
//        /*
//        let textLength = text.characters.count
//        if textLength > 0 {
//            let range = NSMakeRange(textLength - 1, 1)
//            uartTextView.scrollRangeToVisible(range)
//        }*/
//    }

    // MARK: - Actions
    @objc func onTouchDown(_ sender: UIButton) {
        sendTouchEvent(tag: sender.tag, isPressed: true)
        print("senderTag: \(sender.tag)")
    }

    @objc func onTouchUp(_ sender: UIButton) {
        sendTouchEvent(tag: sender.tag, isPressed: false)
        //print("senderTag: \(sender.tag)")
    }

    private func sendTouchEvent(tag: Int, isPressed: Bool) {
        if let delegate = delegate {
            delegate.onSendControllerPadButtonStatus(tag: tag, isPressed: isPressed)
        }
    }

    @IBAction func onClickHelp(_ sender: UIBarButtonItem) {
        let localizationManager = LocalizationManager.shared
        let helpViewController = storyboard!.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
        helpViewController.setHelp(localizationManager.localizedString("controlpad_help_text"), title: localizationManager.localizedString("controlpad_help_title"))
        let helpNavigationController = UINavigationController(rootViewController: helpViewController)
        helpNavigationController.modalPresentationStyle = .popover
        helpNavigationController.popoverPresentationController?.barButtonItem = sender

        present(helpNavigationController, animated: true, completion: nil)
    }
    
    @IBAction func didPressSwitch(_ sender: UISwitch) {
        print("switch pressed")
        if gCoreMotionManager.isAccelerometerActive {
            parentControllerModuleManager.setSensorEnabled(false, index: 1)
//             gCoreMotionManager.stopAccelerometerUpdates()
            return
        }
//        gCoreMotionManager.startAccelerometerUpdates()
        parentControllerModuleManager.setSensorEnabled(true, index: 1)
    }
    
    
    
    //MARK: Controller Mirroring
    
    
    
    //MARK: MFI Controller
    
    func startWatchingForControllers() {
        // Subscribe for the notes
        let ctr = NotificationCenter.default
        ctr.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { note in
            if let ctrl = note.object as? GCController {
                self.add(ctrl)
            }
        }
        ctr.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { note in
            if let ctrl = note.object as? GCController {
                self.remove(ctrl)
            }
        }
        // and kick off discovery
        GCController.startWirelessControllerDiscovery(completionHandler: {})
    }
    
    func stopWatchingForControllers() {
        // Same as the first, 'cept in reverse!
        GCController.stopWirelessControllerDiscovery()
        
        let ctr = NotificationCenter.default
        ctr.removeObserver(self, name: .GCControllerDidConnect, object: nil)
        ctr.removeObserver(self, name: .GCControllerDidDisconnect, object: nil)
    }
    
    // We check to see if we need to look for conrtollers or if we should just start listening for commands
    func checkForConnectedControllers() {
        let controllers: [GCController] = GCController.controllers()
        if controllers.isEmpty {
            print("No controllers found : \(controllers)")
            //TODO: FIX
            //Warning: Attempt to present <UIAlertController: 0x1030d5200> on <iOS.ControllerPadViewController: 0x102791010> whose view is not in the window hierarchy!
//            let ac = UIAlertController(title: "No controllers found", message: nil, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            self.present(ac, animated: true)
        } else {
            print(controllers)
        }
    }
    
    func add(_ controller: GCController) {
        let name = String(describing:controller.vendorName)
        userController = controller
        userController.gamepad?.valueChangedHandler = { (gamepad, element) in
//            switch gamepad {
//            case gamepad.buttonA:
//                print("A")
//            case gamepad.buttonB:
//                print("B")
//            case gamepad.buttonX:
//                print("X")
//            case gamepad.buttonY:
//                print("Y")
//            case gamepad.dpad.down:
//                print("down")
//            case gamepad.dpad.up:
//                print("up")
//            case gamepad.dpad.left:
//                print("left")
//            case gamepad.dpad.right:
//                print("right")
//
//            default:
//                print("Somethings weird")
//            }
            
            if let dpad = element as? GCControllerDirectionPad {
                if dpad.down.isPressed {
                    self.onTouchDown(self.directions[1])
                    print("down")
                }
                
                if dpad.up.isPressed {
                    self.onTouchDown(self.directions[0])
                    print("up")
                }
                
                if dpad.left.isPressed {
                    self.onTouchDown(self.directions[2])
                    print("left")
                }
                
                if dpad.right.isPressed {
                    self.onTouchDown(self.directions[3])
                    print("right")
                }
                
            } else if let number = element as? GCControllerButtonInput {
                if gamepad.buttonA.isPressed {
                    self.onTouchDown(self.numbers[1])
                    print("a for 3")
                }
                
                if gamepad.buttonB.isPressed {
                    self.onTouchDown(self.numbers[2])
                    print("b for 4")
                }
                
                if gamepad.buttonX.isPressed {
                    self.onTouchDown(self.numbers[3])
                    print("x for 1")

                }
                
                if gamepad.buttonY.isPressed {
                    self.onTouchDown(self.numbers[0])
                    print("y for 2")
                }
            } else {
                print("OTHR : \( element )")
            }
        }
        if let gamepad = controller.extendedGamepad {
            print("connect extended \(name, gamepad)")
        } else if let gamepad = controller.microGamepad {
            print("connect micro \(name, gamepad)")
        } else {
            print("Huh? \(name)")
        }
    }
    
    func remove(_ controller: GCController) {
        
    }
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("Pressed")
    }
    
    func incrementPlayerIndex() -> GCControllerPlayerIndex {
        switch playerIndex {
        case .index1:
            playerIndex = .index2
        case .index2:
            playerIndex = .index3
        case .index3:
            playerIndex = .index4
        default:
            playerIndex = .index1
        }
        return playerIndex
    }
}
