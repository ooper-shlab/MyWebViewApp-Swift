//
//  String+HTML.swift
//  MyWebViewApp
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/22.
//  Copyright © 2015 OOPer (NAGATA, Atsuyuki). All rights reserved. See LICENSE.txt .
//

import Foundation

extension String {
    var HTMLEntitiesEncoded: String {
        struct My {
            static let dict = ["<":"&lt;", ">":"&gt;", "\"":"&quot;", "'":"&apos;", "&":"&amp;"]
            static let pattern = try! OOPRegularExpression(pattern: "[<>\"'&]", options: []) {
                string, _ in
                return dict[string]!
            }
        }
        return My.pattern.stringByReplacingMatchesInString(self)
    }
}