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
        for (i, byte) in bytes.enumerated() {
            if self[self.count - bytes.count + i] != byte {
                return false
            }
        }
        return true
    }
}
