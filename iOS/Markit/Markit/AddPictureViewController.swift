//
//  AddPictureViewController.swift
//  Markit
//
//  Created by Trixie on 12/5/16.
//  Copyright © 2016 Victor Frolov. All rights reserved.
//

import UIKit
import AVFoundation

class AddPictureViewController: UIViewController {
    
    @IBOutlet weak var takeAPicture: UIView!
    
    let captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        captureSession.sessionPreset = AVCaptureSessionPresetLow
//        let devices = AVCaptureDeviceDiscoverySession.self
//        print(devices)
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
