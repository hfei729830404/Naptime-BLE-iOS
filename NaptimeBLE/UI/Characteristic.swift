//
//  Characteristic.swift
//  NaptimeBLE
//
//  Created by NyanCat on 27/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol UUIDType {
    var uuid: String { get }
}
protocol Displayable {
    var displayName: String { get }
}

extension CBUUID {

    var uuid: UUIDType? {
        if let service = ServiceType(rawValue: self.uuidString) {
            return service
        } else if let characteristic = CharacteristicType(rawValue: self.uuidString) {
            return characteristic
        }
        return nil
    }
    var isService: Bool {
        return self.uuid is ServiceType
    }
    var isCharacteristic: Bool {
        return self.uuid is CharacteristicType
    }

    var whichService: ServiceType? {
        return self.uuid as? ServiceType
    }

    var whichCharacteristic: CharacteristicType? {
        return self.uuid as? CharacteristicType
    }
}

enum ServiceType: String, UUIDType {
    case genericAccess = "1800"
    case genericAttribute  = "1801"
    case command  = "00000000-1212-EFDE-1523-785FEABCD123"
    case battery  = "180F"
    case eeg  = "00000011-1212-EFDE-1523-785FEABCD123"
    case eeg_1  = "0000FFE0-1212-EFDE-1523-785FEABCD123"
    case dfu = "00001530-1212-EFDE-1523-785FEABCD123"
    case deviceInfo = "180A"

    var uuid: String {
        return self.rawValue
    }
}

extension ServiceType: Displayable {
    var displayName: String {
        switch self {
        case .genericAccess:
            return "基础信息服务"
        case .genericAttribute:
            return "Generic Attribute 服务"
        case .command:
            return "指令传输服务"
        case .battery:
            return "电量服务"
        case .eeg, .eeg_1:
            return "脑电服务"
        case .dfu:
            return "DFU 服务"
        case .deviceInfo:
            return "设备信息服务"
        }
    }
}

enum CharacteristicType: String, UUIDType {
    case gap_deviceName = "00002A00-0000-1000-8000-00805F9B34FB"
    case gap_appearance = "00002A01-0000-1000-8000-00805F9B34FB"
    case gap_ppcp = "00002A04-0000-1000-8000-00805F9B34FB"
    case gatt_serviceChanged = "00002A05-0000-1000-8000-00805F9B34FB"
    case cccd = "00002902-0000-1000-8000-00805F9B34FB"
    case cmd_upload = "00000001-1212-EFDE-1523-785FEABCD123"
    case cmd_download = "00000002-1212-EFDE-1523-785FEABCD123"
    case battery_level = "2A19"
    case eeg_data = "00000012-1212-EFDE-1523-785FEABCD123"
    case eeg_data_1 = "0000FFE1-1212-EFDE-1523-785FEABCD123"
    case dfu_ctrl = "00001531-1212-EFDE-1523-785FEABCD123"
    case dfu_package = "00001532-1212-EFDE-1523-785FEABCD123"
    case device_serial = "2A25"
    case device_firmware_revision = "2A26"
    case device_hardware_revision = "2A27"
    case device_manufacturer = "2A29"

    var uuid: String {
        return self.rawValue
    }
}

extension CharacteristicType: Displayable {
    var displayName: String {
        switch self {
        case .gap_deviceName:
            return "设备名称"
        case .gap_appearance:
            return "设备类型"
        case .gap_ppcp:
            return "连接参数"
        case .gatt_serviceChanged:
            return "Service change"
        case .cccd:
            return "CCCD"
        case .cmd_upload:
            return "指令上行"
        case .cmd_download:
            return "指令下行"
        case .battery_level:
            return "电池电量"
        case .eeg_data, .eeg_data_1:
            return "脑电数据"
        case .dfu_ctrl:
            return "DFU 控制指令"
        case .dfu_package:
            return "DFU 数据包"
        case .device_serial:
            return "序列号"
        case .device_firmware_revision:
            return "固件版本"
        case .device_hardware_revision:
            return "硬件版本"
        case .device_manufacturer:
            return "制造商"
        }
    }
}
