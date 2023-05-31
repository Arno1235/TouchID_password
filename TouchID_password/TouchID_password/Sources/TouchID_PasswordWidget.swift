//
//  TouchID_PasswordWidget.swift
//  TouchID_password
//
//  Created by Arno Van Eetvelde on 31/05/2023.
//  
//

import Foundation
import AppKit
import PockKit
import LocalAuthentication

class TouchID_PasswordWidget: PKWidget {
    
    static var identifier: String = "com.arnovaneetvelde.TouchID-password"
    var customizationLabel: String = "TouchID_password"
    var view: NSView!
    
    required init() {
        self.view = PKButton(title: "ID", target: self, action: #selector(touchID_password))
    }
    
    @objc private func touchID_password() {
        
        authenticateTapped()
        
    }
    
    func authenticateTapped() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                success, authenticationError in

                DispatchQueue.main.async {
                    if success {
                        // Touch ID Success
                        self.type_password(password: self.read_password(filename: "secret.txt"))
                        self.restart_app()
                    } else {
                        // Touch ID Failed
                    }
                }
            }
        } else {
            alert_popup(title:"Touch ID", text: "No touch ID sensor on this device.")
        }
    }
    
    func read_password(filename: String) -> String {

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = dir.appendingPathComponent(filename)
            
            do {
                return try String(contentsOf: fileURL, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
        
        return "error"
        
    }
    
    func type_password(password: String) -> Void {
        let source = CGEventSource(stateID: CGEventSourceStateID.hidSystemState)
        let loc = CGEventTapLocation.cghidEventTap
        
        let password_array = password.components(separatedBy: "\n")
        
        var char = true
        
        var keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
        var keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
        
        for password_char in password_array {
            
            if char {
                
                keyDown = CGEvent(keyboardEventSource: source, virtualKey: UInt16(password_char) ?? 0, keyDown: true)
                keyUp = CGEvent(keyboardEventSource: source, virtualKey: UInt16(password_char) ?? 0, keyDown: false)
                
                char = false
                
            } else {
                
                if password_char == "+" {
                    
                    keyDown?.flags = CGEventFlags.maskShift
                    keyUp?.flags = CGEventFlags.maskShift
                    
                    keyDown?.post(tap: loc)
                    keyUp?.post(tap: loc)
                    
                } else if password_char == "-" {
                    
                    keyDown?.post(tap: loc)
                    keyUp?.post(tap: loc)
                    
                }
                
                char = true
                
            }
            
        }

    }
    
    func restart_app() -> Void {
        
        if let path = Bundle.main.resourceURL?.deletingLastPathComponent().deletingLastPathComponent().absoluteString {
                NSLog("restart \(path)")
                _ = Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [path])
                NSApp.terminate(self)
            }
        
    }
    
    func alert_popup(title: String, text: String) -> Void {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
}
