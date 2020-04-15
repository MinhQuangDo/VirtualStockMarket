//
//  Login.swift
//  VirtualStockMarket
//
//  Created by Steven Toribio on 2/17/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class Login: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var gifIcon: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "gifIcon", withExtension: "gif")!)
        let gifImage = UIImage.gif(data: imageData)
        gifIcon.image = gifImage
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
//        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
        
    func update_balance(){
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).setData(["balance":0],merge: true)
    
    }
    
    func getBalance(completion: @escaping(Double) -> ()){
        var bal:Double = 0.0
        
      let db = Firestore.firestore()
      db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            if error == nil {
               if let document = document, document.exists {
                        let data  = document.data()
                        bal = data!["balance"] as! Double
                        completion(bal)
                    }
                }
                else{
                    completion(-1)
                }
            }
        
    }
      

    @IBAction func login(_ sender: UIButton) {
        
        let email = self.email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let password = self.password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil{
               
                 let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                 let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
                 alert.addAction(okAction)
                 self.present(alert, animated: true, completion: nil)
                 print(error?.localizedDescription)
               
            
            }
            else{
                if(Auth.auth().currentUser!.isEmailVerified){
                    let db = Firestore.firestore()
                    db.collection("users").whereField("uid",isEqualTo: result!.user.uid).getDocuments { (result, error) in
                        
                        for document in result!.documents {
                            
                            let first_name = document.data()["first_name"]
                            let last_name = document.data()["last_name"]
                            let alert = UIAlertController(title: "Welcome", message: "Welcome to the market \(first_name!) \(last_name!)", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            
                            
                                
                            }
                            
                        }
                    
                    self.performSegue(withIdentifier: "wow", sender: "nil")
                  //  self.update_balance()
                    self.email.text = ""
                    self.password.text = ""
                    
                 
                    self.getBalance { (bal) -> () in
                        if bal > -1 {
                             print("balance: \(bal)")
                        }
                        else {
                             print("Not found")
                        }
                    }
                    
                   
                }
                else{
                    
                    Auth.auth().currentUser?.sendEmailVerification() { (error) in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription)
                    }
                    
                        do{
                          try Auth.auth().signOut()
                        } catch let signOutError as NSError {
                             print ("Error signing out: %@", signOutError)
                        }
                        
                    let alert = UIAlertController(title: "Email", message: "You have to vertify your email address before you can log in , check your inbox for an email from us!", preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default)
                                    alert.addAction(okAction)
                                    self.present(alert, animated: true, completion: nil)
                                    
                }
                    
                    
            
            }
                
            }
        
        }
    }
}
