//
//  BatteryService.swift
//  NaptimeBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public class BatteryService: Service {
    public typealias ST = BatteryService
}

extension BatteryService: Readable, Notifiable {

    public typealias ReadType = Characteristic.Battery

    public typealias NotifyType = Characteristic.Battery
}
