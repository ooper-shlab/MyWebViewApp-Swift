//
//  NSData+suffix.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/21.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved.
//

import Foundation

extension NSData {
    func hasSuffix(bytes: UInt8...) -> Bool {
        if self.length < bytes.count { return false }
        let ptr = UnsafePointer<UInt8>(self.bytes)
        for (i, byte) in bytes.enumerate() {
            if ptr[self.length - bytes.count + i] != byte {
                return false
            }
        }
        return true
    }
}
