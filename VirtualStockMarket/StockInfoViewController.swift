//
//  StockInfoViewController.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 2/19/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import Charts

class StockInfoViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var symbol: String!
    var name: String!
    var high: Float!
    var low: Float!
    var open:Float!
    var close: Float!           //actual price of the stock
    var yesterdayClose: Float!
    var volume: Float!
    var yearHigh: Float!
    var yearLow: Float!
    var avgCost: Float!
    
    var mostRecentStockPrices: Array<Float>!
    var macd: Array<Float>!
    var macdSignal: Array<Float>!
    var ma: Array<Float>!
    var rsi: Array<Float>!
    var ema: Array<Float>!
    
    var watchlist: Array<String>!

    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!

    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var Volume: UILabel!
    @IBOutlet weak var lowYlabel: UILabel!
    @IBOutlet weak var highYlabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var avgCostLabel: UILabel!
    @IBOutlet weak var todayReturnLabel: UILabel!
    @IBOutlet weak var totalReturnLabel: UILabel!
    
    var dayInPriceGraph = 7;
    
    @IBAction func WeekPrice(_ sender: Any) {
        dayInPriceGraph = 7
        updatePriceGraph()
    }
    @IBAction func OneMonthPrice(_ sender: Any) {
        dayInPriceGraph = 30
        updatePriceGraph()
    }
    @IBAction func ThreeMonthPrice(_ sender: Any) {
        dayInPriceGraph = 90
        updatePriceGraph()
    }
    @IBAction func SixMonthPrice(_ sender: Any) {
        dayInPriceGraph = 180
        updatePriceGraph()
    }
    @IBAction func YearPrice(_ sender: Any) {
        dayInPriceGraph = 365
        updatePriceGraph()
    }
    
    
    @IBOutlet weak var indicatorTextField: UITextField!
    
    func createPickerView() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        indicatorTextField.inputView = pickerView
    }
    
    func dismissPickerView() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
       let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.closeSelection))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
       indicatorTextField.inputAccessoryView = toolBar
    }
    
    @objc func closeSelection() {
        view.endEditing(true)
        updateTechnicalIndicatorGraph()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return indicators.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return indicators[row] // dropdown item
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndicator = indicators[row] // selected item
        indicatorTextField.text = currentIndicator
    }
    
    var dayInTechnicalGraph = 7;
    var indicators = ["Moving Average(5)", "Exponential Moving Average(5)", "Relative Strength Index(14)", "Moving Average Convergence Divergence(12, 26, 9)"]
    var currentIndicator = "Moving Average(5)"
    
    
    @IBAction func OneWeekTechnical(_ sender: Any) {
        dayInTechnicalGraph = 7
        updateTechnicalIndicatorGraph()
    }
    @IBAction func OneMonthTechnical(_ sender: Any) {
        dayInTechnicalGraph = 30
        updateTechnicalIndicatorGraph()
    }
    @IBAction func ThreeMonthTechnical(_ sender: Any) {
        dayInTechnicalGraph = 90
        updateTechnicalIndicatorGraph()
    }
    @IBAction func SixMonthTechnical(_ sender: Any) {
        dayInTechnicalGraph = 180
        updateTechnicalIndicatorGraph()
    }
    @IBAction func YearTechnical(_ sender: Any) {
        dayInTechnicalGraph = 365
        updateTechnicalIndicatorGraph()
    }
    
    @IBOutlet weak var PriceChart: LineChartView!
    @IBOutlet weak var TechnicalIndicatorChart: LineChartView!
    @IBOutlet weak var changeLabel: UILabel!

    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var sellButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.get_avg_value() {val in
            self.avgCostLabel.text = "$" + String(format: "%.2f", val)
            self.get_num_stocks() {count in
                self.shareLabel.text = String(count)
                let todayDiff = (Double(self.close) - Double(self.yesterdayClose)) * Double(count)
                
                if todayDiff < 0 {
                    self.todayReturnLabel.text = "-$" + String(format: "%.2f", -todayDiff)
                    self.todayReturnLabel.textColor = UIColor(red: 244/255, green: 125/255, blue: 95/255, alpha: 1.0)
                } else if todayDiff > 0 {
                    self.todayReturnLabel.text = "$" + String(format: "%.2f", todayDiff)
                    self.todayReturnLabel.textColor = UIColor(red: 29.0/255.0, green: 204.0/255.0, blue: 155.0/255.0, alpha: 1.0)
                }
                

                let totalDiff = (Double(self.close) - val) * Double(count)
                if totalDiff < 0 {
                    self.totalReturnLabel.text = "-$" + String(format: "%.2f", -totalDiff)
                    self.totalReturnLabel.textColor = UIColor(red: 244/255, green: 125/255, blue: 95/255, alpha: 1.0)
                } else if totalDiff > 0 {
                    self.totalReturnLabel.text = "$" + String(format: "%.2f", totalDiff)
                    self.totalReturnLabel.textColor = UIColor(red: 29.0/255.0, green: 204.0/255.0, blue: 155.0/255.0, alpha: 1.0)
                }
                
            }
        }
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        createPickerView()
        dismissPickerView()
        mostRecentStockPrices = fetchStockData1Year(symbol: symbol)
        updatePriceGraph()
        (macd, macdSignal) = fetchMACEData1Year(symbol: symbol)
        ma = fetchMAData1Year(symbol: symbol)
        rsi = fetchRSIData1Year(symbol: symbol)
        ema = fetchEMAData1Year(symbol: symbol)
        updateTechnicalIndicatorGraph()
        
        high = 0.0
        low = 0.0
        close = 0.0
        yesterdayClose = 0.0
        yearHigh = 0.0
        yearLow = 0.0
        volume = 0
        open = 0.0
        avgCost = 0.0
        getStockData(symbol: symbol)
        
        if mostRecentStockPrices.count == 0 {
            let alert = UIAlertController(title: "Error",
            message: "Stock not available now!", preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "Back", style: .default, handler: { action in
                self.navigationController?.popViewController(animated: true)
             }))
             self.present(alert, animated: true, completion: nil)
            
        }

        if mostRecentStockPrices.count >= 2 {
            let todayPrice = mostRecentStockPrices[0]
            let yesterdayPrice = mostRecentStockPrices[1]
            yesterdayClose = yesterdayPrice
            if todayPrice >= yesterdayPrice {
                changeLabel.text = String(format: "+%.4f", (todayPrice - yesterdayPrice) / yesterdayPrice) + "%"
                changeLabel.textColor = UIColor(red: 8/256, green: 206/256, blue: 152/256, alpha: 1.0)
            } else {
                changeLabel.text = String(format: "-%.4f", (yesterdayPrice - todayPrice) / yesterdayPrice) + "%"
                changeLabel.textColor = UIColor(red: 244/256, green: 85/256, blue: 50/256, alpha: 1.0)
            }
        }
        
        
       self.isInWatchList(){bool in
        
        if(!bool){
            let addToWatchListButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addWatchList))
                self.navigationItem.rightBarButtonItem = addToWatchListButton
        }
        else{
            let removeToWatchListButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteFromWatchList))
           self.navigationItem.rightBarButtonItem = removeToWatchListButton
            }
        
        }
        
        symbolLabel.text = symbol;
        lowLabel.text = "$" + String(format: "%.2f", low) ;
        highLabel.text = "$" + String(format: "%.2f", high) ;
        lowYlabel.text = "$" + String(format: "%.2f", yearLow) ;
        Volume.text =  String(format: "%.2f", volume / 1000000) + "M" ;
        openLabel.text = "$" + String(format: "%.2f", open) ;
        highYlabel.text = "$" + String(format: "%.2f", yearHigh) ;
        avgCostLabel.text = "$" + String(format: "%.2f", avgCost)
        currentLabel.text = " $" + String(format: "%.3f", close) ;
        nameLabel.text = name;

        buyButton.backgroundColor = UIColor(red: 244/255, green: 125/255, blue: 95/255, alpha: 1.0)
        buyButton.setTitleColor(UIColor.white, for: .normal)
        buyButton.layer.cornerRadius = 14
        buyButton.layer.masksToBounds = true

        sellButton.backgroundColor = UIColor(red: 244/255, green: 125/255, blue: 95/255, alpha: 1.0)
        sellButton.setTitleColor(UIColor.white, for: .normal)
        sellButton.layer.cornerRadius = 14
        sellButton.layer.masksToBounds = true
    }

    func getStockData(symbol: String) {
        getStockName()
        let url = URL(string: "https://api.twelvedata.com/time_series?symbol=" + symbol + "&apikey=" + APIKeyTwelveData + "&interval=1day&outputsize=1095")
        let data = try? Data(contentsOf: url!)
        let APIResults = try? JSONDecoder().decode(APIResultsStockHistory.self, from: data!)
        if APIResults == nil {
            return
        }

        yearHigh = APIResults!.values[0].high
        yearLow = APIResults!.values[0].low
        for stockResult in APIResults!.values {
            yearHigh = max(yearHigh, stockResult.high)
            yearLow = min(yearLow, stockResult.low)
        }
        open = APIResults!.values[0].open
        high = APIResults!.values[0].high
        low = APIResults!.values[0].low
        close = APIResults!.values[0].close
        volume = APIResults!.values[0].volume
        
    }

    @IBAction func buy_stock(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            print("singed in ")
        } else {
          print("not signed in")
        }

    }
    
    func get_avg_value(completion: @escaping(Double) -> ()){
        let db = Firestore.firestore()
        db.collection("current_stocks").whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).whereField("symbol", isEqualTo: symbol!).getDocuments() {(result, error) in
            
            if error != nil{
                    print(error?.localizedDescription)
                  }
                  else{
        
                    if(result?.count != 0){
                          for document in result!.documents {
                            if(document.data()["quantity_owned"] as! Double > 0){
                            completion(document.data()["average_price"] as! Double)
                            }
                        }
                }
                    else{
                        completion(0)
                }
                
            }
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is Buy
        {

            let buy = segue.destination as? Buy
            buy?.close = close!

            let date=Date()
            buy?.date = String("\(date)".split(separator: " ")[0])
            buy?.name = name!


            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)

            buy?.time = String(hour)+":"+String(minutes)

            buy?.symbol = symbol!

    }

        if segue.destination is Sell
            {

                let sell = segue.destination as? Sell
                sell?.close = close!

                let date=Date()
                sell?.date = String("\(date)".split(separator: " ")[0])
                sell?.name = name!

                let calendar = Calendar.current
                let hour = calendar.component(.hour, from: date)
                let minutes = calendar.component(.minute, from: date)

                sell?.time = String(hour)+":"+String(minutes)

                sell?.symbol = symbol!
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


    func updatePriceGraph(){
        var stonks = [Double]()
        for i in mostRecentStockPrices {
            stonks.insert(Double(i), at: 0)
            if stonks.count == dayInPriceGraph {break}
        }

        if stonks.count != dayInPriceGraph {
            for _ in stonks.count...dayInPriceGraph - 1 {
                stonks.insert(0, at: 0);
            }
        }

        var lineChartEntry  = [ChartDataEntry]()

        for i in 0..<stonks.count {
          let value = ChartDataEntry(x: Double(i), y: stonks[i])
          lineChartEntry.append(value)
        }

        let line1 = LineChartDataSet(entries: lineChartEntry)
        line1.colors = [NSUIColor.green]
        line1.drawCirclesEnabled = false;

        let data = LineChartData()

        data.addDataSet(line1)
        data.setDrawValues(false)

        PriceChart.data = data
        PriceChart.legend.enabled = false
        PriceChart.rightAxis.drawLabelsEnabled = false
      }
    
    func updateTechnicalIndicatorGraph() {
        if currentIndicator == "Moving Average Convergence Divergence(12, 26, 9)" {
           updateMACDGraph()
        } else if currentIndicator == "Moving Average(5)" {
            updateMAGraph()
        } else if currentIndicator == "Relative Strength Index(14)" {
            updateRSIGraph()
        } else if currentIndicator == "Exponential Moving Average(5)" {
            updateEMAGraph()
        }
    }
    
    func updateMACDGraph() {
        var macdPoints = [Double]()
        var macdSignalPoints = [Double]()
        for i in macd {
            macdPoints.insert(Double(i), at: 0)
            if macdPoints.count == dayInTechnicalGraph {break}
        }
        
        for i in macdSignal {
            macdSignalPoints.insert(Double(i), at: 0)
            if macdSignalPoints.count == dayInTechnicalGraph {break}
        }

        if macdPoints.count != dayInTechnicalGraph {
            for _ in macdPoints.count...dayInTechnicalGraph - 1 {
                macdPoints.insert(0, at: 0);
            }
        }
        
        if macdSignalPoints.count != dayInTechnicalGraph {
            for _ in macdSignalPoints.count...dayInTechnicalGraph - 1 {
                macdSignalPoints.insert(0, at: 0);
            }
        }

        var macdLineChartEntry  = [ChartDataEntry]()
        var macdSignalLineChartEntry  = [ChartDataEntry]()

        for i in 0..<macdPoints.count {
          let value = ChartDataEntry(x: Double(i), y: macdPoints[i])
          macdLineChartEntry.append(value)
        }
        
        for i in 0..<macdSignalPoints.count {
          let value = ChartDataEntry(x: Double(i), y: macdSignalPoints[i])
          macdSignalLineChartEntry.append(value)
        }

        let macdLine = LineChartDataSet(entries: macdLineChartEntry)
        macdLine.colors = [NSUIColor.blue]
        macdLine.drawCirclesEnabled = false;
        
        let macdSignalLine = LineChartDataSet(entries: macdSignalLineChartEntry)
        macdSignalLine.colors = [NSUIColor.red]
        macdSignalLine.drawCirclesEnabled = false;

        let data = LineChartData()

        data.addDataSet(macdLine)
        data.addDataSet(macdSignalLine)
        data.setDrawValues(false)

        TechnicalIndicatorChart.data = data
        TechnicalIndicatorChart.legend.enabled = false
        TechnicalIndicatorChart.rightAxis.drawLabelsEnabled = false
    }
    
    func updateMAGraph() {
        var maPoints = [Double]()
        for i in ma {
            maPoints.insert(Double(i), at: 0)
            if maPoints.count == dayInTechnicalGraph {break}
        }


        if maPoints.count != dayInTechnicalGraph {
            for _ in maPoints.count...dayInTechnicalGraph - 1 {
                maPoints.insert(0, at: 0);
            }
        }

        var maLineChartEntry  = [ChartDataEntry]()

        for i in 0..<maPoints.count {
          let value = ChartDataEntry(x: Double(i), y: maPoints[i])
          maLineChartEntry.append(value)
        }

        let maLine = LineChartDataSet(entries: maLineChartEntry)
        maLine.colors = [NSUIColor.magenta]
        maLine.drawCirclesEnabled = false;

        let data = LineChartData()

        data.addDataSet(maLine)
        data.setDrawValues(false)

        TechnicalIndicatorChart.data = data
        TechnicalIndicatorChart.legend.enabled = false
        TechnicalIndicatorChart.rightAxis.drawLabelsEnabled = false
    }
    
    func updateRSIGraph() {
        var rsiPoints = [Double]()
        for i in rsi {
            rsiPoints.insert(Double(i), at: 0)
            if rsiPoints.count == dayInTechnicalGraph {break}
        }


        if rsiPoints.count != dayInTechnicalGraph {
            for _ in rsiPoints.count...dayInTechnicalGraph - 1 {
                rsiPoints.insert(0, at: 0);
            }
        }

        var rsiLineChartEntry  = [ChartDataEntry]()

        for i in 0..<rsiPoints.count {
          let value = ChartDataEntry(x: Double(i), y: rsiPoints[i])
          rsiLineChartEntry.append(value)
        }

        let rsiLine = LineChartDataSet(entries: rsiLineChartEntry)
        rsiLine.colors = [NSUIColor.orange]
        rsiLine.drawCirclesEnabled = false;

        let data = LineChartData()

        data.addDataSet(rsiLine)
        data.setDrawValues(false)

        TechnicalIndicatorChart.data = data
        TechnicalIndicatorChart.legend.enabled = false
        TechnicalIndicatorChart.rightAxis.drawLabelsEnabled = false
    }
    
    func updateEMAGraph() {
        var emaPoints = [Double]()
        for i in ema {
            emaPoints.insert(Double(i), at: 0)
            if emaPoints.count == dayInTechnicalGraph {break}
        }


        if emaPoints.count != dayInTechnicalGraph {
            for _ in emaPoints.count...dayInTechnicalGraph - 1 {
                emaPoints.insert(0, at: 0);
            }
        }

        var emaLineChartEntry  = [ChartDataEntry]()

        for i in 0..<emaPoints.count {
          let value = ChartDataEntry(x: Double(i), y: emaPoints[i])
          emaLineChartEntry.append(value)
        }

        let emaLine = LineChartDataSet(entries: emaLineChartEntry)
        emaLine.colors = [NSUIColor.blue]
        emaLine.drawCirclesEnabled = false;

        let data = LineChartData()

        data.addDataSet(emaLine)
        data.setDrawValues(false)

        TechnicalIndicatorChart.data = data
        TechnicalIndicatorChart.legend.enabled = false
        TechnicalIndicatorChart.rightAxis.drawLabelsEnabled = false
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
    
    func update_watchlist(list:Array<String>){
        
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(["watchlist": list])
               
    }
    
    @objc func addWatchList(sender: UIButton!) {
        
        get_watchlist() { list in
            var final_list =  list
           
            if !final_list.contains(self.symbol!){

                      print("it doesn't contain ")
                      final_list.append(self.symbol!)
                      let removeToWatchListButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.deleteFromWatchList))
                     
                self.navigationItem.rightBarButtonItem = removeToWatchListButton
                self.update_watchlist(list:final_list)

                  }
        }
        
    }
    
    @objc func deleteFromWatchList(sender: UIButton!) {
        //code to delete from watchlist
        get_watchlist() { list in
            var final_list:Array<String> =  []
           
            if list.contains(self.symbol!){
                        for item in list{
                                
                            if(item != self.symbol!){
                                
                                final_list.append(item)
                                
                            }
                        }
                     let addToWatchListButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addWatchList))
                     self.navigationItem.rightBarButtonItem = addToWatchListButton
                      
                      self.update_watchlist(list:final_list)

                  }
        }
        
    }

    func getStockName() {
        let url = URL(string: "https://api.twelvedata.com/stocks?symbol=" + symbol)
        let data = try? Data(contentsOf: url!)
        let APIResults = try? JSONDecoder().decode(APIResultsStockInfo.self, from: data!)
        if APIResults == nil || APIResults!.data.count == 0 {
            return
        }
        
        name = APIResults!.data[0].name
        
    }
    
    func isInWatchList(completion: @escaping(Bool) -> ()){
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).getDocument { (document, error) in
            
            if error == nil {
                var bool = false
                if let document = document, document.exists {
                    let data  = document.data()
                    let list = data!["watchlist"] as! Array<String>
                    bool = list.contains(self.symbol!)
                    completion(bool)
                    
                  }
            }
        }
        
    }


}
