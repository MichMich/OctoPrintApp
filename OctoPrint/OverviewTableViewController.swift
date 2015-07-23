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
    let sections = ["Version", "State", "Temperatures"]
    
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
            
            case 2:
                return octoPrint.temperatures.count
            
            default:
                return 0
        }
        
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
	override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		if section == tableView.numberOfSections - 1 {
			if let updated = octoPrint.updateTimeStamp {
				let formattedDate = NSDateFormatter.localizedStringFromDate(updated,dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: .MediumStyle)
				return "Last update: \(formattedDate)"
			}
		}
		return nil
	}

	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath)
        
        let shortPath = (indexPath.section, indexPath.row)
        switch shortPath {
            case (0, 0):
                cell.textLabel?.text = "API"
                cell.detailTextLabel?.text = octoPrint.apiVersion
            
            case (0, 1):
                cell.textLabel?.text = "Server"
                cell.detailTextLabel?.text = octoPrint.serverVersion
            
            case (1, 0):
                cell.textLabel?.text = "Printer"
                cell.detailTextLabel?.text = octoPrint.printerStateText
            
            case (2,_):
                let cell = tableView.dequeueReusableCellWithIdentifier("TemperatureCell", forIndexPath: indexPath)
                
            
                var names:[String] = []
                for (name, _) in octoPrint.temperatures {
                    names.append(name)
                }
                
                if let temperature = octoPrint.temperatures[names[indexPath.row]] {
                    
                    cell.textLabel?.text = names[indexPath.row]
                    cell.detailTextLabel?.text = "\(temperature.actual) (\(temperature.target))"
                }
            
            
            default:
                break
        }
        
        return cell
		
	}
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 2 {
            performSegueWithIdentifier("ShowTemperatureSelector", sender: self)
        } else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
	
}


// OctoPrintDelegate Methods
extension OverviewTableViewController {
    func octoPrintDidUpdate() {
        updateUI()
    }
}

