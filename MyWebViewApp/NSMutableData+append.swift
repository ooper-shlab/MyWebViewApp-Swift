//
//  NSMutableData+append.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/21.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

extension NSMutableData {
    func append(_ string: String) {
        let len = string.utf8.count
        self.append(string, length: len)
    }
}
