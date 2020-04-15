//
//  SearchViewController.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 2/13/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTableView: UITableView!
    var bestMatches: Array<Search>!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bestMatches = []
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchBar.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    func searchStockByKeyword (keyword: String) {
        let url = URL(string: "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=" + keyword.replacingOccurrences(of: " ", with: "%20") + "&apikey=" + APIKeyAV)
        let data = try? Data(contentsOf: url!)
        if data == nil {
            bestMatches = []
            return
        }
        let APIResults = try? JSONDecoder().decode(APISearchResults.self, from: data!)
        if APIResults == nil {
            bestMatches = []
        } else {
            bestMatches = APIResults?.bestMatches
        }
    }
    

    @IBAction func searchButtonClicked(_ sender: Any) {
        let searchText = self.searchBar.text!
        searchStockByKeyword(keyword: searchText)
        self.searchTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bestMatches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "StockCell")
        cell.textLabel?.text = String(bestMatches[indexPath.row].symbol)
        cell.detailTextLabel?.text = String(bestMatches[indexPath.row].name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showStockInfo", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "showStockInfo" {
            let destination = segue.destination as? StockInfoViewController
            let stockIndex = sender as! Int
            destination!.symbol = bestMatches[stockIndex].symbol
            destination!.name = bestMatches[stockIndex].name
        }
    }
}
