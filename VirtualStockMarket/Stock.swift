//
//  Stock.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 2/5/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit

struct StockHistory: Decodable {
    enum CodingKeys: String, CodingKey {
            case datetime = "datetime"
            case open = "open";
            case high = "high";
            case low = "low";
            case close = "close";
            case volume = "volume";
        }
    
    //convert string to float
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let openDecode = try Float(values.decode(String.self, forKey: .open)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.open], debugDescription: "Expecting string representation of Float"))
        }
        guard let highDecode = try Float(values.decode(String.self, forKey: .high)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.high], debugDescription: "Expecting string representation of Float"))
        }
        guard let lowDecode = try Float(values.decode(String.self, forKey: .low)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.low], debugDescription: "Expecting string representation of Float"))
        }
        guard let closeDecode = try Float(values.decode(String.self, forKey: .close)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.close], debugDescription: "Expecting string representation of Float"))
        }
        guard let volumeDecode = try Float(values.decode(String.self, forKey: .volume)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.volume], debugDescription: "Expecting string representation of Float"))
        }
        datetime = try String(values.decode(String.self, forKey: .datetime))
        open = openDecode
        high = highDecode
        low = lowDecode
        close = closeDecode
        volume = volumeDecode
    }
    
    let datetime: String!
    let open: Float!
    let high: Float!
    let low: Float!
    let close: Float!
    let volume: Float!
}

struct StockInfo: Decodable {
    enum CodingKeys: String, CodingKey {
            case name = "name"
        }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try String(values.decode(String.self, forKey: .name))
    }
    
    let name: String!
}
