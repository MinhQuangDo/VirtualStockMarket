////
////  StockRealTime.swift
////  VirtualStockMarket
////
////  Created by Minh Do on 2/22/20.
////  Copyright © 2020 Group13_439. All rights reserved.
////
//
//struct StockRealTime: Decodable {
//    enum CodingKeys: String, CodingKey {
//        case dayHigh = "day_high";
//        case dayLow = "day_low";
//        case yearHigh = "52_week_high";
//        case yearLow = "52_week_low";
//        case volume = "volume";
//        case volumeAvg = "volume_avg";
//        case company = "name";
//    }
//    
//    //convert string to float
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        guard let dayHighDecode = try Float(values.decode(String.self, forKey: .dayHigh)) else {
//            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.dayHigh], debugDescription: "Expecting string representation of Float"))
//        }
//        guard let dayLowDecode = try Float(values.decode(String.self, forKey: .dayLow)) else {
//            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.dayLow], debugDescription: "Expecting string representation of Float"))
//        }
//        guard let yearHighDecode = try Float(values.decode(String.self, forKey: .yearHigh)) else {
//            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.yearHigh], debugDescription: "Expecting string representation of Float"))
//        }
//        guard let yearLowDecode = try Float(values.decode(String.self, forKey: .yearLow)) else {
//            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.yearLow], debugDescription: "Expecting string representation of Float"))
//        }
//        guard let volumeDecode = try Float(values.decode(String.self, forKey: .volume)) else {
//            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.volume], debugDescription: "Expecting string representation of Int"))
//        }
//        
//        guard let volumeAvgDecode = try Float(values.decode(String.self, forKey: .volumeAvg)) else {
//        throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.volumeAvg], debugDescription: "Expecting string representation of Int"))
//        }
//        
//        dayHigh = dayHighDecode
//        dayLow = dayLowDecode
//        yearHigh = yearHighDecode
//        yearLow = yearLowDecode
//        volume = volumeDecode
//        volumeAvg = volumeAvgDecode
//        company = try String(values.decode(String.self, forKey: .company))
//    }
//    
//    let dayHigh: Float!
//    let dayLow: Float!
//    let yearHigh: Float!
//    let yearLow: Float!
//    let volume: Float!
//    let volumeAvg: Float!
//    let company: String!
//}
