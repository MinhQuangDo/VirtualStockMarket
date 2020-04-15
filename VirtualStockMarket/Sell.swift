//
//  Sell.swift
//  VirtualStockMarket
//
//  Created by Steven Toribio on 3/29/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class Sell: UIViewController {

    
    
   var close: Float!
   var name: String!
   var symbol: String!
   var date: String!
   var time: String!
    var num_stocks: Int!
    var final_bal:Double = 0.0
    
    @IBOutlet weak var company_symbol: UILabel!
    @IBOutlet weak var price_of_stock: UILabel!
    @IBOutlet weak var input_quantity: UITextField!
    @IBOutlet weak var number_stocks_owned: UILabel!
    
    @IBOutlet weak var current_balance: UILabel!
    @IBOutlet weak var sellButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        

        // Do any additional setup after loading the view.
        sellButton.backgroundColor = UIColor(red: 244/255, green: 125/255, blue: 95/255, alpha: 1.0)
        sellButton.setTitleColor(UIColor.white, for: .normal)
        sellButton.layer.cornerRadius = 14
        sellButton.layer.masksToBounds = true
        
        check()
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
    
    func check (){
        
        
        print(close!)
        print(name!)
        print(symbol!)
        print(date!)
        print(time!)
        
        price_of_stock.text =  "$" + String(close!)
        company_symbol.text = symbol!
        self.get_num_stocks() {count in
            self.number_stocks_owned.text = "\(count)"
            self.num_stocks = count
        }
        self.getBalance() {balance in
            self.current_balance.text = "$\(balance)"
        }
        
        
    }
    
     func get_num_stocks(completion: @escaping(Int) -> ()){
        
        var total_quantity = 0
        
        let db = Firestore.firestore()
        db.collection("purchase_history").whereField("uid",isEqualTo: Auth.auth().currentUser!.uid).whereField("symbol", isEqualTo: symbol!).getDocuments { (result, error) in
            
            if  error != nil {
                           
                           print(error?.localizedDescription)
                           completion(-1)
                       }
            else{
                
            for document in result!.documents {
                total_quantity += document.data()["quantity_bought"] as! Int
                }
                
             completion(total_quantity)
                
            }
    
        
    }
    }


    @IBAction func sell(_ sender: Any) {
        if(valid_input()){
        if(self.num_stocks>=Int(input_quantity.text!)!){
            self.getBalance{ bal in
               
                
                var cost = Double(self.input_quantity.text!)!
                cost = cost * Double(self.close!)
                self.final_bal = bal+cost
                
            }
            send_purchase_db()
            
        }
        else{
            let alert = UIAlertController(title: "Error",
            message: "You do not have enough stocks to sell this quantity of stocks", preferredStyle: .alert)
             let okAction = UIAlertAction(title: "Ok", style:
            UIAlertAction.Style.default)
             alert.addAction(okAction)
             self.present(alert, animated: true, completion: nil)
        }
        }
        else{
            
            let alert = UIAlertController(title: "Error",
            message: "Your input is not valid, try again", preferredStyle: .alert)
             let okAction = UIAlertAction(title: "Ok", style:
            UIAlertAction.Style.default)
             alert.addAction(okAction)
             self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    func send_purchase_db(){
        let db = Firestore.firestore()
                             db.collection("purchase_history").addDocument(data: [
                               "uid": Auth.auth().currentUser!.uid,
                               "company_name":name!,
                               "symbol": symbol!,
                               "stock_price": close!,
                               "quantity_bought": Int(input_quantity.text!)! * -1,
                               "date_bought": date!,
                               "time_bought":time!
                               
                             ]) { err in
                                 if let err = err {
                                     print("Error adding document: \(err)")
                                 } else {
                                     print("Document added with ID:")
                                   let alert = UIAlertController(title: "Sucess",
                                   message: "Sell was sucessful", preferredStyle: .alert)
                                    let okAction = UIAlertAction(title: "Ok", style:
                                   UIAlertAction.Style.default)
                                    alert.addAction(okAction)
                                  self.present(alert, animated: true, completion: nil)
                                   self.get_avg_value()
                                   self.update_balance()
                                  self.get_num_stocks() {count in
                                                     self.number_stocks_owned.text = "\(count)"
                                                     self.num_stocks=count
                                                 }
                                   
                                 }
                             }
        
    
    }
    
    func get_avg_value(){
        var avg_value  = 0.0
        var total_quantity = 0
        
        let db = Firestore.firestore()
        db.collection("purchase_history").whereField("uid",isEqualTo: Auth.auth().currentUser!.uid).whereField("symbol", isEqualTo: symbol!).getDocuments { (result, error) in
            
            if  error != nil {
                           
                           print(error?.localizedDescription)
                       }
            else{
                
            for document in result!.documents {
                total_quantity += document.data()["quantity_bought"] as! Int
                let quant = document.data()["quantity_bought"] as! Double
                let price = document.data()["stock_price"] as! Double
                avg_value += price * quant
                    
                }
                avg_value = avg_value/Double(total_quantity)
                
                print("avg val:\(avg_value)")
                print("total quant:\(total_quantity)")
                
                self.update_current_stocks(value: avg_value, quanitity: total_quantity)
                
            }
    
        
    }
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
    
    func update_balance(){
        let db = Firestore.firestore()
        self.final_bal = Double(round(100*final_bal)/100)
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["balance": self.final_bal])
        
        current_balance.text = "$\(self.final_bal)"
    
    }
    
    
    
    func update_current_stocks(value:Double,quanitity:Int){
        print("in this method")
         let db = Firestore.firestore()
        
        db.collection("current_stocks").whereField("uid",isEqualTo: Auth.auth().currentUser!.uid).whereField("symbol", isEqualTo: symbol!).getDocuments { (result, error) in
            
        
                  if error != nil{
                    
                    print(error?.localizedDescription)
            
                    
                  
                  }
                  else{
                    
                    
                    if(result?.count != 0){
                     
                     var doc_id = ""
                     for document in result!.documents {
                        
                       doc_id = document.documentID
                    }
                        
                        db.collection("current_stocks").document(doc_id).updateData([
                            "uid": Auth.auth().currentUser!.uid,
                            "symbol":self.symbol!,
                            "quantity_owned":quanitity,
                            "average_price":value
                        ])
                }
                    else{
                        
                        db.collection("current_stocks").addDocument(data: [
                        "uid": Auth.auth().currentUser!.uid,
                        "symbol": self.symbol!,
                        "quantity_owned": quanitity,
                        "average_price": value
                            
                        
                        ]){ err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID:")
                        
                          
                        }
                        
                    }
            
        }
        }
        
    }
        

}
    
    
    
    func valid_input() ->  Bool{
        
        if(input_quantity.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" && Int(input_quantity.text!)! > 0 ){
            return true
        }
        else{
            
             let alert = UIAlertController(title: "Error",
            message: "Not valid input, should be greater then 0", preferredStyle: .alert)
             let okAction = UIAlertAction(title: "Ok", style:
            UIAlertAction.Style.default)
             alert.addAction(okAction)
             self.present(alert, animated: true, completion: nil)
            
            return false
        }
        
    }
}
