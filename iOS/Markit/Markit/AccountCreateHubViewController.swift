//
//  AccountCreateHubViewController.swift
//  Markit
//
//  Created by Victor Frolov on 9/27/16.
//  Copyright © 2016 Victor Frolov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class AccountCreateHubViewController: UIViewController {
    var ref: FIRDatabaseReference!
    @IBOutlet weak var hub:UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var paymentPreference: UITextField!
    @IBOutlet weak var markedHub:UIImageView!
    @IBOutlet weak var markedUsername: UIImageView!
    @IBOutlet weak var markedPaymentPreference: UIImageView!
    @IBOutlet weak var badUsername: UILabel!
    @IBOutlet weak var paymentCashButton: UIButton!
    @IBOutlet weak var paymentVenmoButton: UIButton!
    @IBOutlet weak var paymentOtherButton: UIButton!
    var userInfo: [String]!
    var paymentPreferenceDict = [String:String]()
    

    @IBAction func finishSignup(_ sender: AnyObject) {
        if !markedHub.isHidden && !markedUsername.isHidden && !markedPaymentPreference.isHidden {
            FIRAuth.auth()?.createUser(withEmail: userInfo[2], password: userInfo[3]) { (user, error) in
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE MMM dd yyy hh:mm:ss 'GMT'Z (zzz)"
                let currentDate = dateFormatter.string(from: date as Date)
                
                NSLog(String(format: "Successfully created user: %@", self.userInfo[2]))
                let uidRef = self.ref.child("/users/" + user!.uid)
                let userJson = ["dateCreated"       : currentDate,
                                "email"             : self.userInfo[2],
                                "favorites"         : "",
                                "firstName"         : self.userInfo[0],
                                "lastName"          : self.userInfo[1],
                                "uid"               : user!.uid,
                                "userHub"           : self.hub.text!,
                                "username"          : self.username.text!,
                                "rating"            : "-1",
                                "paymentPreference" : self.paymentPreferenceDict] as [String : Any]
                uidRef.setValue(userJson)
                
                FIRAuth.auth()!.signIn(withEmail: self.userInfo[2], password: self.userInfo[3]){ (user, error) in
                    if let error = error {
                        print("Sign in failed:", error.localizedDescription)
                    } else {
                        print("user signed in")
                        self.dismiss(animated: false, completion: {
                            self.performSegue(withIdentifier: "successCreateAccount", sender: self)
                        })
                    }
                }
                
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        
        markedHub.isHidden = true
        markedUsername.isHidden = true
        markedPaymentPreference.isHidden = true
        badUsername.isHidden = true
        
        drawButtonWhiteBorder(button: paymentCashButton)
        drawButtonWhiteBorder(button: paymentVenmoButton)
        drawButtonWhiteBorder(button: paymentOtherButton)
        
    }
    
    @IBAction func cashButtonSelected(sender: AnyObject) {
        buttonSelect(button: paymentCashButton)
        paymentPreferenceDict["0"] = paymentCashButton.isSelected ? "cash" : nil
    }
    
    @IBAction func venmoButtonSelected(sender: AnyObject) {
        buttonSelect(button: paymentVenmoButton)
        paymentPreferenceDict["1"] = paymentVenmoButton.isSelected ? "venmo" : nil
    }
    
    @IBAction func otherButtonSelected(sender: AnyObject) {
        buttonSelect(button: paymentOtherButton)
        paymentPreferenceDict["2"] = paymentOtherButton.isSelected ? "other" : nil
    }
    
    func buttonSelect(button: UIButton) {
        if (!button.isSelected) {
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.black, for: .selected)
            button.isSelected = true
            self.markedPaymentPreference.isHidden = false
        } else {
            button.backgroundColor = UIColor.clear
            button.isSelected = false
        }
        if (!paymentCashButton.isSelected && !paymentVenmoButton.isSelected && !paymentOtherButton.isSelected) {
            self.markedPaymentPreference.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        username.becomeFirstResponder()
    }
    
    func isValidUsername(testStr:String) -> Bool {
        let usernameRegEx = "[A-Z0-9a-z]+"
        let usernameTest = NSPredicate(format:"SELF MATCHES %@", usernameRegEx)
        return usernameTest.evaluate(with: testStr)
    }
    
    func drawButtonWhiteBorder(button: UIButton) {
        button.backgroundColor = .clear
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if username.text!.characters.count > 2 {
            let namesRef = ref.child("/usernames")

            namesRef.observeSingleEvent(of: FIRDataEventType.value, with: {
                snap in
                
                if !self.isValidUsername(testStr: self.username.text!) {
                    self.badUsername.text = "Sorry, only letters and numbers allowed"
                    self.badUsername.isHidden = false
                    self.markedUsername.isHidden = true
                } else if snap.hasChild(self.username.text!.lowercased()) {
                    print("name exists")
                    self.badUsername.text = "Sorry, that username is taken :("
                    self.badUsername.isHidden = false
                    self.markedUsername.isHidden = true
                } else {
                    print("name does not exist!")
                    self.badUsername.isHidden = true
                    self.markedUsername.isHidden = false
                }
            })
        }
        //actually set up the hub selectin feature later
        //for now it's a dumby number of 5
        let dumbyFakeApproval = 2
        markedHub.isHidden = hub.text!.characters.count >= dumbyFakeApproval ? false : true
    }
    
    func drawWhiteBottomBorder(textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(origin: CGPoint(x: 0, y:textField.frame.height - 1), size: CGSize(width: textField.frame.width, height:  1))
        bottomLine.backgroundColor = UIColor.white.cgColor
        textField.borderStyle = UITextBorderStyle.none
        textField.layer.addSublayer(bottomLine)
    }

    override func viewDidLayoutSubviews() {
        hub.addTarget(self, action: #selector(self.textViewDidChange), for: .editingChanged)
        username.addTarget(self, action: #selector(self.textViewDidChange), for: .editingChanged)
        paymentPreference.addTarget(self, action: #selector(self.textViewDidChange), for: .editingChanged)
        
        drawWhiteBottomBorder(textField: hub)
        drawWhiteBottomBorder(textField: username)
        drawWhiteBottomBorder(textField: paymentPreference)

    }

}
