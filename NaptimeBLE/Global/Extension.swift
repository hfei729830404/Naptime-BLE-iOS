//
//  Extension.swift
//  NaptimeBLE
//
//  Created by NyanCat on 27/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import RxBluetoothKit

extension Data {
    var hexString: String {
        return self.enumerated().map({ (offset, element) -> String in
            String(format: "0x%02X ", element)
        }).joined()
    }
}

extension Service: Displayable {
    var displayName: String {
        return (self.uuid.uuid as? ServiceType)?.displayName ?? "Unknown"
    }
}

extension Characteristic: Displayable {
    var displayName: String {
        return (self.uuid.uuid as? CharacteristicType)?.displayName ?? "Unknown"
    }
}
