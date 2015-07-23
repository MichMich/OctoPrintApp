//
//  ViewController.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 22-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class OverviewTableViewController: UITableViewController, OctoPrintDelegate {

    
    let octoPrint = OctoPrint()
    
    
    @IBOutlet weak var apiTableViewCell: UITableViewCell!
    @IBOutlet weak var serverTableViewCell: UITableViewCell!
    
    @IBOutlet weak var printerTableViewCell: UITableViewCell!

    
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
	
        tableView.reloadData()
        
    }
    
	func temperatureArray() -> [String:Temperature] {
		var temperatureArray: [String:Temperature] = [:]
		
		temperatureArray["Bed"] = octoPrint.bedTemperature
		
		return temperatureArray
	}
	

	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		// Display updated timestamp below last section.
		if section == tableView.numberOfSections - 1 {
			if let updated = octoPrint.updateTimeStamp {
				let formattedDate = NSDateFormatter.localizedStringFromDate(updated,dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: .MediumStyle)
				return "Last update: \(formattedDate)"
			}
		}
		return nil
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if section == tableView.numberOfSections - 1 {
			return 1 //temperatureArray().count
		}

		return super.tableView(tableView, numberOfRowsInSection: section)
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		if indexPath.section == tableView.numberOfSections - 1 {
			return 50
		}
		
		return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if indexPath.section == tableView.numberOfSections - 1 {
			let cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "Whoot")
			cell.textLabel?.text = "Whoot! \(indexPath.row)"
			return cell
		}
		
		return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
	}
	
}


// OctoPrintDelegate Methods
extension OverviewTableViewController {
    func octoPrintDidUpdate() {
        updateUI()
    }
}

