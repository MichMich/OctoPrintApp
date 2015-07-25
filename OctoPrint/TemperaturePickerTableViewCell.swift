//
//  PickerTableViewCell.swift
//  OctoPrint
//
//  Created by Michael Teeuw on 23-07-15.
//  Copyright © 2015 Michael Teeuw. All rights reserved.
//

import UIKit

class TemperaturePickerTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    let pickerView = UIPickerView()
    
    var temperatures:[Float] = []

    var temperature:Float = 0 {
        didSet {
            updateUI()
        }
    }
    var minTemp:Float = 0 {
        didSet {
            updateUI()
        }
    }
    var maxTemp:Float = 0 {
        didSet {
            updateUI()
        }
    }
    var stepSize:Float = 1 {
        didSet {
            updateUI()
        }
    }
    
    var delegate:TemperaturePickerTableViewCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setup()
    }

 
    func setup() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        self.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: pickerView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    func updateUI() {
        
        generateTemperatures()
        pickerView.reloadComponent(0)
        if let index = temperatures.indexOf(temperature) {
           pickerView.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    func generateTemperatures() {
  
        temperatures = []
        
        var temp:Float
        var currentTemperatureAdded = false
        for temp = minTemp; temp <= maxTemp; temp += stepSize {
            
            if temp == temperature {
                currentTemperatureAdded = true
            }
            
            if !currentTemperatureAdded && temp > temperature  {
                
                temperatures.append(temperature)
                currentTemperatureAdded = true
            }
            
            temperatures.append(temp)
        }
    }
    
}

// UIPickerViewDataSource
extension TemperaturePickerTableViewCell {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return temperatures.count
    }
    
}

// UIPickerViewDelegate
extension TemperaturePickerTableViewCell {
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        temperature = temperatures[row]
        delegate?.temperaturePickerCellDidUpdate(self)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return temperatures[row].celciusString()
    }
}

protocol TemperaturePickerTableViewCellDelegate {
    func temperaturePickerCellDidUpdate(temperaturePickerCell:TemperaturePickerTableViewCell)
}
