//
//  ScheduleCell.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 12/20/18.
//  Copyright © 2018 Chris Kasper. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ScheduleCell: UITableViewCell {
    
    let cardBackgroundView = UIView()
    var id = ""
    var userid = ""
    var ref: DatabaseReference!
    var handleDB: DatabaseHandle!
    
    var medInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "Med Info Will go here"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        return label
    }()
    
    let dispenseButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Dispense", for: UIControl.State.normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = UIColor.lightGray
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        cardBackgroundView.layer.cornerRadius = 8
        cardBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        cardBackgroundView.backgroundColor = UIColor(red:0.53, green:0.80, blue:0.92, alpha:1.0)
        addSubview(cardBackgroundView)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(medInfoLabel)
        addSubview(dispenseButton)
        
        dispenseButton.addTarget(self, action: #selector(ScheduleCell.dispensePills), for: .touchUpInside)
        
        medInfoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        medInfoLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        medInfoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -100).isActive = true
        medInfoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        
        dispenseButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dispenseButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        dispenseButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        dispenseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        
        cardBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        cardBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        cardBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        cardBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }
    
    @objc func dispensePills() {
        if id == "" {
            print("No id with this cell?")
        } else {
            print("Attempting to dispense scheduled pills with id: \(id)")

            let alert = UIAlertController(title: "Dispense Now", message: "Are you sure you want to dispense this dosage?", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Yes", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.ref = Database.database().reference()
                self.ref.child("users").child(self.userid).child("dispenseNow").childByAutoId().setValue(["epoch": self.id])
                self.dispenseButton.isEnabled = false
            })
            let action2 = UIAlertAction(title: "No", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Don't want to dispense")
            })

            alert.addAction(action1)
            alert.addAction(action2)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
