//
//  HomeViewController.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 12/16/18.
//  Copyright © 2018 Chris Kasper. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class HomeViewController: UIViewController {

    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    
    struct currentUser {
        static var uid = ""
    }
    
    // Config Medication Schedule Button
    let MSButton: UIButton = {
        let button = UIButton(type: .custom) as UIButton
        let image = UIImage.init(named: "if_office-15_809622")
        button.frame = CGRect(x: 0, y: 0 , width: 125, height: 125)
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(HomeViewController.goToSchedule), for: .touchUpInside)
        return button
    }()
    
    let option1: UITextView = {
       let text = UITextView()
        text.text = "View Schedule"
        text.font = UIFont.boldSystemFont(ofSize: 18)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = nil
        text.isEditable = false
        text.isUserInteractionEnabled = false
        text.isScrollEnabled = false
        return text
    }()
    
    // Config Add Medication Button
    let AMButton: UIButton = {
        let button = UIButton(type: .custom) as UIButton
        let image = UIImage.init(named: "if_199_CircledPlus_183316")
        button.frame = CGRect(x: 0, y: 0 , width: 125, height: 125)
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(HomeViewController.goToAddMed), for: .touchUpInside)
        return button
    }()
    
    let option2: UITextView = {
        let text = UITextView()
        text.text = "Add Medication"
        text.font = UIFont.boldSystemFont(ofSize: 18)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = nil
        text.isEditable = false
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        return text
    }()
    
    // Config View Medications Button
    let VMButton: UIButton = {
        let button = UIButton(type: .custom) as UIButton
        let image = UIImage.init(named: "if_capsules_1118215")
        button.frame = CGRect(x: 0, y: 0 , width: 125, height: 125)
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(HomeViewController.goToViewMed), for: .touchUpInside)
        return button
    }()
    
    let option3: UITextView = {
        let text = UITextView()
        text.text = "View Medication"
        text.font = UIFont.boldSystemFont(ofSize: 18)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = nil
        text.isEditable = false
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        return text
    }()
    
    // Config View Account Button
    let VAButton: UIButton = {
        let button = UIButton(type: .custom) as UIButton
        let image = UIImage.init(named: "if_ic_account_circle_48px_352002")
        button.frame = CGRect(x: 0, y: 0 , width: 125, height: 125)
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(HomeViewController.goToViewAcct), for: .touchUpInside)
        return button
    }()
    
    let option4: UITextView = {
        let text = UITextView()
        text.text = "View Account"
        text.font = UIFont.boldSystemFont(ofSize: 18)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = nil
        text.isEditable = false
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        return text
    }()
    
    let Cross: UIImageView = {
        let image = UIImageView(image: #imageLiteral(resourceName: "plus-symbol"))
        return image
    }()
    
    // Config Contact CareTaker Button
    let CTButton: UIButton = {
        let button = UIButton(type: .custom) as UIButton
        let image = UIImage.init(named: "if_Svtethoscope_2415600")
        button.frame = CGRect(x: 0, y: 0 , width: 125, height: 125)
        button.setImage(image, for: UIControl.State.normal)
        button.addTarget(self, action: #selector(HomeViewController.contactCG), for: .touchUpInside)
        return button
    }()
    
    let option5: UITextView = {
        let text = UITextView()
        text.text = "Contact CareTaker"
        text.font = UIFont.boldSystemFont(ofSize: 18)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = nil
        text.isEditable = false
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        return text
    }()
    
    let heading: UITextView = {
        let text = UITextView()
        text.text = "Pharm-Assist"
        text.font = UIFont.boldSystemFont(ofSize: 36)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = nil
        text.isEditable = false
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        return text
    }()
    
    let subhead: UITextView = {
        let text = UITextView()
        text.text = "What would you like to do?"
        text.font = UIFont.boldSystemFont(ofSize: 24)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = nil
        text.isEditable = false
        text.isScrollEnabled = false
        text.isUserInteractionEnabled = false
        return text
    }()
    
//    // Notification Button
//    let notificationButton: UIButton = {
//        let button = UIButton(type: .custom) as UIButton
//        let image = UIImage.init(named: "if_notifications_3671825")
//        button.frame = CGRect(x: 0, y: 0 , width: 125, height: 125)
//        button.setImage(image, for: UIControl.State.normal)
//        button.addTarget(self, action: #selector(HomeViewController.seeNotifications), for: .touchUpInside)
//        return button
//    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                currentUser.uid = user.uid
                self.setupNotifications()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        login()
        setupLayout()
    }
    
    @objc func goToSchedule() {
        print("Go to medication schedule page!")
        let controller = ScheduleViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func goToAddMed() {
        print("Go to add medication page!")
        let controller = AddMedViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func goToViewMed() {
        print("Go to view medication page!")
        let controller = MedInfoViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func goToViewAcct() {
        //try! Auth.auth().signOut() --for debug purposes
        let controller = AccountViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func contactCG() {
        print("Contact Caregiver!")
        ref = Database.database().reference()
        
        ref.child("users").child(currentUser.uid).child("info").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let ct = value["ct"] as! NSDictionary
                let doc = value["doctor"] as! NSDictionary
                
                let ct_phone = ct["phone"] as! String
                let doc_phone = doc["phone"] as! String
                
                if !ct_phone.isPhoneNumber && !doc_phone.isPhoneNumber {
                    print("No phone numbers")
                    return
                }
                
                let optionMenu = UIAlertController(title: nil, message: "Who do you want to call?", preferredStyle: .actionSheet)
                
                if ct_phone.isPhoneNumber {
                    let ctAction = UIAlertAction(title: (ct["name"] as! String), style: .default, handler: {
                        (alert: UIAlertAction!) -> Void in
                        
                        if let url = URL(string: "tel://\(ct_phone.onlyDigits())") {
                            UIApplication.shared.open(url)
                        }
                    })
                    optionMenu.addAction(ctAction)
                }
                
                if doc_phone.isPhoneNumber {
                    let docAction = UIAlertAction(title: (doc["name"] as! String), style: .default, handler: {
                        (alert: UIAlertAction!) -> Void in
                        
                        if let url = URL(string: "tel://\(doc_phone.onlyDigits())") {
                            UIApplication.shared.open(url)
                        }
                    })
                    optionMenu.addAction(docAction)
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                optionMenu.addAction(cancel)
                
                self.present(optionMenu, animated: true, completion: nil)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
//    @objc func seeNotifications() {
//        print("Where are the notifications")
//    }
    
    @objc func login() {
        Auth.auth().signIn(withEmail: "chris@test.com", password: "1234567") { user, error in
            if error == nil && user != nil {
                print("Login successful")
                self.setupNotifications()
            } else {
                print("Error reported: \(error!)")
            }
        }
    }
    
    private func setupNotifications() {
        
        // See if notifications should be updated
        ref = Database.database().reference()
        ref.child("users").child(currentUser.uid).child("updateNotif").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Int {
                if value == 1 {
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    
                    let refSched = Database.database().reference()
                    
                    refSched.child("users").child(currentUser.uid).child("schedule").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value2 = snapshot.value as? NSDictionary {
                            var epoch = Set<Int>()
                            
                            for key in value2.allKeys {
                                if let pill = value2[key] as? NSDictionary {
                                    for time in pill.allKeys {
                                        let t = time as! String
                                        epoch.insert(Int(t)!)
                                    }
                                }
                            }
                            
                            print(epoch)
                            
                            for time in epoch {
                                let date = Date(timeIntervalSince1970: TimeInterval(time))
                                let hour = Calendar.current.component(.hour, from: date)
                                let minute = Calendar.current.component(.minute, from: date)
                                let day = Calendar.current.component(.day, from: date)
                                let month = Calendar.current.component(.month, from: date)
                                let year = Calendar.current.component(.year, from: date)
                                
                                var notifDate = DateComponents()
                                
                                notifDate.hour = hour
                                notifDate.minute = minute
                                notifDate.day = day
                                notifDate.month = month
                                notifDate.year = year

                                let content = UNMutableNotificationContent()
                                content.title = "Pharm-Assist"
                                content.body = "Time to take your medicine!"
                                content.sound = UNNotificationSound.default

                                let trigger = UNCalendarNotificationTrigger.init(dateMatching: notifDate, repeats: false)
                                let request = UNNotificationRequest(identifier: date.description(with: .current), content: content, trigger: trigger)
                                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)


                                let refUpdate = Database.database().reference()

                                refUpdate.child("users").child(currentUser.uid).child("updateNotif").setValue(0, withCompletionBlock: { (error, ref)  in
                                    if error != nil {
                                        print("Failed to update change updateNotif")
                                    }})
                            }
                            
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    private func setupLayout() {
        view.addSubview(Cross)
        view.addSubview(MSButton)
        view.addSubview(AMButton)
        view.addSubview(VMButton)
        view.addSubview(VAButton)
        view.addSubview(option1)
        view.addSubview(option2)
        view.addSubview(option3)
        view.addSubview(option4)
        view.addSubview(CTButton)
        view.addSubview(option5)
//        view.addSubview(notificationButton)
        view.addSubview(heading)
        view.addSubview(subhead)
        
        view.backgroundColor = UIColor(red:0.53, green:0.80, blue:0.92, alpha:1.0)
        
//        notificationButton.translatesAutoresizingMaskIntoConstraints = false
//        notificationButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
//        notificationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
//        notificationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        notificationButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        heading.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70).isActive = true
        heading.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        subhead.topAnchor.constraint(equalTo: heading.bottomAnchor, constant: 20).isActive = true
        subhead.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        Cross.translatesAutoresizingMaskIntoConstraints = false
        Cross.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        Cross.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        Cross.heightAnchor.constraint(equalToConstant: 350).isActive = true
        Cross.widthAnchor.constraint(equalToConstant: 350).isActive = true
        
        MSButton.translatesAutoresizingMaskIntoConstraints = false
        MSButton.centerYAnchor.constraint(equalTo: Cross.centerYAnchor, constant: -100).isActive = true
        MSButton.centerXAnchor.constraint(equalTo: Cross.centerXAnchor, constant: -90).isActive = true
        MSButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        MSButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        option1.centerXAnchor.constraint(equalTo: MSButton.centerXAnchor).isActive = true
        option1.centerYAnchor.constraint(equalTo: MSButton.centerYAnchor, constant: 70).isActive = true
        
        AMButton.translatesAutoresizingMaskIntoConstraints = false
        AMButton.centerYAnchor.constraint(equalTo: Cross.centerYAnchor, constant: -100).isActive = true
        AMButton.centerXAnchor.constraint(equalTo: Cross.centerXAnchor, constant: 90).isActive = true
        AMButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        AMButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        option2.centerXAnchor.constraint(equalTo: AMButton.centerXAnchor).isActive = true
        option2.centerYAnchor.constraint(equalTo: AMButton.centerYAnchor, constant: 70).isActive = true
        
        VMButton.translatesAutoresizingMaskIntoConstraints = false
        VMButton.centerYAnchor.constraint(equalTo: Cross.centerYAnchor, constant: 80).isActive = true
        VMButton.centerXAnchor.constraint(equalTo: Cross.centerXAnchor, constant: -90).isActive = true
        VMButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
        VMButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        option3.centerXAnchor.constraint(equalTo: VMButton.centerXAnchor).isActive = true
        option3.centerYAnchor.constraint(equalTo: VMButton.centerYAnchor, constant: 70).isActive = true
        
        VAButton.translatesAutoresizingMaskIntoConstraints = false
        VAButton.centerYAnchor.constraint(equalTo: Cross.centerYAnchor, constant: 80).isActive = true
        VAButton.centerXAnchor.constraint(equalTo: Cross.centerXAnchor, constant: 90).isActive = true
        VAButton.heightAnchor.constraint(equalToConstant: 115).isActive = true
        VAButton.widthAnchor.constraint(equalToConstant: 115).isActive = true
        
        option4.centerXAnchor.constraint(equalTo: VAButton.centerXAnchor).isActive = true
        option4.centerYAnchor.constraint(equalTo: VAButton.centerYAnchor, constant: 70).isActive = true
        
        CTButton.translatesAutoresizingMaskIntoConstraints = false
        CTButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
        CTButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        CTButton.heightAnchor.constraint(equalToConstant: 115).isActive = true
        CTButton.widthAnchor.constraint(equalToConstant: 115).isActive = true
        
        option5.centerYAnchor.constraint(equalTo: CTButton.centerYAnchor, constant: 70).isActive = true
        option5.centerXAnchor.constraint(equalTo: CTButton.centerXAnchor).isActive = true
    }

}

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
}
