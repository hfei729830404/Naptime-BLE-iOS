//
//  Service.swift
//  NaptimeBLE
//
//  Created by HyanCat on 01/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import RxSwift
import RxBluetoothKit

// MARK: - 基础协议

public protocol Service {
    associatedtype ST

//    var service: RxBluetoothKit.Service { get set }
}

// MARK: - 能力协议

public protocol Readable: Service {
    associatedtype ReadType: CharacteristicReadType
    func read(characteristic: ReadType)
}

public protocol Writable: Service {
    associatedtype WriteType: CharacteristicWriteType
    func write(data: Data, to characteristic: WriteType)
}

public protocol Notifiable: Service {
    associatedtype NotifyType: CharacteristicNotifyType
    func notify(characteristic: NotifyType)
}

// MARK: - 性状

public extension Readable {
    public func read(characteristic: ReadType) {
        //
    }
}

public extension Writable {
    public func write(data: Data, to characteristic: WriteType) {
        //
    }
}

public extension Notifiable {
    public func notify(characteristic: NotifyType) {
        //
    }
}

/**
public extension Service where ST == ABCService {
    //
}
 */

//enum ServiceType {
//    case genericAccess
//    case genericAttribute
//    case command
//    case battery
//    case eeg
//    case dfu
//    case deviceInfo
//}
