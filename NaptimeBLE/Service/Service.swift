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
import PromiseKit
import CoreBluetooth

// MARK: - 基础协议

public typealias Bytes = [UInt8]

public protocol Service {
    init(rxService: RxBluetoothKit.Service)
}

public class BLEService: Service {

    let rxService: RxBluetoothKit.Service

    public required init(rxService: RxBluetoothKit.Service) {
        self.rxService = rxService
    }
}

// MARK: - 能力协议

public protocol Readable: Service {
    associatedtype ReadType: CharacteristicReadType
    func read(characteristic: ReadType) -> Promise<Data>
}

public protocol Writable: Service {
    associatedtype WriteType: CharacteristicWriteType
    func write(data: Data, to characteristic: WriteType) -> Promise<Void>
}

public protocol Notifiable: Service {
    associatedtype NotifyType: CharacteristicNotifyType
    func notify(characteristic: NotifyType) -> Observable<Bytes>
}

// MARK: - 性状

public extension Readable where Self: BLEService {
    public func read(characteristic: ReadType) -> Promise<Data> {
        let promise = Promise<Data> { (fulfill, reject) in
            _ = self.rxService.characteristics?.first(where: { $0.uuid == characteristic.uuid })?.readValue().subscribe(onNext: {
                if let data = $0.value {
                    fulfill(data)
                }
            }, onError: { error in
                reject(error)
            })
        }
        return promise
    }
}

public extension Writable where Self: BLEService {
    public func write(data: Data, to characteristic: WriteType) -> Promise<Void> {
        let promise = Promise<Void> { (fulfill, reject) in
            _ = self.rxService.characteristics?.first(where: { $0.uuid == characteristic.uuid })?
                .writeValue(data, type: .withResponse)
                .subscribe(onNext: nil, onError: { error in
                    reject(error)
                }, onCompleted: {
                    fulfill(())
                }, onDisposed: nil)
        }
        return promise
    }
}

public extension Notifiable where Self: BLEService {
    public func notify(characteristic: NotifyType) -> Observable<Bytes> {
        if let char =
            self.rxService.characteristics?.first(where: { $0.uuid == characteristic.uuid }) {
            return char.setNotificationAndMonitorUpdates().map {
                $0.value!.copiedBytes
            }
        }
        return Observable.error(BluetoothError.characteristicsDiscoveryFailed(self.rxService, nil))
    }
}

extension Data {
    var copiedBytes: [UInt8] {
        var bytes = [UInt8](repeating: 0, count: self.count)
        self.copyBytes(to: &bytes, count: self.count)
        return bytes
    }
}

enum ServiceType: String {
    case command = "00000000-1212-EFDE-1523-785FEABCD123"
    case battery = "180F"
//    case eeg = "00000011-1212-EFDE-1523-785FEABCD123"
    case eeg = "0000FFE0-1212-EFDE-1523-785FEABCD123"
    case dfu = "00001530-1212-EFDE-1523-785FEABCD123"
    case deviceInfo = "180A"
}
