//
//  AddTitleViewController.swift
//  Markit
//
//  Created by Victor Frolov on 9/27/16.
//  Copyright © 2016 Victor Frolov. All rights reserved.
//

import UIKit

class AddTitleViewController: UIViewController {
    
    @IBOutlet weak var itemTitle: UITextField!
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    @IBAction func tapButton(sender: UIButton) {
        let trimmedTitle = itemTitle.text!.trim()
        
        if trimmedTitle.characters.count > 4 && trimmedTitle.characters.count < 24 {
            performSegue(withIdentifier: "unwindAddTitle", sender: self)
        } else {
            let alertController = UIAlertController(title: "Invalid Title", message:
                "Please enter a valid title.\n(Ex. Used iPhone)", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        let fontSize: CGFloat = 30.0
        if itemTitle.text!.characters.count > 24 {
            itemTitleLabel.font = UIFont(name: "HelveticaNeue", size: (fontSize - 13.0))
            itemTitleLabel.text = "Please choose a shorter title\n (under 24 characters)."
        } else {
            itemTitleLabel.font = UIFont(name: "HelveticaNeue", size: fontSize)
            itemTitleLabel.text = itemTitle.text
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTitle.addTarget(self, action: #selector(self.textViewDidChange), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        itemTitle.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
