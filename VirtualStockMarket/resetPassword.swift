//
//  resetPassword.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 3/17/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class resetPassword: UIViewController {
    override func viewDidLoad() {
        
    }
    @IBOutlet weak var email: UITextField!
    
    @IBAction func reset_password(_ sender: Any) {
     
        let email_text = self.email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if email_text != "" {
            Auth.auth().sendPasswordReset(withEmail: email_text) {(error)  in
                
                if error != nil {
                    
                    print(error?.localizedDescription)
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else{
                    let alert = UIAlertController(title: "No error", message: "You've recieved an email to reset your password", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }
        else{
            let alert = UIAlertController(title: "Error", message: "no email was filled in, try again", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}
