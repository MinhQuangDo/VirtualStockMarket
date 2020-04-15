//
//  register.swift
//  VirtualStockMarket
//
//  Created by Steven Toribio on 2/17/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class register: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet var first_name: UITextField!
    @IBOutlet var last_name: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func filled() -> Bool {

        if first_name.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            last_name.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {

                return false

        }

        return true

    }
    
    
    @IBAction func signup(_ sender: Any) {
        

        
        if filled() == false {
            

            let alert = UIAlertController(title: "Error", message: "Fill in all the forms in order to register for this app.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)

        }
        
        Auth.auth().createUser(withEmail: email.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: password.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (result,error) in
            
              if  error != nil {
                
                
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
               print(error?.localizedDescription)
            }
            else{
                let db = Firestore.firestore()
                db.collection("users").document(Auth.auth().currentUser!.uid).setData([
                    "first_name": self.first_name.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                    "last_name": self.last_name.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                    "balance": 50000,
                    "uid":Auth.auth().currentUser!.uid,
                    "watchlist": []
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID:")
                    }
                }
                
                self.email_vertification()
                self.first_name.text = ""
                self.last_name.text = ""
                self.email.text = ""
                self.password.text = ""
                let alert = UIAlertController(title: "Done", message: "You have sucefully registered, please check your inbox to vertify email", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    func email_vertification() {
        
        Auth.auth().signIn(withEmail: email.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: password.text!.trimmingCharacters(in: .whitespacesAndNewlines)) { (result, error) in
            
            if error == nil {
                Auth.auth().currentUser?.sendEmailVerification() { (error) in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription)
                    }
                    
                }
            }
            
        }
        
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
            
    }
    
}
