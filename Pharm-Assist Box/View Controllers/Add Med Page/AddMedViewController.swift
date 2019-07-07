//
//  AddMedViewController.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 1/18/19.
//  Copyright © 2019 Chris Kasper. All rights reserved.
//

import UIKit
import Firebase

class AddMedViewController: UIViewController, QRViewControllerDelegate, SelectViewControllerDelegate, SelectTimeViewControllerDelegate, UITextFieldDelegate {
    var handle: AuthStateDidChangeListenerHandle?
    var qrCode = Dictionary<String, String>()
    var timesPerDay: Int = 0
    var ref: DatabaseReference!
    var slotToUse: String = ""
    
    struct currentUser {
        static var uid = ""
    }
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor(red:0.53, green:0.80, blue:0.92, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentSize.height = 1200
        
        return view
    }()
    
    let qrHeading: UITextView = {
        let text = UITextView()
        text.text = "Use QR code"
        text.font = UIFont.boldSystemFont(ofSize: 28)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = nil
        text.isEditable = false
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        return text
    }()
    
    // Config QR capture button
    let qrButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Capture", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(AddMedViewController.captureQR), for: .touchUpInside)
        return button
    }()
    
    let divider: UIImageView = {
        let image = UIImage(named:"horizontal-line")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 255, height: 255)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let pillFields: [UILabel] = {
        let fields = ["Name","Dosage","Number of Pills","Pills per Time"]
        var arr = [UILabel]()
        for field in fields {
            let label = UILabel()
            label.text = field
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.backgroundColor = UIColor.white
            label.layer.cornerRadius = 5
            label.clipsToBounds = true
            label.textAlignment = .center
            arr.append(label)
        }
        return arr
    }()
    
    let textFields: [UITextField] = {
        var arr = [UITextField]()
        for i in 1...4 {
            let text = UITextField()
            text.translatesAutoresizingMaskIntoConstraints = false
            text.font = UIFont.boldSystemFont(ofSize: 20)
            text.backgroundColor = UIColor.white
            text.layer.cornerRadius = 5
            text.clipsToBounds = true
            text.textAlignment = .center
            
            arr.append(text)
        }
        return arr
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
        button.addTarget(self, action: #selector(AddMedViewController.oftenFunc), for: .touchUpInside)
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
                button.addTarget(self, action: #selector(AddMedViewController.timeFunc0), for: .touchUpInside)
            } else if i == 1 {
                button.addTarget(self, action: #selector(AddMedViewController.timeFunc1), for: .touchUpInside)
            } else if i == 2 {
                button.addTarget(self, action: #selector(AddMedViewController.timeFunc2), for: .touchUpInside)
            } else if i == 3 {
                button.addTarget(self, action: #selector(AddMedViewController.timeFunc3), for: .touchUpInside)
            }
            
            arr.append(button)
        }
        return arr
    }()
    
    let addMedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Medication!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(AddMedViewController.submitMed), for: .touchUpInside)
        return button
    }()
    
    @objc func captureQR() {
        let controller = QRViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: false)
    }
    
    @objc func oftenFunc() {
        let selectVC = SelectViewController()
        selectVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        selectVC.delegate = self
        present(selectVC, animated: true, completion: nil)
    }
    
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
    
    @objc func updateFields() {
        textFields[0].text = self.qrCode["name"]
        textFields[1].text = self.qrCode["dosage"]
        textFields[2].text = self.qrCode["numPills"]
        textFields[3].text = self.qrCode["numPer"]
        
        self.timesPerDay = Int(self.qrCode["tpd"]!)!
        setupTimePickers()
        
        setupLayout()
    }
    
    func didFinishQRView(controller: QRViewController) {
        print("In didFinish in AddMedVC")
        print(controller.qrCode.description)
        self.qrCode = controller.qrCode
        
        if !self.qrCode.isEmpty {
            updateFields()
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
    
    func didFinishSelectTimeView(controller: SelectTimeViewController) {
        print("In didFinishTimeSV in AddMedVC")
        if controller.receivedOption != nil {
            timeButtons[controller.id!].setTitle(controller.receivedOption,for:.normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Medication"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        for i in 0...3 {
            textFields[i].delegate = self
        }
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                currentUser.uid = user.uid
            }
        }

        setupLayout()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddMedViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
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

    private func setupLayout() {
        view.addSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        scrollView.addSubview(qrHeading)
        qrHeading.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 35).isActive = true
        qrHeading.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        scrollView.addSubview(qrButton)
        qrButton.topAnchor.constraint(equalTo: qrHeading.bottomAnchor, constant: 10).isActive = true
        qrButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        qrButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        qrButton.widthAnchor.constraint(equalToConstant: 150).isActive = true

        scrollView.addSubview(divider)
        divider.topAnchor.constraint(equalTo: qrButton.bottomAnchor, constant: 5).isActive = true
        divider.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        divider.heightAnchor.constraint(equalToConstant: 100).isActive = true
        divider.widthAnchor.constraint(equalToConstant: 250).isActive = true

        let subStackView1 = UIStackView(arrangedSubviews: pillFields)
        subStackView1.axis = .vertical
        subStackView1.distribution = .fillEqually
        subStackView1.alignment = .fill
        subStackView1.spacing = 5
        subStackView1.translatesAutoresizingMaskIntoConstraints = false
        subStackView1.heightAnchor.constraint(equalToConstant: 175).isActive = true

        let subStackView2 = UIStackView(arrangedSubviews: textFields)
        subStackView2.axis = .vertical
        subStackView2.distribution = .fillEqually
        subStackView2.alignment = .fill
        subStackView2.spacing = 5
        subStackView2.translatesAutoresizingMaskIntoConstraints = false
        subStackView2.heightAnchor.constraint(equalToConstant: 175).isActive = true

        let stackView = UIStackView(arrangedSubviews: [subStackView1,subStackView2])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 1
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.sizeToFit()
        stackView.layoutIfNeeded()

        scrollView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 0).isActive = true
        stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 10).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true

        scrollView.addSubview(oftenLabel)
        oftenLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20).isActive = true
        oftenLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true

        scrollView.addSubview(oftenButton)
        oftenButton.topAnchor.constraint(equalTo: oftenLabel.bottomAnchor, constant: 20).isActive = true
        oftenButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        oftenButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        oftenButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
    
    }
    
    private func setupTimePickers() {
        addMedButton.removeFromSuperview()
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
        
        scrollView.addSubview(addMedButton)
        
        if freq == "Once a day" {
            timeButtons[3].removeFromSuperview()
            timeLabels[3].removeFromSuperview()
            timeButtons[2].removeFromSuperview()
            timeLabels[2].removeFromSuperview()
            timeButtons[1].removeFromSuperview()
            timeLabels[1].removeFromSuperview()
            scrollView.contentSize.height = 900
            
            timesPerDay = 1
            
            
        } else if freq == "Two times a day" {
            timeButtons[3].removeFromSuperview()
            timeLabels[3].removeFromSuperview()
            timeButtons[2].removeFromSuperview()
            timeLabels[2].removeFromSuperview()
            scrollView.contentSize.height = 1000
            
            timesPerDay = 2
            
            
        } else if freq == "Three times a day" {
            timeButtons[3].removeFromSuperview()
            timeLabels[3].removeFromSuperview()
            scrollView.contentSize.height = 1100
            
            timesPerDay = 3
            
            
        } else if freq == "Four times a day" {
            scrollView.contentSize.height = 1200
            timesPerDay = 4
            
        }
        
        setAddButton(idx: idx)
    }
    
    private func setAddButton(idx: Int) {
        addMedButton.topAnchor.constraint(equalTo: timeButtons[idx].bottomAnchor, constant: 40).isActive = true
        addMedButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        addMedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addMedButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    private func createSchedule() {
        var pillSchedule = Dictionary<String, Dictionary<String,Int>>()
        var numPills = Int(qrCode["numPills"]!)!
        let numPer = Int(qrCode["numPer"]!)!
        let pillName = qrCode["name"]!
        
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
        
        self.ref.child("users").child(currentUser.uid).child("schedule").child(pillName).updateChildValues(pillSchedule, withCompletionBlock: { (error, ref)  in
            if error != nil {
                print("Failed to upload schedule")
                let alert = UIAlertController(title: "Ut oh", message: "There was an issue processing your request, please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
                    return
                }))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            else{
                print("Success in uploading schedule")
                let alert = UIAlertController(title: "Medication added", message: "Put medication in dispenser \(self.slotToUse)", preferredStyle: .alert)
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
    
    @objc func submitMed() {
        // Check to make sure form was filled out
        var flag = 0
        
        // Check textfields
        for i in 0...3 {
            if textFields[i].text == "" {
                flag = 1
            }
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
        
        if qrCode.isEmpty {
            // Means manual input from patient, fill qrCode data structure
            qrCode["name"] = textFields[0].text
            qrCode["dosage"] = textFields[1].text
            qrCode["numPills"] = textFields[2].text
            qrCode["numPer"] = textFields[3].text
            
        }
        
        // Check numPills and numPer
        if Int(qrCode["numPer"]!) == nil {
            flag = 1;
        }
        if Int(qrCode["numPills"]!) == nil {
            flag = 1;
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
            
            let ref1 = Database.database().reference()
            ref1.child("users").child(currentUser.uid).child("dispenser").observeSingleEvent(of: .value, with: { (snapshot) in
                if let slots = snapshot.value as? NSDictionary {
                    if slots["Slot 1"] as! String == "" {
                        self.slotToUse = "Slot 1"
                    } else if slots["Slot 2"] as! String == "" {
                        self.slotToUse = "Slot 2"
                        
                    } else if slots["Slot 3"] as! String == "" {
                        self.slotToUse = "Slot 3"
                    } else {
                        let alert = UIAlertController(title: "Ut oh", message: "There are no available slots in the dispenser", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
                            return
                        }))
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    // Add the medication to the user's database
                    self.ref = Database.database().reference()
                    self.ref.child("users").child(currentUser.uid).child("medications").child(self.qrCode["name"]!).setValue(["name": self.qrCode["name"],"dosage": self.qrCode["dosage"],"numPills": self.qrCode["numPills"],"numPer": self.qrCode["numPer"], "tpd": String(self.timesPerDay)], withCompletionBlock: { (error, ref)  in
                        if error != nil {
                            print("Failed to upload medication info")
                            let alert = UIAlertController(title: "Ut oh", message: "There was an issue processing your request, please try again", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
                                
                                return
                            }))
                            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                            return
                        } else {
                            let refUpdate = Database.database().reference()
                            
                            refUpdate.child("users").child(currentUser.uid).child("dispenser").child(self.slotToUse).setValue(self.qrCode["name"]!, withCompletionBlock: { (error, ref)  in
                                if error != nil {
                                    print("Failed to update change updateNotif")
                                }})
                            
                        }})
                        self.createSchedule()
                    
                } else {
                    print("Error trying to view open slots\n")
                    return
                }
            }) { (error) in
                print(error.localizedDescription)
            }
            
            // TODO: Check if medication exists in user db, update if necessary
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { (nil) in
            return
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        return
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
