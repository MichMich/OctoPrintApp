//
//  ViewController.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 22-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, OctoPrintDelegate {

    
    let octoPrint = OctoPrint()
    
    
    @IBOutlet weak var apiTableViewCell: UITableViewCell!
    @IBOutlet weak var serverTableViewCell: UITableViewCell!
    
    @IBOutlet weak var printerTableViewCell: UITableViewCell!
    
    @IBOutlet weak var bedTableViewCell: UITableViewCell!
    @IBOutlet weak var extruderTableViewCell: UITableViewCell!

    @IBOutlet weak var updateTableViewCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        octoPrint.delegate = self
        octoPrint.updateAll()
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updatePrinterData"), userInfo: nil, repeats: true)

        
        title = "OctoPrint"
    }
    
    func updatePrinterData() {
        octoPrint.updateAll()
    }

    func updateUI() {
        apiTableViewCell.detailTextLabel?.text = String(octoPrint.apiVersion)
        serverTableViewCell.detailTextLabel?.text = String(octoPrint.serverVersion)

        printerTableViewCell.detailTextLabel?.text = octoPrint.printerStateText
        
        bedTableViewCell.detailTextLabel?.text = "\(octoPrint.bedTemperature.actual) (\(octoPrint.bedTemperature.target))"
        
        
        if let extruder = octoPrint.extruderTemperatures["tool0"] {
            extruderTableViewCell.detailTextLabel?.text = "\(extruder.actual) (\(extruder.target))"
        }
        
        if let updated = octoPrint.updateTimeStamp {
            updateTableViewCell.detailTextLabel?.text = "\(updated)"
        } else {
            updateTableViewCell.detailTextLabel?.text = "Never"
        }
        
    }
    
    
    func octoPrintDidUpdate() {
        print("Update timestamp: \(octoPrint.updateTimeStamp)")
        print("API version: \(octoPrint.apiVersion)")
        print("Server version: \(octoPrint.serverVersion)")
        print("Printer State Text: \(octoPrint.printerStateText)")
        print("Printer State Flags \(octoPrint.printerStateFlags)")
        print("Bed temperature: \(octoPrint.bedTemperature)")
        print("Extruder temperatures: \(octoPrint.extruderTemperatures)")
        
        updateUI()
    }

}

