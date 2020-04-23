//
//  APIResultsStockDaily.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 2/5/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit

struct APIResultsStockHistory: Decodable {
    let values: [StockHistory]
}

struct APIResultsStockInfo: Decodable {
    let data: [StockInfo]
}

