//
//  Extension.swift
//  NaptimeBLE
//
//  Created by NyanCat on 27/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

extension Data {
    var hexString: String {
        return self.enumerated().map({ (offset, element) -> String in
            String(format: "0x%02X ", element)
        }).joined()
    }
}
