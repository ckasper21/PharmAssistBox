//
//  MedInfoViewController.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 4/1/19.
//  Copyright © 2019 Chris Kasper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class MedInfoViewController: UIViewController, SelectMedViewControllerDelegate {

    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    var options = ["Select"]
    var medInfo: NSDictionary! // <- Patient related info
    var pillInfo: NSDictionary! // <- Pill related info
    
    var numPills: Int = 0
    
    struct currentUser {
        static var uid = ""
    }
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor(red:0.53, green:0.80, blue:0.92, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentSize.height = 1050
        
        return view
    }()
    
    let medInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        return view
    }()
    
    let infoLabels: [UILabel] = {
        let fields = ["Name","Generic Name","Type of Pill","What does it treat?", "How to take", "Contraindications", "Warnings/Precautions"]
        var arr = [UILabel]()
        for field in fields {
            let label = UILabel()
            label.text = field
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.clipsToBounds = true
            arr.append(label)
        }
        return arr
    }()
    
    let infoText: [UITextField] = {
        var arr = [UITextField]()
        for i in 1...7 {
            let text = UITextField()
            text.translatesAutoresizingMaskIntoConstraints = false
            text.font = UIFont.systemFont(ofSize: 16)
            
            text.clipsToBounds = true
            
            arr.append(text)
        }
        return arr
    }()
    
    let pillPicView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let changeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Schedule", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = .white
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(MedInfoViewController.changeSched), for: .touchUpInside)
        return button
    }()
    
    let selectLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Medication"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    let selectMed: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select", for:  .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(MedInfoViewController.selectMedFunc), for: .touchUpInside)
        return button
    }()
    
    let dosageSchedLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Dosage Schedule"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let dosageAMTLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Dosage"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let pillsLeftLabel: UILabel = {
        let label = UILabel()
        label.text = "Pills Left"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let slotLabel: UILabel = {
        let label = UILabel()
        label.text = "Dispenser Slot"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    @objc func selectMedFunc() {
        let selectVC = SelectMedViewController()
        selectVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        selectVC.delegate = self
        
        if currentUser.uid != "" {
            selectVC.userID = currentUser.uid
            selectVC.options = options
            
            present(selectVC, animated: true, completion: nil)
        } else {
            print("User not logged in")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Medication Information"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                currentUser.uid = user.uid
                self.getMeds()
            }
        }
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
        }
    }
    
    func didFinishSelectMedView(controller: SelectMedViewController) {
        print("In didFinishSMV in MedInfoVC")
        if controller.receivedOption != nil && controller.receivedOption != "Select" {
            selectMed.setTitle(controller.receivedOption, for: .normal)
            setupMedInfo()
        }
    }
    
    private func getMeds() {
        ref = Database.database().reference()
        ref.child("users").child(currentUser.uid).child("medications").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                self.medInfo = value
                self.options = self.options + (value.allKeys as! [String]).sorted()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func setupMedInfo() {
        // First make sure everything is removed
        dosageSchedLabel.removeFromSuperview()
        dosageAMTLabel.removeFromSuperview()
        pillsLeftLabel.removeFromSuperview()
        medInfoView.removeFromSuperview()
        
        // Add back
        let pill = String(selectMed.title(for: .normal)!)
        let pillInfo = medInfo[pill] as! NSDictionary
        
        numPills = Int(pillInfo["numPills"] as! String)!
        
        dosageSchedLabel.text = "Current Dosage Schedule: " + (pillInfo["tpd"] as! String) + " time(s) per day"
        dosageAMTLabel.text = "Current Dosage: " + (pillInfo["dosage"] as! String)
        pillsLeftLabel.text = "Pills left: " + (pillInfo["numPills"] as! String)
        
        let ref1 = Database.database().reference()
        
        ref1.child("users").child(currentUser.uid).child("dispenser").observeSingleEvent(of: .value, with: { (snapshot) in
            if let slots = snapshot.value as? NSDictionary {
                if slots["Slot 1"] as! String == pill {
                    self.slotLabel.text = "Dispenser Slot: " + "1"
                } else if slots["Slot 2"] as! String == pill {
                    self.slotLabel.text = "Dispenser Slot: " + "2"
                    
                } else if slots["Slot 3"] as! String == pill {
                    self.slotLabel.text = "Dispenser Slot: " + "3"
                }
            }
        })
        
        scrollView.addSubview(dosageSchedLabel)
        scrollView.addSubview(dosageAMTLabel)
        scrollView.addSubview(pillsLeftLabel)
        scrollView.addSubview(slotLabel)
        scrollView.addSubview(medInfoView)
        
        dosageSchedLabel.topAnchor.constraint(equalTo: selectMed.bottomAnchor, constant: 10).isActive = true
        dosageSchedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        
        dosageAMTLabel.topAnchor.constraint(equalTo: dosageSchedLabel.bottomAnchor, constant: 5).isActive = true
        dosageAMTLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        
        pillsLeftLabel.topAnchor.constraint(equalTo: dosageAMTLabel.bottomAnchor, constant: 5).isActive = true
        pillsLeftLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        
        slotLabel.topAnchor.constraint(equalTo: pillsLeftLabel.bottomAnchor, constant: 5).isActive = true
        slotLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        
        medInfoView.topAnchor.constraint(equalTo: slotLabel.bottomAnchor, constant: 10).isActive = true
        medInfoView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        medInfoView.heightAnchor.constraint(equalToConstant: 750).isActive = true
        medInfoView.widthAnchor.constraint(equalToConstant: 390).isActive = true
        
        ref.child("medications").child(pill).observeSingleEvent(of: .value, with: { (snapshot) in
            if let info = snapshot.value as? NSDictionary {
                let storageRef = Storage.storage().reference(forURL: info["imageURL"] as! String)
                storageRef.downloadURL(completion: { (url, error) in
                    do {
                        self.pillInfo = info
                        let data = try Data(contentsOf: url!)
                        let pillPic = UIImage(data: data as Data)
                        self.pillPicView.image = pillPic
            
                        self.setupPillPic()
                        
                    } catch {
                        print(error)
                    }
                })
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc func changeSched() {
        let controller = ChangeSchedViewController()
        controller.pill = String(selectMed.title(for: .normal)!)
        controller.pillsLeft = numPills
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setupPillPic() {
        medInfoView.addSubview(pillPicView)
        pillPicView.topAnchor.constraint(equalTo: medInfoView.topAnchor, constant: 20).isActive = true
        pillPicView.centerXAnchor.constraint(equalTo: medInfoView.centerXAnchor).isActive = true
        pillPicView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        pillPicView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        medInfoView.addSubview(infoLabels[0])
        medInfoView.addSubview(infoLabels[1])
        medInfoView.addSubview(infoLabels[2])
        medInfoView.addSubview(infoLabels[3])
        medInfoView.addSubview(infoLabels[4])
        medInfoView.addSubview(infoLabels[5])
        medInfoView.addSubview(infoLabels[6])
        
        medInfoView.addSubview(infoText[0])
        medInfoView.addSubview(infoText[1])
        medInfoView.addSubview(infoText[2])
        medInfoView.addSubview(infoText[3])
        medInfoView.addSubview(infoText[4])
        medInfoView.addSubview(infoText[5])
        medInfoView.addSubview(infoText[6])
        
        infoText[0].text = pillInfo["name"] as? String
        infoText[1].text = pillInfo["genericName"] as? String
        infoText[2].text = pillInfo["type"] as? String
        infoText[3].text = pillInfo["treat"] as? String
        infoText[4].text = pillInfo["htt"] as? String
        infoText[5].text = pillInfo["contra"] as? String
        infoText[6].text = pillInfo["warn"] as? String
        
        infoLabels[0].topAnchor.constraint(equalTo: pillPicView.bottomAnchor, constant: 15).isActive = true
        infoLabels[0].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        infoText[0].topAnchor.constraint(equalTo: infoLabels[0].bottomAnchor, constant: 10).isActive = true
        infoText[0].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        
        infoLabels[1].topAnchor.constraint(equalTo: infoText[0].bottomAnchor, constant: 15).isActive = true
        infoLabels[1].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        infoText[1].topAnchor.constraint(equalTo: infoLabels[1].bottomAnchor, constant: 10).isActive = true
        infoText[1].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        
        infoLabels[2].topAnchor.constraint(equalTo: infoText[1].bottomAnchor, constant: 15).isActive = true
        infoLabels[2].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        infoText[2].topAnchor.constraint(equalTo: infoLabels[2].bottomAnchor, constant: 10).isActive = true
        infoText[2].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        
        infoLabels[3].topAnchor.constraint(equalTo: infoText[2].bottomAnchor, constant: 15).isActive = true
        infoLabels[3].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        infoText[3].topAnchor.constraint(equalTo: infoLabels[3].bottomAnchor, constant: 10).isActive = true
        infoText[3].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true

        infoLabels[4].topAnchor.constraint(equalTo: infoText[3].bottomAnchor, constant: 15).isActive = true
        infoLabels[4].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        infoText[4].topAnchor.constraint(equalTo: infoLabels[4].bottomAnchor, constant: 10).isActive = true
        infoText[4].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        
        infoLabels[5].topAnchor.constraint(equalTo: infoText[4].bottomAnchor, constant: 15).isActive = true
        infoLabels[5].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        infoText[5].topAnchor.constraint(equalTo: infoLabels[5].bottomAnchor, constant: 10).isActive = true
        infoText[5].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        
        infoLabels[6].topAnchor.constraint(equalTo: infoText[5].bottomAnchor, constant: 15).isActive = true
        infoLabels[6].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        infoText[6].topAnchor.constraint(equalTo: infoLabels[6].bottomAnchor, constant: 10).isActive = true
        infoText[6].leadingAnchor.constraint(equalTo: medInfoView.leadingAnchor, constant: 25).isActive = true
        
        scrollView.addSubview(changeButton)
        changeButton.topAnchor.constraint(equalTo: medInfoView.bottomAnchor, constant: 30).isActive = true
        changeButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        changeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        changeButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor(red:0.53, green:0.80, blue:0.92, alpha:1.0)
        view.addSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        scrollView.addSubview(selectLabel)
        scrollView.addSubview(selectMed)
        
        selectLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true
        selectLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        
        selectMed.topAnchor.constraint(equalTo: selectLabel.bottomAnchor, constant: 5).isActive = true
        selectMed.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        selectMed.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        selectMed.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

}
