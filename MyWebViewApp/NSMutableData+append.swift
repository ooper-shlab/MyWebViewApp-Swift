//
//  NSMutableData+append.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/21.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

extension NSMutableData {
    func append(string: String) {
        let len = string.utf8.count
        self.appendBytes(string, length: len)
    }
}