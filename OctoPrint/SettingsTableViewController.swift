//
//  SettingsTableViewController.swift
//  OctoPrint
//
//  Created by Philip Brechler on 28.07.15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit
import AVFoundation

class SettingsTableViewController: UITableViewController, UITextFieldDelegate, QRCodeReaderViewControllerDelegate {
    
    @IBOutlet var hostTextField: UITextField!
    @IBOutlet var apiKeyTextField: UITextField!
    
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"

        self.hostTextField.text = NSUserDefaults.standardUserDefaults().stringForKey("OctoPrintHost") ?? "octopi.local"
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

    @IBAction func scanButtonTapped(sender: AnyObject) {
        if QRCodeReader.supportsMetadataObjectTypes() {
            reader.modalPresentationStyle = .FormSheet
            reader.delegate               = self
            
            reader.completionBlock = { (result: String?) in
                print("Completion with result: \(result)")
            }
            
            presentViewController(reader, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Whoops!", message: "Scanner not supported by the current device.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    
  
    
    // MARK: - QRCodeReader Delegate Methods
    
    func reader(reader: QRCodeReaderViewController, didScanResult result: String) {
        self.dismissViewControllerAnimated(true, completion: { [unowned self] () -> Void in
                self.apiKeyTextField.text = result
        })
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
