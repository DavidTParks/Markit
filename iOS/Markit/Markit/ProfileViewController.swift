//
//  ProfileViewController.swift
//  Markit
//
//  Created by Bryan Ku on 10/13/16.
//  Copyright © 2016 Victor Frolov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ProfileViewController: UIViewController {
    @IBOutlet var collectionOfStars: Array<UIImageView>?
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var notificationsButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var profileBackGround: UIImageView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var firstLastNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var hubLabel: UILabel!
    @IBOutlet weak var noRatingLabel: UILabel!
    @IBOutlet weak var otherPaymentLabel: UILabel!
    @IBOutlet weak var venmoPaymentLabel: UILabel!
    @IBOutlet weak var cashPaymentLabel: UILabel!
    var ref: FIRDatabaseReference!
    var firstName = "", lastName = "", paymentPreference : NSArray = []
    var profilePic = UIImage(named: "profilepicture")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawButtonWhiteBorder(button: editButton)
        drawButtonWhiteBorder(button: logOutButton)
        
        for star in collectionOfStars! {
            star.isHidden = true
        }
        self.pageControl.currentPageIndicatorTintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.black
        definesPresentationContext = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToEditProfile" {
            if let destination = segue.destination as? EditProfileViewController {
                destination.firstName         = self.firstName
                destination.lastName          = self.lastName
                destination.email             = self.emailLabel.text!
                destination.username          = self.usernameLabel.text!
                destination.hub               = self.hubLabel.text!
                destination.paymentPreference = self.paymentPreference
                destination.profilePic        = self.profilePic!
            }
        }
        if let profilePageViewController = segue.destination as? ProfilePageViewController {
            profilePageViewController.profileDelegate = self
        }
    }
    
    @IBAction func unwindEditProfile(segue: UIStoryboardSegue) { }
    
    @IBAction func unwindNotifications(segue: UIStoryboardSegue) { }
    
    @IBAction func logOut(sender: UIButton) {
        try! FIRAuth.auth()!.signOut()
        self.dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: "segueBackToLogin", sender: self)
        })
    }
    
    override func viewDidLayoutSubviews() {
        makeProfilePicCircular()
        updateProfilePic()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateProfile()
        updateProfilePic()
    }
    
    func updateProfilePic() {
        let user = FIRAuth.auth()?.currentUser
        let storage = FIRStorage.storage()
        let storageRef = storage.reference(forURL: "gs://markit-80192.appspot.com")
        let profilePicRef = storageRef.child("images/profileImages/\(user!.uid)/imageOne")
        
        profilePicRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            if (error != nil) {
                print("NO PICTURE????")
                self.profilePicture.image = self.profilePic
            } else {
                // Data for "images/island.jpg" is returned
                // ... let islandImage: UIImage! = UIImage(data: data!)
                self.profilePic = UIImage(data: data!)
                self.profilePicture.contentMode = .scaleAspectFill
                //self.makeProfilePicCircular()
                self.profilePicture.image = self.profilePic
            }
        }
    }
    
    func makeProfilePicCircular() {
        profilePicture.layer.borderWidth = 3
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.clear.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
    }
    
    func drawButtonWhiteBorder(button: UIButton) {
        button.backgroundColor = .clear
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    func updateProfile() {
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            self.firstName = value?["firstName"] as? String ?? ""
            self.lastName = value?["lastName"] as? String ?? ""
            let name = "\(self.firstName) \(self.lastName)"
            let email = value?["email"] as? String ?? ""
            let hub = value?["userHub"] as? String ?? ""
            let rating = value?["rating"] as? String ?? "-1"
            let stars = Int(rating)! - 1
//            self.paymentPreference = value?["paymentPreference"] as! NSArray
            self.paymentContains(array: self.paymentPreference, paymentOptions: ["cash", "venmo", "other"])
            
            self.firstLastNameLabel.text = name
            self.usernameLabel.text = username
            self.emailLabel.text = email
            self.hubLabel.text = hub
            
            if (rating != "-1" && stars <= 4) {
                for i in 0...stars {
                    self.collectionOfStars![i].isHidden = false
                }
                self.noRatingLabel.isHidden = true
            } else {
                self.noRatingLabel.isHidden = false
            }
            
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func paymentContains(array: NSArray, paymentOptions: [String]) {
        cashPaymentLabel.textColor = UIColorFromRGB(rgbValue: 0xCACACA)
        venmoPaymentLabel.textColor = UIColorFromRGB(rgbValue: 0xCACACA)
        otherPaymentLabel.textColor = UIColorFromRGB(rgbValue: 0xCACACA)
        print("ADFA \(array)")
        
        for option in paymentOptions {
            if array.contains(option) {
                if (option == "cash") {
                    cashPaymentLabel.textColor = UIColor.gray
                } else if (option == "venmo") {
                    venmoPaymentLabel.textColor = UIColor.gray
                } else if (option == "other") {
                    otherPaymentLabel.textColor = UIColor.gray
                }
            }
        }
    }
    
    private func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}
