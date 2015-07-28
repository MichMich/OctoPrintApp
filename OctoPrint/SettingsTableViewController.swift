//
//  SettingsTableViewController.swift
//  OctoPrint
//
//  Created by Philip Brechler on 28.07.15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController,UITextFieldDelegate {
    
    @IBOutlet var hostTextField: UITextField!
    @IBOutlet var apiKeyTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hostTextField.text = NSUserDefaults.standardUserDefaults().stringForKey("OctoPrintHost")
        self.apiKeyTextField.text = NSUserDefaults.standardUserDefaults().stringForKey("OctoPrintAPIKey")
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSUserDefaults.standardUserDefaults().setObject(self.hostTextField.text, forKey: "OctoPrintHost")
        NSUserDefaults.standardUserDefaults().setObject(self.apiKeyTextField.text, forKey: "OctoPrintAPIKey")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.hostTextField {
            self.apiKeyTextField.becomeFirstResponder()
        } else {
            self.apiKeyTextField.resignFirstResponder()
        }
        NSUserDefaults.standardUserDefaults().setObject(self.hostTextField.text, forKey: "OctoPrintHost")
        NSUserDefaults.standardUserDefaults().setObject(self.apiKeyTextField.text, forKey: "OctoPrintAPIKey")
        return true
    }

}
