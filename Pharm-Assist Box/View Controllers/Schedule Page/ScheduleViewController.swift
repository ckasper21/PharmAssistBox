//
//  ScheduleViewController.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 12/19/18.
//  Copyright © 2018 Chris Kasper. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Foundation

class ScheduleViewController: UITableViewController {
    
    var dispenseNowDB = Dictionary<String, Dictionary<String, String>>()
    var readyToDispense = Set<Int>()
    var handleDPDB: DatabaseHandle!
    
    var ref: DatabaseReference!
    var handleDB: DatabaseHandle!
    
    // Ready to dispense
    var handler2d: DatabaseHandle!

    var handle: AuthStateDidChangeListenerHandle?
    let userID = Auth.auth().currentUser?.uid
    
    let daysWeek = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
    
    // New Dictionaries
    var newMainDic = Dictionary<Int, Dictionary<String, Dictionary<String, String>>>()
    var DayHeaders = [String]()
    var HeadDays = Dictionary<String, [Int]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        navigationItem.title = "Schedule"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.separatorStyle = .none
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(DateHeader.self, forHeaderFooterViewReuseIdentifier: "headerId")

        tableView.sectionHeaderHeight = 50
        
        populateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DayHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (HeadDays[DayHeaders[section]]?.count)!
    }
    
    override func tableView(_ tableView: UITableView,cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ScheduleCell

        let epoch = HeadDays[DayHeaders[indexPath.section]]![indexPath.row] as Int
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        let splitDate = date.description(with: .current).split(separator: " ")
        let time = String(splitDate[5].split(separator: ":")[0] + ":" + splitDate[5].split(separator: ":")[1] + " " + splitDate[6])

        let pillDic = newMainDic[epoch]
        
        var medInfo = ""
        
        if self.readyToDispense.contains(epoch) {
            medInfo = time + " (Ready to Dispense)\n"
            cell.cardBackgroundView.backgroundColor = .red
        } else {
            medInfo = time + "\n"
        }
        
        for key in (pillDic?.keys)! {
            let pillName = pillDic![key]!["name"]
            let numPills = pillDic![key]!["numPills"]
            
            medInfo += "\t\t\t- " + pillName! + " (" + numPills! + ") \n"
        }
        
        for key in (dispenseNowDB.keys) {
            if ((String(epoch)) == dispenseNowDB[key]!["epoch"]) {
                cell.dispenseButton.isEnabled = false
            }
        }
        
        
        cell.medInfoLabel.text = medInfo
        cell.id = String(epoch)
        cell.userid = userID!
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerId") as! DateHeader
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        let date = dateFormatter.date(from: DayHeaders[section])
        let dayName = self.daysWeek[(Calendar.current.component(.weekday, from: date!))-1]
        
        header.nameLabel.text = dayName + " - " + DayHeaders[section]
        //header.nameLabel.text = DayHeaders[section]
        return header
    }
    
    private func populateData() {
        if userID == nil {
            print("No user")
        } else {
            handleDB = ref.child("users").child(userID!).child("schedule").observe(.childAdded, with: { (snapshot) in
                
                if let pillDic = snapshot.value as? NSDictionary {
                    for key in pillDic.allKeys { // epoch Dates
                        let name = snapshot.key
                        let entry = pillDic[key] as! NSDictionary
                        let numPills = String(entry["numPills"] as! Int)
                        let epoch = Int(key as! String)!
                        
                        // Add to dictionary
                        let thisPill = ["name": name, "numPills": numPills]
                        self.addData(pillDic: thisPill, pillName: name, epoch: epoch)

                        // Do sorting here
                        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
                        var stringDate = date.description(with: .current).split(separator: " ")
                        let month = stringDate[1]
                        let day = stringDate[2]
                        let year = stringDate[3]

                        let newDate = month + " " + day + " " + year
                        
                        if !self.DayHeaders.contains(newDate) {
                            self.DayHeaders.append(newDate)
                            var dateArray = [Date]()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMMM d, yyyy"
                            
                            for date in self.DayHeaders {
                                let date = dateFormatter.date(from: date)
                                if let date = date {
                                    dateArray.append(date)
                                }
                            }
                            self.DayHeaders.removeAll()
                            for date in dateArray.sorted(by: {$0.compare($1) == .orderedAscending}) {
                                self.DayHeaders.append(dateFormatter.string(from: date))
                            }
                        
                        }
                        
                        var currentArr = self.HeadDays[newDate]
                        if currentArr == nil {
                            let arr = [epoch]
                            self.HeadDays.updateValue(arr, forKey: newDate)
                        } else {
                            if !currentArr!.contains(epoch) {
                                currentArr?.append(epoch)
                                currentArr?.sort()
                                self.HeadDays.updateValue(currentArr!, forKey: newDate)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, withCancel: nil)
            
            
            handleDPDB = ref.child("users").child(userID!).child("dispenseNow").observe(.childAdded, with: { (snapshot) in
                
                if let dpDic = snapshot.value as? NSDictionary {
                    let epoch = dpDic["epoch"] as! String
                    
                    self.dispenseNowDB.updateValue(["epoch": epoch], forKey: snapshot.key)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }, withCancel: nil)
            
            ref.child("users").child(userID!).child("readyToDispense").observeSingleEvent(of: .value, with: { (snapshot) in
                if let s = snapshot.value as? String {
                    let startIdx = s.index(s.startIndex, offsetBy: 5)
                    let endIdx = s.index(s.endIndex, offsetBy: -3)
                    
                    let subS = String(s[startIdx...endIdx]).split(separator: ",")
                    
                    for epoch in subS {
                        let s = Int(epoch.replacingOccurrences(of: " ", with: ""))!
                        print(s)
                        self.readyToDispense.insert(s)
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    private func addData(pillDic: Dictionary<String,String>, pillName: String, epoch: Int) {
        var currentEpochDic = newMainDic[epoch]
        
        if currentEpochDic == nil {
            let thisPill = [pillName: pillDic]
            newMainDic.updateValue(thisPill, forKey: epoch)
        } else {
            currentEpochDic?.updateValue(pillDic, forKey: pillName)
            newMainDic.updateValue(currentEpochDic!, forKey: epoch)
        }
    }
}
