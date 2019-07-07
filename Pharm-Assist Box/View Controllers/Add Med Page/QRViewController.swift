//
//  QRViewController.swift
//  Pharm-Assist Box
//
//  Created by Chris Kasper on 1/18/19.
//  Copyright © 2019 Chris Kasper. All rights reserved.
//

import UIKit
import AVFoundation

protocol QRViewControllerDelegate {
    func didFinishQRView(controller: QRViewController)
}

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    var video = AVCaptureVideoPreviewLayer()
    var qrCode = Dictionary<String, String>()
    var delegate: QRViewControllerDelegate! = nil
    
    // Create session
    let session = AVCaptureSession()
    
    let square: UIImageView = {
        let image = UIImage(named: "check-box-empty")
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "QR Code Scanner"
        
        // Define capture device
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
            
        }
        catch {
            print("Error with camera session\n")
        }
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        view.layer.addSublayer(video)
        
        view.addSubview(square)
        
        square.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        square.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.bringSubviewToFront(square)
        
        session.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == AVMetadataObject.ObjectType.qr {
                    sleep(1)
                    self.session.stopRunning()
                    let pillName = String(object.stringValue!.split(separator: ";")[0])
                    let alert = UIAlertController(title: "QR Code", message: "This is a code for " + pillName + ". Is this the right code?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retake", style: .default, handler: { (nil) in
                        self.session.startRunning()
                    }))
                    alert.addAction(UIAlertAction(title: "Proceed", style: .default, handler: { (nil) in
                        let qrString = object.stringValue
                        self.checkQRCode(qrString: qrString!)
                    }))
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func checkQRCode(qrString: String) {
        let qrSplit = qrString.split(separator: ";")
        if qrSplit.count != 5 {
            let alert = UIAlertController(title: "QR Code Invalid", message: "This is not the proper QR code for a Pharm-Assist Box medication", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            // tpd = times per day, numPer = number of pills per dosage, tib = time in between (in seconds)
            let pillDic = ["name": String(qrSplit[0]),"dosage": String(qrSplit[1]),"numPills": String(qrSplit[2]),"numPer": String(qrSplit[3]),"tpd": String(qrSplit[4])] //,"tib": String(qrSplit[5])]
            self.qrCode = pillDic
            navigationController?.popViewController(animated: true)
            delegate.didFinishQRView(controller: self)
        }
    }
}
