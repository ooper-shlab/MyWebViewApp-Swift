//
//  aaa.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/24.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

@objc(__$aaa$bbb)
class bbb: NSObject {
    func ccc(request: WebServerRequest) {
        request.transmitter.addResponse(__FUNCTION__+" method called")
        request.transmitter.startTransmission()
    }
}
