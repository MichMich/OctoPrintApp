//
//  TemperatureTableViewController.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 27-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class TemperatureTableViewController: UITableViewController {

    
    let sections = ["Bed", "Tools"]
    
    override func viewDidLoad() {
        title = "Temperature"
        
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", key: .DidUpdatePrinter, object: OPManager.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", key: .DidUpdateVersion, object: OPManager.sharedInstance)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", key: .DidUpdateSettings, object: OPManager.sharedInstance)
        
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
            return 1
            
        case 1:
            return OPManager.sharedInstance.tools.count
            
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
        case (0,_):
            let cell = tableView.dequeueReusableCellWithIdentifier("TemperatureCell", forIndexPath: indexPath)
            let tool = OPManager.sharedInstance.bed
            
            cell.textLabel?.text = tool.identifier
            cell.detailTextLabel?.text = "\(tool.actualTemperature.celciusString()) (\(tool.targetTemperature.celciusString()))"
            return cell
            
        case (1,_):
            let cell = tableView.dequeueReusableCellWithIdentifier("TemperatureCell", forIndexPath: indexPath)
            let tool = OPManager.sharedInstance.tools[indexPath.row]
            
            cell.textLabel?.text = tool.identifier
            cell.detailTextLabel?.text = "\(tool.actualTemperature.celciusString()) (\(tool.targetTemperature.celciusString()))"
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath)
            cell.textLabel?.text = "Unknown cell!"
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowTemperatureSelector", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTemperatureSelector" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let temperatureSelector = segue.destinationViewController as! TemperatureSelectorTableViewController
                
                temperatureSelector.heatedComponent = (indexPath.section == 0) ? OPManager.sharedInstance.bed : OPManager.sharedInstance.tools[indexPath.row]
                
            }
            
        }
    }

}
