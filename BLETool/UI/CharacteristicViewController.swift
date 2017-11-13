//
//  CharacteristicViewController.swift
//  NaptimeBLE
//
//  Created by NyanCat on 28/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxBluetoothKit
import RxSwift
import SVProgressHUD
import NaptimeBLE

class CharacteristicViewController: UITableViewController {

    var service: BLEService!

    private var _characteristics: [RxBluetoothKit.Characteristic] = []

    let disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        _characteristics = service.rxService.characteristics ?? []
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _characteristics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characteristicCellIdentifier", for: indexPath)
        let characteristic = _characteristics[indexPath.row]
        cell.textLabel?.text = characteristic.displayName
        cell.detailTextLabel?.text = characteristic.uuid.uuidString
        return cell
    }

    var _selectedCharacteristic: RxBluetoothKit.Characteristic?

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        _selectedCharacteristic = _characteristics[indexPath.row]
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

//        let cell = tableView.cellForRow(at: indexPath)
//        let characteristic = _characteristics[indexPath.row]

//        guard let type = characteristic.uuid.whichCharacteristic else { return }
//        switch type {
//        case .device_serial,
//             .device_firmware_revision,
//             .device_hardware_revision,
//             .device_manufacturer:
//            characteristic.readValue().subscribe(onNext: {
//                if let data = $0.value {
//                    dispatch_to_main {
//                        cell?.detailTextLabel?.text = String(data: data, encoding: .utf8)
//                    }
//                }
//            }).disposed(by: disposeBag)
//        case .battery_level:
//            characteristic.readValue().subscribe(onNext: {
//                if let data = $0.value {
//                    dispatch_to_main {
//                        var bytes = [UInt8](repeating: 0, count: data.count)
//                        data.copyBytes(to: &bytes, count: data.count)
//                        cell?.detailTextLabel?.text = String(format: "%d%%", bytes[0])
//                    }
//                }
//            }).disposed(by: disposeBag)
//        case .cmd_upload, .cmd_download:
//            self.performSegue(withIdentifier: "pushToCommand", sender: self)
//        case .eeg_data, .eeg_data_1:
//            self.performSegue(withIdentifier: "pushToEEG", sender: self)
//        default:
//            break
//        }
    }
}

extension RxBluetoothKit.Characteristic {
    var showValue: String {
//        if let value = self.value {
//            if self.uuid.whichCharacteristic == CharacteristicType.battery_level {
//                var bytes = [UInt8](repeating: 0, count: value.count)
//                value.copyBytes(to: &bytes, count: value.count)
//                return String(format: "%d%%", bytes[0])
//            }
//            if let str = String(data: value, encoding: .utf8) {
//                return str
//            }
//        }
        return self.uuid.uuidString
    }
}
