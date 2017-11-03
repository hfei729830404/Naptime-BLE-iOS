//
//  DeviceInfoService.swift
//  NaptimeBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public class DeviceInfoService: Service {
    public typealias ST = DeviceInfoService
}

extension DeviceInfoService: Readable {

    public typealias ReadType = Characteristic.DeviceInfo

}
