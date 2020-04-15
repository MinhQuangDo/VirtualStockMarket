//
//  StockTableViewController.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 3/29/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import Firebase

struct Stock{
    var name : String
    var price: String
    var trend: String
}

class StockTableViewController: UITableViewController {
    
    var stockData = [
        Stock(name: "AAPL", price: "", trend: ""),
        Stock(name: "FB", price: "", trend: ""),
        Stock(name: "TSLA", price: "", trend: ""),
        Stock(name: "GOOGL", price: "", trend: "")
    ]
    
    var watchList :Array<Stock> = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBalance() {balance in
        self.navigationItem.title = "Investing: $" + String(format: "%.2f", balance)
        }
        
        let group = DispatchGroup()
        group.enter()
        self.watchList = []
        
        self.get_watchlist() { list in
            for stock in list{
                self.watchList.append(Stock(name: stock, price: "", trend: ""))
            }
            for i in 0..<self.watchList.count {
                let stockObject = self.getStockData(symbol: self.watchList[i].name)
                self.watchList[i] = stockObject
            }
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell1")
        
        for i in 0..<self.stockData.count {
            let stockObject = self.getStockData(symbol: self.stockData[i].name)
            self.stockData[i] = stockObject
        }
        
        
        let logOutButton = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
        logOutButton.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "Thonburi-bold", size: 22)!], for: .normal)
        logOutButton.tintColor = UIColor(red: 244/255, green: 125/255, blue: 95/255, alpha: 1.0)
        navigationItem.rightBarButtonItem = logOutButton
        
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return stockData.count
        }
        return watchList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StockCell
        
        let sectionData = indexPath.section == 0 ? stockData[indexPath.row] : watchList[indexPath.row]
        
        if (indexPath.section == 0) {
            if stockData[indexPath.row].trend == "up" {
                cell.stockPrice.backgroundColor = UIColor(red: 29.0/255.0, green: 204.0/255.0, blue: 155.0/255.0, alpha: 1.0)
            } else {
                cell.stockPrice.backgroundColor = UIColor(red: 244/255, green: 125/255, blue: 95/255, alpha: 1.0)
            }
        } else{
            if watchList[indexPath.row].trend == "up" {
                cell.stockPrice.backgroundColor = UIColor(red: 29.0/255.0, green: 204.0/255.0, blue: 155.0/255.0, alpha: 1.0)
            } else {
                cell.stockPrice.backgroundColor = UIColor(red: 244/255, green: 125/255, blue: 95/255, alpha: 1.0)
            }
        }

        cell.stockPrice.textColor = UIColor.white
        cell.stockPrice.layer.cornerRadius = 8
        cell.stockPrice.layer.masksToBounds = true


        cell.stockName.text = sectionData.name
        cell.stockPrice.text = sectionData.price

        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        if(section == 0){
            label.text = "  Trending Stocks"
        }
        if(section == 1){
            label.text = "  Watch List"
        }
        label.font = UIFont (name: "Thonburi-bold", size: 22)
        return label
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "stockshift", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "stockshift" {
            let destination = segue.destination as? StockInfoViewController
            let indexPath = sender as! IndexPath
            if indexPath.section == 0 {
                destination!.symbol = stockData[indexPath.row].name
            } else {
                destination!.symbol = watchList[indexPath.row].name
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
    
    func getStockData(symbol: String) -> Stock{
        var price = 0.0
        var trend = "up"
        let twoDaysData = fetchStockData2Days(symbol: symbol)
        if twoDaysData.count == 2 {
            price = Double(twoDaysData[0])
            if price >= Double(twoDaysData[1]) {
                trend = "up"
            } else {
                trend = "down"
            
            }
        }
        
        return Stock(name: symbol, price: String(format: "$%.2f", price), trend: trend)
        
    }
    
    func get_watchlist(completion: @escaping(Array<String>) -> ()) {
        let db = Firestore.firestore()
     
         db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            
               var watch: Array<String>
                   if error == nil {
                      if let document = document, document.exists {
                               let data  = document.data()
                               watch = data!["watchlist"] as! Array<String>
                               completion(watch)
                           }
                       }
                       else{
                           completion(["error"])
                       }
                   }
        
    }
    
    @objc func logOut(sender: UIButton!) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        
        self.performSegue(withIdentifier: "logOut", sender: "nil")
    }
}
