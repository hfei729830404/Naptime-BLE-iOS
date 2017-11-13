//
//  Extension.swift
//  NaptimeBLE
//
//  Created by NyanCat on 27/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import RxBluetoothKit
import NaptimeBLE

extension Data {
    var hexString: String {
        return self.enumerated().map({ (offset, element) -> String in
            String(format: "0x%02X ", element)
        }).joined()
    }
}

protocol Displayable {
    var displayName: String { get }
}

extension Peripheral: Displayable {
    var displayName: String {
        return self.name ?? "Null"
    }
}

extension BLEService: Displayable {
    var displayName: String {
        if let type = (self as? ServiceTypable)?.serviceType {
            switch type {
            case .connect:
                return "连接服务"
            case .command:
                return "指令服务"
            case .battery:
                return "电量服务"
            case .eeg:
                return "脑电服务"
            case .dfu:
                return "DFU服务"
            case .deviceInfo:
                return "设备信息服务"
            }
        }
        return "Unknown"
    }
}

extension BLEService: UUIDType {
    public var uuid: String {
        if let type = (self as? ServiceTypable)?.serviceType {
            return type.rawValue
        }
        return "Unknown"
    }
}

//extension NaptimeBLE.Characteristic.DeviceInfo: Displayable {
//    var displayName: String {
//        switch self {
//        case .mac:
//            return "MAC 地址"
//        case .serial:
//            return "序列号"
//        case .firmwareRevision:
//            return "固件版本"
//        case .hardwareRevision:
//            return "硬件版本"
//        case .manufacturer:
//            return "制造商"
//        }
//    }
//}

//extension NaptimeBLE.Characteristic.Battery: Displayable {
//    var displayName: String {
//        switch self {
//        case .battery:
//            return "电池电量"
//        }
//    }
//}

extension RxBluetoothKit.Characteristic: Displayable {
    var displayName: String {
        switch self.uuid.uuidString {
        case NaptimeBLE.Characteristic.DeviceInfo.mac.rawValue:
            return "MAC 地址"
        case NaptimeBLE.Characteristic.DeviceInfo.serial.rawValue:
            return "序列号"
        case NaptimeBLE.Characteristic.DeviceInfo.firmwareRevision.rawValue:
            return "固件版本"
        case NaptimeBLE.Characteristic.DeviceInfo.hardwareRevision.rawValue:
            return "硬件版本"
        case NaptimeBLE.Characteristic.DeviceInfo.manufacturer.rawValue:
            return "制造商"
        case NaptimeBLE.Characteristic.Battery.battery.rawValue:
            return "电池电量"
        default:
            return "Any"
        }
    }
}
