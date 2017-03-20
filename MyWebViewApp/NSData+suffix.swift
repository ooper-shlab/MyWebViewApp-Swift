//
//  NSData+suffix.swift
//  OOPUtils
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/21.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

extension Data {
    func hasSuffix(_ bytes: UInt8...) -> Bool {
        if self.count < bytes.count { return false }
        let ptr = (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count)
        for (i, byte) in bytes.enumerated() {
            if ptr[self.count - bytes.count + i] != byte {
                return false
            }
        }
        return true
    }
}
