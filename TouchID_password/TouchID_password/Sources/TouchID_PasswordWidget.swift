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

class TouchID_PasswordWidget: PKWidget {
    
    static var identifier: String = "com.arnovaneetvelde.TouchID-password"
    var customizationLabel: String = "TouchID_password"
    var view: NSView!
    
    required init() {
        self.view = PKButton(title: "TouchID_password", target: self, action: #selector(printMessage))
    }
    
    @objc private func printMessage() {
        NSLog("[TouchID_PasswordWidget]: Hello, World!")
    }
    
}
