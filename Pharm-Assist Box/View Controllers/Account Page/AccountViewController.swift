//
//  AccountViewController.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 12/17/18.
//  Copyright © 2018 Chris Kasper. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AccountViewController: UIViewController, UITextFieldDelegate {

    var handle: AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    var patientInfo: NSDictionary!
    
    struct currentUser {
        static var uid = ""
    }
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor(red:0.53, green:0.80, blue:0.92, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentSize.height = 850
        
        return view
    }()
    
    let saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.style = UIBarButtonItem.Style.done
        button.title = "Save"
        button.action = #selector(AccountViewController.saveFunc)
        return button
    }()
    
    let accountLabel: UILabel = {
        let label = UILabel()
        label.text = "Patient Info"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    let accountFields: [UILabel] = {
        let fields = ["Name","PatientID","E-mail","Phone"]
        var arr = [UILabel]()
        for field in fields {
            let label = UILabel()
            label.text = field
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.backgroundColor = UIColor.white
            label.clipsToBounds = true
            label.textAlignment = .center
            arr.append(label)
        }
        return arr
    }()
    
    let accountText: [UITextField] = {
        var arr = [UITextField]()
        for i in 1...4 {
            let text = UITextField()
            text.translatesAutoresizingMaskIntoConstraints = false
            text.font = UIFont.boldSystemFont(ofSize: 18)
            text.backgroundColor = UIColor.white
            text.clipsToBounds = true
            text.textAlignment = .center
            text.adjustsFontSizeToFitWidth = true
            
            arr.append(text)
        }
        return arr
    }()
    
    let ctLabel: UILabel = {
        let label = UILabel()
        label.text = "CareTaker"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    let ctFields: [UILabel] = {
        let fields = ["Name","E-mail","Phone"]
        var arr = [UILabel]()
        for field in fields {
            let label = UILabel()
            label.text = field
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.backgroundColor = UIColor.white
            label.clipsToBounds = true
            label.textAlignment = .center
            arr.append(label)
        }
        return arr
    }()
    
    let ctText: [UITextField] = {
        var arr = [UITextField]()
        for i in 1...3 {
            let text = UITextField()
            text.translatesAutoresizingMaskIntoConstraints = false
            text.font = UIFont.boldSystemFont(ofSize: 18)
            text.backgroundColor = UIColor.white
            text.clipsToBounds = true
            text.textAlignment = .center
            text.adjustsFontSizeToFitWidth = true
            
            arr.append(text)
        }
        return arr
    }()
    
    let docLabel: UILabel = {
        let label = UILabel()
        label.text = "Doctor"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    let docFields: [UILabel] = {
        let fields = ["Name","Phone", "Address"]
        var arr = [UILabel]()
        for field in fields {
            let label = UILabel()
            label.text = field
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.backgroundColor = UIColor.white
            label.clipsToBounds = true
            label.textAlignment = .center
            arr.append(label)
        }
        return arr
    }()
    
    let docText: [UITextField] = {
        var arr = [UITextField]()
        for i in 1...3 {
            let text = UITextField()
            text.translatesAutoresizingMaskIntoConstraints = false
            text.font = UIFont.boldSystemFont(ofSize: 18)
            text.backgroundColor = UIColor.white
            text.clipsToBounds = true
            text.textAlignment = .center
            text.adjustsFontSizeToFitWidth = true
            
            arr.append(text)
        }
        return arr
    }()
    
    @objc func saveFunc() {
        print("Save to Firebase")
        
        let patient = patientInfo["patient"] as! NSDictionary
        let ct = patientInfo["ct"] as! NSDictionary
        let doc = patientInfo["doctor"] as! NSDictionary
        
        patient.setValue(accountText[0].text, forKey: "name")
        patient.setValue(accountText[1].text, forKey: "patientID")
        patient.setValue(accountText[2].text, forKey: "email")
        patient.setValue(accountText[3].text, forKey: "phone")
        
        ct.setValue(ctText[0].text, forKey: "name")
        ct.setValue(ctText[1].text, forKey: "email")
        ct.setValue(ctText[2].text, forKey: "phone")
        
        doc.setValue(docText[0].text, forKey: "name")
        doc.setValue(docText[1].text, forKey: "phone")
        doc.setValue(docText[2].text, forKey: "address")
        
        patientInfo.setValue(patient, forKey: "patient")
        patientInfo.setValue(ct, forKey: "ct")
        patientInfo.setValue(doc, forKey: "doctor")
        
        self.ref = Database.database().reference()
        
        self.ref.child("users").child(currentUser.uid).child("info").setValue(patientInfo, withCompletionBlock: { (error, ref)  in
            if error != nil {
                print("Failed to change info")
                let alert = UIAlertController(title: "Ut oh", message: "There was an issue processing your request, please try again", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
                    return
                }))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            else{
                print("Success in changing schedule")
                let alert = UIAlertController(title: "Success", message: "Information was successfully changed", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (nil) in
                    return
                }))
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(AccountViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AccountViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationItem.title = "Account Info"
        navigationController?.navigationBar.prefersLargeTitles = true
        saveButton.target = self
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                currentUser.uid = user.uid
                self.getData()
            }
        }
        
        for i in 0...3 {
            accountText[i].delegate = self
        }
        
        for i in 0...2 {
            ctText[i].delegate = self
        }
        
        for i in 0...2 {
            docText[i].delegate = self
        }

        setupLayout()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AccountViewController.dismissKeyboard))
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
    
    private func getData() {
        ref = Database.database().reference()
        ref.child("users").child(currentUser.uid).child("info").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                self.patientInfo = value
                self.populateText()
                
            } else {
                print("User info not filled")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func populateText() {
        if patientInfo.count != 0 {
            let patient = patientInfo["patient"] as! NSDictionary
            let ct = patientInfo["ct"] as! NSDictionary
            let doc = patientInfo["doctor"] as! NSDictionary
            
            accountText[0].text = (patient["name"] as! String)
            accountText[1].text = (patient["patientID"] as! String)
            accountText[2].text = (patient["email"] as! String)
            accountText[3].text = (patient["phone"] as! String)
            
            ctText[0].text = (ct["name"] as! String)
            ctText[1].text = (ct["email"] as! String)
            ctText[2].text = (ct["phone"] as! String)
            
            docText[0].text = (doc["name"] as! String)
            docText[1].text = (doc["phone"] as! String)
            docText[2].text = (doc["address"] as! String)
        }
    }

    private func setupLayout() {
        view.backgroundColor = UIColor(red:0.53, green:0.80, blue:0.92, alpha:1.0)
        
        view.addSubview(scrollView)
        navigationItem.rightBarButtonItem = saveButton
        
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        scrollView.addSubview(accountLabel)
        
        accountLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25).isActive = true
        accountLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        let patsubStackView1 = UIStackView(arrangedSubviews: accountFields)
        patsubStackView1.axis = .vertical
        patsubStackView1.distribution = .fillEqually
        patsubStackView1.alignment = .fill
        patsubStackView1.spacing = 2
        patsubStackView1.translatesAutoresizingMaskIntoConstraints = false
        patsubStackView1.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let patsubStackView2 = UIStackView(arrangedSubviews: accountText)
        patsubStackView2.axis = .vertical
        patsubStackView2.distribution = .fillEqually
        patsubStackView2.alignment = .fill
        patsubStackView2.spacing = 2
        patsubStackView2.translatesAutoresizingMaskIntoConstraints = false
        patsubStackView2.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let patstackView = UIStackView(arrangedSubviews: [patsubStackView1,patsubStackView2])
        patstackView.axis = .horizontal
        patstackView.distribution = .fillProportionally
        patstackView.alignment = .fill
        patstackView.spacing = 2
        patstackView.translatesAutoresizingMaskIntoConstraints = false
        patstackView.sizeToFit()
        patstackView.layoutIfNeeded()
        
        scrollView.addSubview(patstackView)
        
        patstackView.topAnchor.constraint(equalTo: accountLabel.bottomAnchor, constant: 15).isActive = true
        patstackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        patstackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        scrollView.addSubview(ctLabel)
        
        ctLabel.topAnchor.constraint(equalTo: patstackView.bottomAnchor, constant: 35).isActive = true
        ctLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true

        let ctsubStackView1 = UIStackView(arrangedSubviews: ctFields)
        ctsubStackView1.axis = .vertical
        ctsubStackView1.distribution = .fillEqually
        ctsubStackView1.alignment = .fill
        ctsubStackView1.spacing = 2
        ctsubStackView1.translatesAutoresizingMaskIntoConstraints = false
        ctsubStackView1.heightAnchor.constraint(equalToConstant: 175).isActive = true
        
        let ctsubStackView2 = UIStackView(arrangedSubviews: ctText)
        ctsubStackView2.axis = .vertical
        ctsubStackView2.distribution = .fillEqually
        ctsubStackView2.alignment = .fill
        ctsubStackView2.spacing = 2
        ctsubStackView2.translatesAutoresizingMaskIntoConstraints = false
        ctsubStackView2.heightAnchor.constraint(equalToConstant: 175).isActive = true
        
        let ctstackView = UIStackView(arrangedSubviews: [ctsubStackView1,ctsubStackView2])
        ctstackView.axis = .horizontal
        ctstackView.distribution = .fillProportionally
        ctstackView.alignment = .fill
        ctstackView.spacing = 2
        ctstackView.translatesAutoresizingMaskIntoConstraints = false
        ctstackView.sizeToFit()
        ctstackView.layoutIfNeeded()
        
        scrollView.addSubview(ctstackView)
        
        ctstackView.topAnchor.constraint(equalTo: ctLabel.bottomAnchor, constant: 15).isActive = true
        ctstackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        ctstackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        scrollView.addSubview(docLabel)
        
        docLabel.topAnchor.constraint(equalTo: ctstackView.bottomAnchor, constant: 35).isActive = true
        docLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        
        let docsubStackView1 = UIStackView(arrangedSubviews: docFields)
        docsubStackView1.axis = .vertical
        docsubStackView1.distribution = .fillEqually
        docsubStackView1.alignment = .fill
        docsubStackView1.spacing = 2
        docsubStackView1.translatesAutoresizingMaskIntoConstraints = false
        docsubStackView1.heightAnchor.constraint(equalToConstant: 175).isActive = true
        
        let docsubStackView2 = UIStackView(arrangedSubviews: docText)
        docsubStackView2.axis = .vertical
        docsubStackView2.distribution = .fillEqually
        docsubStackView2.alignment = .fill
        docsubStackView2.spacing = 2
        docsubStackView2.translatesAutoresizingMaskIntoConstraints = false
        docsubStackView2.heightAnchor.constraint(equalToConstant: 175).isActive = true
        
        let docstackView = UIStackView(arrangedSubviews: [docsubStackView1,docsubStackView2])
        docstackView.axis = .horizontal
        docstackView.distribution = .fillProportionally
        docstackView.alignment = .fill
        docstackView.spacing = 2
        docstackView.translatesAutoresizingMaskIntoConstraints = false
        docstackView.sizeToFit()
        docstackView.layoutIfNeeded()
        
        scrollView.addSubview(docstackView)
        
        docstackView.topAnchor.constraint(equalTo: docLabel.bottomAnchor, constant: 15).isActive = true
        docstackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        docstackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= keyboardFrame.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += keyboardFrame.height
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
