//
//  SelectTimePicker.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 2/1/19.
//  Copyright © 2019 Chris Kasper. All rights reserved.
//

import UIKit

class SelectTimePicker: UIPickerView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.layer.masksToBounds = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SelectTimeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) || (component == 1) {
            let option = options[component] as! [Int]
            return option.count
        } else {
            let option = options[component] as! [String]
            return option.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) || (component == 1) {
            let option = options[component] as! [Int]
            return String(format: "%02d", option[row])
        } else {
            let option = options[component] as! [String]
            return option[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let hours = options[component] as! [Int]
            hr = String(format: "%02d", hours[row])
            
        } else if component == 1 {
            let mins = options[component] as! [Int]
            min = String(format: "%02d", mins[row])
            
        } else if component == 2 {
            let amPMs = options[component] as! [String]
            amPM = amPMs[row]
        }
        
        if hr == nil {
            hr = "01"
        }
        
        if min == nil {
            min = "00"
        }
        
        if amPM == nil {
            amPM = "AM"
        }
        
        receivedOption = hr! + ":" + min! + " " + amPM!
    }
    
}

