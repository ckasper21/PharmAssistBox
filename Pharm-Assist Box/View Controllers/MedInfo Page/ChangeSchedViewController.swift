//
//  ChangeSchedViewController.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 4/5/19.
//  Copyright © 2019 Chris Kasper. All rights reserved.
//

import UIKit
import Firebase

class ChangeSchedViewController: UIViewController, SelectViewControllerDelegate, SelectTimeViewControllerDelegate, UITextFieldDelegate {
    
    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    var pill: String?
    var pillsLeft: Int = 0
    var timesPerDay: Int = 0
    
    struct currentUser {
        static var uid = ""
    }
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor(red:0.53, green:0.80, blue:0.92, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentSize.height = 1300
        
        return view
    }()
    
    let heading: UILabel = {
        let label = UILabel()
        label.text = "Changing schedule for"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let pillLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let numPerLabel: UILabel = {
        let label = UILabel()
        label.text = "How many pills will you take per dosage?"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let numPerText: UITextField = {
        let text = UITextField()
        text.text = "Ex: 1"
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.boldSystemFont(ofSize: 18)
        text.backgroundColor = UIColor.white
        text.layer.cornerRadius = 5
        text.clipsToBounds = true
        text.textAlignment = .center
        return text
    }()
    
    let oftenLabel: UILabel = {
        let label = UILabel()
        label.text = "How often will you take this medication?"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let oftenButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(ChangeSchedViewController.oftenFunc), for: .touchUpInside)
        return button
    }()
    
    let changeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(ChangeSchedViewController.submitMed), for: .touchUpInside)
        return button
    }()
    
    let timeLabels: [UITextView] = {
        let fields = ["Time 1","Time 2","Time 3","Time 4"]
        var arr = [UITextView]()
        for field in fields {
            let text = UITextView()
            text.text = field
            text.font = UIFont.boldSystemFont(ofSize: 20)
            text.translatesAutoresizingMaskIntoConstraints = false
            text.backgroundColor = nil
            text.isEditable = false
            text.isScrollEnabled = false
            text.isUserInteractionEnabled = false
            
            arr.append(text)
        }
        return arr
    }()
    
    let timeButtons: [UIButton] = {
        var arr = [UIButton]()
        for i in 0...3 {
            let button = UIButton(type: .system)
            button.setTitle("Select Time", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 18)
            button.backgroundColor = UIColor.white
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.translatesAutoresizingMaskIntoConstraints = false
            
            if i == 0 {
                button.addTarget(self, action: #selector(ChangeSchedViewController.timeFunc0), for: .touchUpInside)
            } else if i == 1 {
                button.addTarget(self, action: #selector(ChangeSchedViewController.timeFunc1), for: .touchUpInside)
            } else if i == 2 {
                button.addTarget(self, action: #selector(ChangeSchedViewController.timeFunc2), for: .touchUpInside)
            } else if i == 3 {
                button.addTarget(self, action: #selector(ChangeSchedViewController.timeFunc3), for: .touchUpInside)
            }
            
            arr.append(button)
        }
        return arr
    }()
    
    @objc func timeFunc0() {
        let selectTimeVC = SelectTimeViewController()
        selectTimeVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        selectTimeVC.delegate = self
        
        selectTimeVC.id = 0;
        present(selectTimeVC, animated: true, completion: nil)
    }
    
    @objc func timeFunc1() {
        let selectTimeVC = SelectTimeViewController()
        selectTimeVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        selectTimeVC.delegate = self
        
        selectTimeVC.id = 1;
        present(selectTimeVC, animated: true, completion: nil)
    }
    
    @objc func timeFunc2() {
        let selectTimeVC = SelectTimeViewController()
        selectTimeVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        selectTimeVC.delegate = self
        
        selectTimeVC.id = 2;
        present(selectTimeVC, animated: true, completion: nil)
    }
    
    @objc func timeFunc3() {
        let selectTimeVC = SelectTimeViewController()
        selectTimeVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        selectTimeVC.delegate = self
        
        selectTimeVC.id = 3;
        present(selectTimeVC, animated: true, completion: nil)
    }
    
    @objc func oftenFunc() {
        let selectVC = SelectViewController()
        selectVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        selectVC.delegate = self
        present(selectVC, animated: true, completion: nil)
    }
    
    func didFinishSelectTimeView(controller: SelectTimeViewController) {
        print("In didFinishTimeSV in AddMedVC")
        if controller.receivedOption != nil {
            timeButtons[controller.id!].setTitle(controller.receivedOption,for:.normal)
        }
    }
    
    func didFinishSelectView(controller: SelectViewController) {
        print("In didFinishSV in AddMedVC")
        if controller.receivedOption != nil && controller.receivedOption != "Select" {
            oftenButton.setTitle(controller.receivedOption,for:.normal)
            let freq = oftenButton.title(for: .normal)
            
            if freq == "Once a day" {
                timesPerDay = 1
                
            } else if freq == "Two times a day" {
                timesPerDay = 2
                
            } else if freq == "Three times a day" {
                timesPerDay = 3
                
            } else if freq == "Four times a day" {
                timesPerDay = 4
            }
            
            setupTimePickers()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Change Schedule"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                currentUser.uid = user.uid
            }
        }
        
        numPerText.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChangeSchedViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setupLayout()
    }
    
    private func setupTimePickers() {
        changeButton.removeFromSuperview()
        var idx = 0;
        
        if timesPerDay == 1 {
            oftenButton.setTitle("Once a day", for: .normal)
            idx = 0
        } else if timesPerDay == 2 {
            oftenButton.setTitle("Two times a day", for: .normal)
            idx = 1
            
        } else if timesPerDay == 3 {
            oftenButton.setTitle("Three times a day", for: .normal)
            idx = 2
            
        } else if timesPerDay == 4 {
            oftenButton.setTitle("Four times a day", for: .normal)
            idx = 3
        }
        
        let freq = oftenButton.title(for: .normal)
        
        scrollView.addSubview(timeLabels[0])
        scrollView.addSubview(timeButtons[0])
        timeLabels[0].topAnchor.constraint(equalTo: oftenButton.bottomAnchor, constant: 20).isActive = true
        timeLabels[0].centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        timeButtons[0].topAnchor.constraint(equalTo: timeLabels[0].bottomAnchor, constant: 10).isActive = true
        timeButtons[0].centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        timeButtons[0].heightAnchor.constraint(equalToConstant: 50).isActive = true
        timeButtons[0].widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        scrollView.addSubview(timeLabels[1])
        scrollView.addSubview(timeButtons[1])
        timeLabels[1].topAnchor.constraint(equalTo: timeButtons[0].bottomAnchor, constant: 20).isActive = true
        timeLabels[1].centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        timeButtons[1].topAnchor.constraint(equalTo: timeLabels[1].bottomAnchor, constant: 10).isActive = true
        timeButtons[1].centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        timeButtons[1].heightAnchor.constraint(equalToConstant: 50).isActive = true
        timeButtons[1].widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        scrollView.addSubview(timeLabels[2])
        scrollView.addSubview(timeButtons[2])
        timeLabels[2].topAnchor.constraint(equalTo: timeButtons[1].bottomAnchor, constant: 20).isActive = true
        timeLabels[2].centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        timeButtons[2].topAnchor.constraint(equalTo: timeLabels[2].bottomAnchor, constant: 10).isActive = true
        timeButtons[2].centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        timeButtons[2].heightAnchor.constraint(equalToConstant: 50).isActive = true
        timeButtons[2].widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        scrollView.addSubview(timeLabels[3])
        scrollView.addSubview(timeButtons[3])
        timeLabels[3].topAnchor.constraint(equalTo: timeButtons[2].bottomAnchor, constant: 20).isActive = true
        timeLabels[3].centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        timeButtons[3].topAnchor.constraint(equalTo: timeLabels[3].bottomAnchor, constant: 10).isActive = true
        timeButtons[3].centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        timeButtons[3].heightAnchor.constraint(equalToConstant: 50).isActive = true
        timeButtons[3].widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        scrollView.addSubview(changeButton)
        
        if freq == "Once a day" {
            timeButtons[3].removeFromSuperview()
            timeLabels[3].removeFromSuperview()
            timeButtons[2].removeFromSuperview()
            timeLabels[2].removeFromSuperview()
            timeButtons[1].removeFromSuperview()
            timeLabels[1].removeFromSuperview()
            scrollView.contentSize.height = 700
            
        } else if freq == "Two times a day" {
            timeButtons[3].removeFromSuperview()
            timeLabels[3].removeFromSuperview()
            timeButtons[2].removeFromSuperview()
            timeLabels[2].removeFromSuperview()
            scrollView.contentSize.height = 750
            
        } else if freq == "Three times a day" {
            timeButtons[3].removeFromSuperview()
            timeLabels[3].removeFromSuperview()
            scrollView.contentSize.height = 800
            
            
        } else if freq == "Four times a day" {
            scrollView.contentSize.height = 900
        }
        
        setChangeButton(idx: idx)
    }
    
    private func setChangeButton(idx: Int) {
        changeButton.topAnchor.constraint(equalTo: timeButtons[idx].bottomAnchor, constant: 40).isActive = true
        changeButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        changeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        changeButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    @objc func submitMed() {
        // Check to make sure form was filled out
        var flag = 0
        var numPer: Int = 0
        
        // Check textfields
        if let pillsPer = Int(numPerText.text!) {
            numPer = pillsPer
        } else {
            print("Invalid number")
            flag = 1
        }
        
        // Check frequency buttons
        if oftenButton.title(for: .normal) == "Select" {
            flag = 1
        } else {
            for i in 0...timesPerDay-1 {
                if timeButtons[i].title(for: .normal) == "Select Time" {
                    flag = 1
                }
            }
        }
        
        // Alert user of error
        if flag == 1 {
            let alert = UIAlertController(title: "Ut oh...", message: "Please make sure you fill out the form before submitting", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
            }))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        print("No errors, lets submit the data to Firebase!")
        
        let alert = UIAlertController(title: "Confirm", message: "Please confirm that you want to submit this medication to Pharm-Assist Box", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (nil) in
            // First add the medication to the user's database
            self.ref = Database.database().reference()
            self.ref.child("users").child(currentUser.uid).child("medications").child(self.pill!).child("numPer").setValue(String(numPer), withCompletionBlock: { (error, ref)  in
                if error != nil {
                    print("Failed to upload medication info")
                    let alert = UIAlertController(title: "Ut oh", message: "There was an issue processing your request, please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
                        return
                    }))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    return
                }})
            
            self.ref.child("users").child(currentUser.uid).child("medications").child(self.pill!).child("tpd").setValue(String(self.timesPerDay), withCompletionBlock: { (error, ref)  in
                if error != nil {
                    print("Failed to upload medication info")
                    let alert = UIAlertController(title: "Ut oh", message: "There was an issue processing your request, please try again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
                        return
                    }))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    return
                }})
            
            // Now need to create schedule, does Firebase push too
            self.createSchedule()
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (nil) in
            return
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        return
        
    }
    
    private func createSchedule() {
        var pillSchedule = Dictionary<String, Dictionary<String,Int>>()
        var numPills = pillsLeft
        var numPer: Int = 0
        
        if let pillsPer = Int(numPerText.text!) {
            numPer = pillsPer
        } else {
            print("Invalid number")
            return
        }
        
        let pillName = pill
        
        let formatter = DateFormatter()
        formatter.defaultDate = Calendar.current.startOfDay(for: Date())
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mm a"
        
        var daysToAdd = 0
        
        let curDate = Date()
        let curDateSec = String(String(curDate.timeIntervalSince1970).split(separator: ".")[0])
        
        // TODO: Check if schedule for this medication exists, add to end if so
        
        if timesPerDay == 1 {
            let time1 = timeButtons[0].title(for: .normal)
            let date = formatter.date(from: time1!)
            
            while numPills != 0 {
                let newDate = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date!)
                let seconds = String(String(newDate!.timeIntervalSince1970).split(separator: ".")[0])
                
                if seconds > curDateSec {
                    pillSchedule[seconds] = ["numPills": numPer]
                    numPills = numPills - numPer
                }
                
                daysToAdd += 1
            }
            
            
        } else if timesPerDay == 2 {
            let time1 = timeButtons[0].title(for: .normal)
            let time2 = timeButtons[1].title(for: .normal)
            
            let date1 = formatter.date(from: time1!)
            let date2 = formatter.date(from: time2!)
            
            while numPills != 0 {
                
                if numPills != 0 {
                    let newDate1 = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date1!)
                    let seconds1 = String(String(newDate1!.timeIntervalSince1970).split(separator: ".")[0])
                    
                    if seconds1 > curDateSec {
                        pillSchedule[seconds1] = ["numPills": numPer]
                        numPills = numPills - numPer
                    }
                }
                
                if numPills != 0 {
                    let newDate2 = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date2!)
                    let seconds2 = String(String(newDate2!.timeIntervalSince1970).split(separator: ".")[0])
                    
                    if seconds2 > curDateSec {
                        pillSchedule[seconds2] = ["numPills": numPer]
                        numPills = numPills - numPer
                    }
                }
                
                daysToAdd += 1
            }
            
        } else if timesPerDay == 3 {
            let time1 = timeButtons[0].title(for: .normal)
            let time2 = timeButtons[1].title(for: .normal)
            let time3 = timeButtons[2].title(for: .normal)
            
            let date1 = formatter.date(from: time1!)
            let date2 = formatter.date(from: time2!)
            let date3 = formatter.date(from: time3!)
            
            while numPills != 0 {
                
                if numPills != 0 {
                    let newDate1 = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date1!)
                    let seconds1 = String(String(newDate1!.timeIntervalSince1970).split(separator: ".")[0])
                    
                    if seconds1 > curDateSec {
                        pillSchedule[seconds1] = ["numPills": numPer]
                        numPills = numPills - numPer
                    }
                    
                }
                
                if numPills != 0 {
                    let newDate2 = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date2!)
                    let seconds2 = String(String(newDate2!.timeIntervalSince1970).split(separator: ".")[0])
                    
                    if seconds2 > curDateSec {
                        pillSchedule[seconds2] = ["numPills": numPer]
                        numPills = numPills - numPer
                    }
                }
                
                if numPills != 0 {
                    let newDate3 = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date3!)
                    let seconds3 = String(String(newDate3!.timeIntervalSince1970).split(separator: ".")[0])
                    
                    if seconds3 > curDateSec {
                        pillSchedule[seconds3] = ["numPills": numPer]
                        numPills = numPills - numPer
                    }
                    
                }
                
                daysToAdd += 1
            }
            
        } else if timesPerDay == 4 {
            let time1 = timeButtons[0].title(for: .normal)
            let time2 = timeButtons[1].title(for: .normal)
            let time3 = timeButtons[2].title(for: .normal)
            let time4 = timeButtons[3].title(for: .normal)
            
            let date1 = formatter.date(from: time1!)
            let date2 = formatter.date(from: time2!)
            let date3 = formatter.date(from: time3!)
            let date4 = formatter.date(from: time4!)
            
            while numPills != 0 {
                if numPills != 0 {
                    let newDate1 = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date1!)
                    let seconds1 = String(String(newDate1!.timeIntervalSince1970).split(separator: ".")[0])
                    
                    if seconds1 > curDateSec {
                        pillSchedule[seconds1] = ["numPills": numPer]
                        numPills = numPills - numPer
                    }
                    
                }
                
                if numPills != 0 {
                    let newDate2 = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date2!)
                    let seconds2 = String(String(newDate2!.timeIntervalSince1970).split(separator: ".")[0])
                    
                    if seconds2 > curDateSec {
                        pillSchedule[seconds2] = ["numPills": numPer]
                        numPills = numPills - numPer
                    }
                }
                
                if numPills != 0 {
                    let newDate3 = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date3!)
                    let seconds3 = String(String(newDate3!.timeIntervalSince1970).split(separator: ".")[0])
                    
                    if seconds3 > curDateSec {
                        pillSchedule[seconds3] = ["numPills": numPer]
                        numPills = numPills - numPer
                    }
                    
                }
                
                if numPills != 0 {
                    let newDate4 = Calendar.current.date(byAdding: .day, value: daysToAdd, to: date4!)
                    let seconds4 = String(String(newDate4!.timeIntervalSince1970).split(separator: ".")[0])
                    
                    if seconds4 > curDateSec {
                        pillSchedule[seconds4] = ["numPills": numPer]
                        numPills = numPills - numPer
                    }
                }
                
                daysToAdd += 1
            }
        }
        
        self.ref = Database.database().reference()

        self.ref.child("users").child(currentUser.uid).child("schedule").child(pillName!).setValue(pillSchedule, withCompletionBlock: { (error, ref)  in
            if error != nil {
                print("Failed to change schedule")
                let alert = UIAlertController(title: "Ut oh", message: "There was an issue processing your request, please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
                    return
                }))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            else{
                print("Success in changing schedule")
                let alert = UIAlertController(title: "Medication added", message: "Schedule was successfully changed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
                    return
                }))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            
        })
        
        let refUpdate = Database.database().reference()
        
        refUpdate.child("users").child(currentUser.uid).child("updateNotif").setValue(1, withCompletionBlock: { (error, ref)  in
            if error != nil {
                print("Failed to update change updateNotif")
            }})
        
        let refBoxSW = Database.database().reference()
        refBoxSW.child("users").child(currentUser.uid).child("updateBoxSW").setValue(1, withCompletionBlock: { (error, ref)  in
            if error != nil {
                print("Failed to update change updateNotif")
            }})
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor(red:0.53, green:0.80, blue:0.92, alpha:1.0)
        
        view.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        scrollView.addSubview(heading)
        scrollView.addSubview(pillLabel)
        scrollView.addSubview(numPerLabel)
        scrollView.addSubview(numPerText)
        scrollView.addSubview(oftenLabel)
        scrollView.addSubview(oftenButton)

        heading.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 30).isActive = true
        heading.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        pillLabel.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 5).isActive = true
        pillLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        pillLabel.text = pill
        
        numPerLabel.topAnchor.constraint(equalTo: pillLabel.bottomAnchor, constant: 20).isActive = true
        numPerLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true

        numPerText.topAnchor.constraint(equalTo: numPerLabel.bottomAnchor, constant: 20).isActive = true
        numPerText.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        numPerText.widthAnchor.constraint(equalToConstant: 75).isActive = true
        numPerText.heightAnchor.constraint(equalToConstant: 75).isActive = true

        oftenLabel.topAnchor.constraint(equalTo: numPerText.bottomAnchor, constant: 20).isActive = true
        oftenLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true

        oftenButton.topAnchor.constraint(equalTo: oftenLabel.bottomAnchor, constant: 20).isActive = true
        oftenButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        oftenButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        oftenButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
