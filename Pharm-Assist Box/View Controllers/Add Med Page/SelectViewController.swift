//
//  SelectViewController.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 1/25/19.
//  Copyright © 2019 Chris Kasper. All rights reserved.
//

import UIKit

protocol SelectViewControllerDelegate {
    func didFinishSelectView(controller: SelectViewController)
}

class SelectViewController: UIViewController {

    var delegate: SelectViewControllerDelegate! = nil
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
    
        return view
    }()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(SelectViewController.dismissDone), for: .touchUpInside)
        return button
    }()
    
    let picker = SelectPicker()
    var options = ["Select", "Once a day", "Two times a day", "Three times a day","Four times a day"]
    var receivedOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        picker.delegate = self
        picker.dataSource = self
        setupLayout()
        // Do any additional setup after loading the view.
    }

    @objc func dismissDone() {
        dismiss(animated: true, completion: nil)
        delegate.didFinishSelectView(controller: self)
    }
    
    func setupLayout() {
        view.addSubview(containerView)
        containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: 400).isActive = true
        
        view.addSubview(picker)
        picker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        picker.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        picker.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        picker.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        picker.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        view.addSubview(doneButton)
        doneButton.topAnchor.constraint(equalTo: picker.bottomAnchor, constant: 10).isActive = true
        doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        doneButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
}
