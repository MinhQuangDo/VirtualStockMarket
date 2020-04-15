//
//  Search.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 2/13/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit

struct Search: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol";
        case name = "2. name";
    }
    
    let symbol: String!
    let name: String!
}
