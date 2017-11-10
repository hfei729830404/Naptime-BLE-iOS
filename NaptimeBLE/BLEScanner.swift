//
//  BLEScanner.swift
//  NaptimeBLE
//
//  Created by HyanCat on 01/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxBluetoothKit
import RxSwift
import PromiseKit

extension DispatchQueue {
    static let ble: DispatchQueue = DispatchQueue(label: "cn.entertech.naptimeBLE.BLE")
}

public final class BLEScanner {

    public static let shared = BLEScanner()

    var manager: BluetoothManager
    private let _disposeBag = DisposeBag()

    private var _observer: Observable<Peripheral>?
    private var _disposable: Disposable?

    private var _usingPeripheral: Peripheral?

    private init() {
        manager = BluetoothManager(queue: .ble, options: nil)
    }

    public func scan() -> Observable<Peripheral> {
        let observable: Observable<Peripheral> = Observable.create { [unowned self] (observer) -> Disposable in
            let disposable = self.manager.scanForPeripherals(withServices: [CBUUID(string: UUID_BLE_DEVICE)])
                .flatMap {
                    Observable.just($0.peripheral)
                }
                .subscribe(onNext: {
                    observer.onNext($0)
                }, onError: {
                    observer.onError($0)
                }, onCompleted: {
                    observer.onCompleted()
                })
            self._disposable = disposable
            disposable.disposed(by: self._disposeBag)
            return disposable
        }
        return observable
    }

    public func stop() {
        _disposable?.dispose()
    }

    public func use(peripheral: Peripheral) {
        _usingPeripheral = peripheral
    }
}
