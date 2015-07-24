//
//  TemperatureSelectorTableViewController.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 23-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class TemperatureSelectorTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    struct Preset {
        let name:String
        let extruderTemperature:Int
        let bedTemperature:Int
    }
    
    var toolName:String?
    let sections = ["Current","Manual","Presets"]
    let presets = [
        Preset(name: "ABS", extruderTemperature: 240, bedTemperature: 110),
        Preset(name: "HIPS", extruderTemperature: 240, bedTemperature: 100),
        Preset(name: "PLA", extruderTemperature: 200, bedTemperature: 65),
        Preset(name: "XTCopolyester", extruderTemperature: 240, bedTemperature: 60)
    ]

    
    var manualTemperatures = [0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = toolName
        generateManualTemperatures()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUI", name: OctoPrintNotifications.DidUpdatePrinter.rawValue, object: nil)
    }
    
    func updateUI() {
        tableView.reloadData()
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
            case 0:
                return 2
            case 1:
                return 1
            case 2:
                return presets.count
            default:
                return 0
        }
      
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath == NSIndexPath(forRow: 0, inSection: 1) {
            return 100
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell", forIndexPath: indexPath)
        
        if let toolName = toolName, temperature = OctoPrintManager.sharedInstance.temperatures[toolName] {

            let shortPath = (indexPath.section, indexPath.row)
            switch shortPath {
                case (0, 0):
                    cell.textLabel?.text = "Actual"
                    cell.detailTextLabel?.text =  temperature.actual.celciusString()
                    cell.userInteractionEnabled = false
                
                case (0, 1):
                    cell.textLabel?.text = "Target"
                    cell.detailTextLabel?.text = temperature.target.celciusString()
                    cell.userInteractionEnabled = false

                
                case (1,_):
                     let pickerCell = tableView.dequeueReusableCellWithIdentifier("PickerCell", forIndexPath: indexPath) as! PickerTableViewCell
                     pickerCell.pickerView.dataSource = self
                     pickerCell.pickerView.delegate = self

                
                     if let index = manualTemperatures.indexOf(Int(temperature.target)) {
                        pickerCell.pickerView.selectRow(index, inComponent: 0, animated: false)
                     }
                case (2,_):
                    
                    cell.userInteractionEnabled = true
                    
                    let preset = presets[indexPath.row]
                    cell.textLabel?.text = preset.name
                    
                    if OctoPrintManager.sharedInstance.toolTypeForTemperatureIdentifier(toolName ?? "") == .Bed {
                        cell.detailTextLabel?.text =  preset.bedTemperature.celciusString()
                    } else {
                        cell.detailTextLabel?.text =  preset.extruderTemperature.celciusString()
                    }
                
                default:
                break
            }
        }
        return cell
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 2 {
            let preset = presets[indexPath.row]
            let newTargetTemperature:Int
            if OctoPrintManager.sharedInstance.toolTypeForTemperatureIdentifier(toolName ?? "") == .Bed {
                newTargetTemperature =  preset.bedTemperature
            } else {
                newTargetTemperature =  preset.extruderTemperature
            }
            
            setTargetTemperature(Float(newTargetTemperature))
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func generateManualTemperatures() {
        manualTemperatures = []
        
        let toolTemperature = OctoPrintManager.sharedInstance.temperatures[toolName!]
        let currentTargetTemperature = Int(toolTemperature?.target ?? 0)
        
        var maxTemp = 300
        var stepTemp = 5
        
        if OctoPrintManager.sharedInstance.toolTypeForTemperatureIdentifier(toolName ?? "") == .Bed {
            maxTemp = 120
            stepTemp = 5
        }
        
        var temperature:Int
        var currentTemperatureAdded = false
        for temperature = 0; temperature <= maxTemp; temperature += stepTemp {
            
            if temperature == currentTargetTemperature {
                currentTemperatureAdded = true
            }
            
            if !currentTemperatureAdded && temperature > currentTargetTemperature  {
                manualTemperatures.append(currentTargetTemperature)
                currentTemperatureAdded = true
            }
            
            manualTemperatures.append(temperature)
        }
    }
   
    func setTargetTemperature(target:Float) {
        if let toolName = toolName {
            OctoPrintManager.sharedInstance.setTargetTemperature(target, forTool: toolName)
        }
    }

}


// UIPickerViewDataSource
extension TemperatureSelectorTableViewController {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return manualTemperatures.count
    }
    
    
}

// UIPickerViewDelegate
extension TemperatureSelectorTableViewController {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return manualTemperatures[row].celciusString()
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setTargetTemperature(Float(manualTemperatures[row]))
    }
}
