//
//  NewListingViewController.swift
//  Markit
//
//  Created by Victor Frolov on 9/21/16.
//  Copyright © 2016 Victor Frolov. All rights reserved.
//

import UIKit

class NewListingViewController: UIViewController, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var itemImage:UIImageView!
    
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    @IBAction func takePicture(sender: UIButton) {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            if (UIImagePickerController.isCameraDeviceAvailable(.rear)) {
            
                imagePicker.sourceType = .camera
                imagePicker.cameraCaptureMode = .photo
                present(imagePicker, animated: true, completion: {})
                print("yay")
                
            } else {
                print("no rear camera")
            }
        } else {
            print("noo")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("inside imagePickerController func")
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            itemImage.contentMode = .scaleToFill
            itemImage.image = pickedImage
            print("allegedly picked image lole)")
        }
    }
    
    
    @IBAction func unwindPrice(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindTitle(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindDescription(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindTag(segue: UIStoryboardSegue) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
