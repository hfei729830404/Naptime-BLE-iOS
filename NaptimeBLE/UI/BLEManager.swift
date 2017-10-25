//
//  BLEManager.swift
//  NaptimeBLE
//
//  Created by NyanCat on 25/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth

extension DispatchQueue {
    static let ble: DispatchQueue = DispatchQueue(label: "cn.entertech.naptimeBLE.BLE")
}

class BLEManager: NSObject, CBCentralManagerDelegate {

    static let shared = BLEManager()

    private(set) var manager: CBCentralManager!

    private override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: .ble)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        //
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //
    }
}
