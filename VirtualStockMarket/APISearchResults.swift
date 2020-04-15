//
//  APISearchResults.swift
//  VirtualStockMarket
//
//  Created by Minh Do on 2/13/20.
//  Copyright © 2020 Group13_439. All rights reserved.
//

import UIKit

struct APISearchResults: Decodable {
    let bestMatches: Array<Search>;
}

