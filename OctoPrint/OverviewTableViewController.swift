//
//  ViewController.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 22-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class OverviewTableViewController: UITableViewController {

    
    let sections = ["Version", "State"]
    
    override func viewDidLoad() {
        title = "Info"
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", key: .DidUpdatePrinter, object: OPManager.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", key: .DidUpdateVersion, object: OPManager.sharedInstance)
        
        OPManager.sharedInstance.updateVersion()
        OPManager.sharedInstance.updatePrinter(autoUpdate:1)
        OPManager.sharedInstance.updateSettings()
        
        updateUI()
    }
    
    
 

    func updateUI() {
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
                return 2
            
            case 1:
                return 1
            
            
            default:
                return 0
        }
        
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == tableView.numberOfSections - 1 {
			if let updated = OPManager.sharedInstance.updateTimeStamp {
				let formattedDate = NSDateFormatter.localizedStringFromDate(updated,dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: .MediumStyle)
				return "Last update: \(formattedDate)"
			}
		}
		return nil
	}

	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let shortPath = (indexPath.section, indexPath.row)
        switch shortPath {
            case (0, 0):
                let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath)
                cell.textLabel?.text = "API"
                cell.detailTextLabel?.text = OPManager.sharedInstance.apiVersion
                cell.userInteractionEnabled = false
            return cell
            
            case (0, 1):
                let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath)
                cell.textLabel?.text = "Server"
                cell.detailTextLabel?.text = OPManager.sharedInstance.serverVersion
                cell.userInteractionEnabled = false
                return cell
            
            case (1, 0):
                let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath)
                cell.textLabel?.text = "Printer"
                cell.detailTextLabel?.text = OPManager.sharedInstance.printerStateText
                cell.userInteractionEnabled = false
                return cell
        
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath)
                cell.textLabel?.text = "Unknown cell!"
                return cell
        }
		
	}

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    }
	
}



