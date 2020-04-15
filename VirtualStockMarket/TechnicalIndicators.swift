//
//  TechnicalIndicators.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 4/12/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit

struct TechnicalIndicatorMACD: Decodable {
    let values: [MACD];
}

struct MACD: Decodable {
    enum CodingKeys: String, CodingKey {
        case macd = "macd";
        case macd_signal = "macd_signal";
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let macdDecode = try Float(values.decode(String.self, forKey: .macd)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.macd], debugDescription: "Expecting string representation of Float"))
        }
        guard let macdSignalDecode = try Float(values.decode(String.self, forKey: .macd_signal)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.macd_signal], debugDescription: "Expecting string representation of Float"))
        }

        macd = macdDecode
        macd_signal = macdSignalDecode
    }

    let macd: Float!
    let macd_signal: Float!
}

struct TechnicalIndicatorMA: Decodable {
    let values: [MA];
}

struct MA: Decodable {
    enum CodingKeys: String, CodingKey {
        case ma = "ma";
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let maDecode = try Float(values.decode(String.self, forKey: .ma)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.ma], debugDescription: "Expecting string representation of Float"))
        }
        ma = maDecode
    }

    let ma: Float!
}

struct TechnicalIndicatorRSI: Decodable {
    let values: [RSI];
}

struct RSI: Decodable {
    enum CodingKeys: String, CodingKey {
        case rsi = "rsi";
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let rsiDecode = try Float(values.decode(String.self, forKey: .rsi)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.rsi], debugDescription: "Expecting string representation of Float"))
        }
        rsi = rsiDecode
    }

    let rsi: Float!
}

struct TechnicalIndicatorEMA: Decodable {
    let values: [EMA];
}

struct EMA: Decodable {
    enum CodingKeys: String, CodingKey {
        case ema = "ema";
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let emaDecode = try Float(values.decode(String.self, forKey: .ema)) else {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.ema], debugDescription: "Expecting string representation of Float"))
        }
        ema = emaDecode
    }

    let ema: Float!
}


