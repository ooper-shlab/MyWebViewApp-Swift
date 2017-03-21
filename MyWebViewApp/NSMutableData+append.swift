//
//  NSMutableData+append.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/21.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

extension Data {
    mutating func append(_ string: String) {
        self.append(string.data(using: .utf8)!)
    }
}
