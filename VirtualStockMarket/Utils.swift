//
//  Utils.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 2/27/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit
var APIKeyAV = "LIV7ZLBBYMUUB3T6"
var APIKeyWTD = "ozyaUTY1q1mtFjw2GjKyUVGdlxCemraRkl6wkz7aVHGNz9fXeSXH6HTlbIL9"
var APIKeyTwelveData = "eea7857f8c904b4f92efc71c6d19e57b"

//func fetchStockData2Days(symbol: String) -> Array<Float> {
//    var mostRecentPrices: Array<Float> = []
//    let url = URL(string: "https://api.worldtradingdata.com/api/v1/history?symbol=" + symbol + "&api_token=" + APIKeyWTD)
//    let data = try? Data(contentsOf: url!)
//    let APIResults = try? JSONDecoder().decode(APIResultsStockIntraday.self, from: data!)
//    if APIResults == nil {
//        return []
//    }
//    let mostRecentDays = APIResults!.history.sorted(by: { $0.key > $1.key })
//    for stockResult in mostRecentDays {
//        mostRecentPrices.append(stockResult.value.close)
//        if mostRecentPrices.count == 2 { break}
//    }
//    return mostRecentPrices
//}

//func fetchStockData3Year(symbol: String) -> Array<Float> {
//    var mostRecentPrices: Array<Float> = []
//    let url = URL(string: "https://api.worldtradingdata.com/api/v1/history?symbol=" + symbol + "&api_token=" + APIKeyWTD)
//    let data = try? Data(contentsOf: url!)
//    let APIResults = try? JSONDecoder().decode(APIResultsStockIntraday.self, from: data!)
//    if APIResults == nil {
//        return []
//    }
//    let mostRecentDays = APIResults!.history.sorted(by: { $0.key > $1.key })
//    for stockResult in mostRecentDays {
//        mostRecentPrices.append(stockResult.value.close)
//        if mostRecentPrices.count == 1095 { break}
//    }
//    return mostRecentPrices
//}

func fetchStockData2Days(symbol: String) -> Array<Float> {
    var mostRecentPrices: Array<Float> = []
    let url = URL(string: "https://api.twelvedata.com/time_series?symbol=" + symbol + "&apikey=" + APIKeyTwelveData + "&interval=1day&outputsize=2")
    let data = try? Data(contentsOf: url!)
    let APIResults = try? JSONDecoder().decode(APIResultsStockHistory.self, from: data!)
    if APIResults == nil {
        return []
    }
    for stockResult in APIResults!.values {
        mostRecentPrices.append(stockResult.close)
    }
    return mostRecentPrices
}

func fetchStockData1Year(symbol: String) -> Array<Float> {
    var mostRecentPrices: Array<Float> = []
    let url = URL(string: "https://api.twelvedata.com/time_series?symbol=" + symbol + "&apikey=" + APIKeyTwelveData + "&interval=1day&outputsize=365")
    let data = try? Data(contentsOf: url!)
    let APIResults = try? JSONDecoder().decode(APIResultsStockHistory.self, from: data!)
    if APIResults == nil {
        return []
    }
    for stockResult in APIResults!.values {
        mostRecentPrices.append(stockResult.close)
    }
    return mostRecentPrices
}

func fetchMACEData1Year(symbol: String) -> (Array<Float>, Array<Float>) {
    var macd: Array<Float> = []
    var macdSignal: Array<Float> = []
    let url = URL(string: "https://api.twelvedata.com/macd?symbol=" + symbol + "&interval=1day&outputsize=365&apikey=" + APIKeyTwelveData)
    let data = try? Data(contentsOf: url!)
    let APIResults = try? JSONDecoder().decode(TechnicalIndicatorMACD.self, from: data!)
    if APIResults == nil {
        return ([], [])
    }
    for indicator in APIResults!.values {
        macd.append(indicator.macd)
        macdSignal.append(indicator.macd_signal)
    }
    return (macd, macdSignal)
}

func fetchMAData1Year(symbol: String) -> Array<Float>{
    var ma: Array<Float> = []
    let url = URL(string: "https://api.twelvedata.com/ma?symbol=" + symbol + "&interval=1day&time_period=5&outputsize=365&apikey=" + APIKeyTwelveData)
    let data = try? Data(contentsOf: url!)
    let APIResults = try? JSONDecoder().decode(TechnicalIndicatorMA.self, from: data!)
    if APIResults == nil {
        return []
    }
    for indicator in APIResults!.values {
        ma.append(indicator.ma)
    }
    return ma
}

func fetchRSIData1Year(symbol: String) -> Array<Float>{
    var rsi: Array<Float> = []
    let url = URL(string: "https://api.twelvedata.com/rsi?symbol=" + symbol + "&interval=1day&time_period=5&outputsize=365&apikey=" + APIKeyTwelveData)
    let data = try? Data(contentsOf: url!)
    let APIResults = try? JSONDecoder().decode(TechnicalIndicatorRSI.self, from: data!)
    if APIResults == nil {
        return []
    }
    for indicator in APIResults!.values {
        rsi.append(indicator.rsi)
    }
    return rsi
}

func fetchEMAData1Year(symbol: String) -> Array<Float>{
    var ema: Array<Float> = []
    let url = URL(string: "https://api.twelvedata.com/ema?symbol=" + symbol + "&interval=1day&time_period=5&outputsize=365&apikey=" + APIKeyTwelveData)
    let data = try? Data(contentsOf: url!)
    let APIResults = try? JSONDecoder().decode(TechnicalIndicatorEMA.self, from: data!)
    if APIResults == nil {
        return []
    }
    for indicator in APIResults!.values {
        ema.append(indicator.ema)
    }
    return ema
}
