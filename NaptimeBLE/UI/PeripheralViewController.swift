//
//  PeripheralViewController.swift
//  NaptimeBLE
//
//  Created by NyanCat on 26/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxBluetoothKit
import RxSwift
import SVProgressHUD

class PeripheralViewController: UITableViewController {

    var peripheral: Peripheral!
    var services: [Service] = []
    var characteristics: [CBUUID: [Characteristic]] = [:]

    var disposeBag: DisposeBag = DisposeBag()

    private let _serviceHeaderReuseIdentifier = "_serviceHeaderReuseIdentifier"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设备 " + peripheral.cbPeripheral.showName

        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ServiceHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: _serviceHeaderReuseIdentifier)
        tableView.separatorInset = UIEdgeInsetsMake(0, 32, 0, 0)

        loadServices()
    }

    private func loadServices() {
        peripheral.discoverServices(nil)
            .flatMap { Observable.from($0) }
            .subscribe(onNext: { [weak self] service in
                guard let `self` = self else { return }
                self.services.append(service)
                self.characteristics[service.uuid] = []
            }, onCompleted: { [weak self] in
                guard let `self` = self else { return }
                dispatch_to_main {
                    self.tableView.reloadData()
                    self.scanCharacteristic()
                }
            })
            .disposed(by: disposeBag)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let service = services[section]
        if let characteristics = characteristics[service.uuid] {
            return characteristics.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCellIdentifier", for: indexPath)
        let service = self.services[indexPath.section]
        let characteristic = self.characteristics[service.uuid]?[indexPath.row]
        cell.textLabel?.text = characteristic?.displayName
        cell.detailTextLabel?.text = characteristic?.showValue
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UINib(nibName: "ServiceHeaderView", bundle: nil).instantiate(withOwner: self, options: nil).first as! ServiceHeaderView
        let service = services[section]
        header.title = service.displayName
        header.detail = service.uuid.uuidString
        return header
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let service = self.services[indexPath.section]
        if let characteristic = self.characteristics[service.uuid]?[indexPath.row] {
            handle(characteristic: characteristic, at: indexPath)
        }
    }

    private func scanCharacteristic() {
        self.services.forEach { service in
            service.discoverCharacteristics(nil)
                .flatMap { Observable.from($0) }
                .subscribe(onNext: { [weak self] characteristic in
                    guard let `self` = self else { return }
                    self.characteristics[service.uuid]?.append(characteristic)
                    }, onCompleted: { [weak self] in
                        guard let `self` = self else { return }
                        dispatch_to_main {
                            if let index = self.services.index(of: service) {
                                let indexSet = IndexSet(integer: index)
                                self.tableView.reloadSections(indexSet, with: .automatic)
                            }
                        }
                })
                .disposed(by: disposeBag)
        }
    }

    private func handle(characteristic: Characteristic, at indexPath: IndexPath) {
        guard let characteristicType = characteristic.uuid.whichCharacteristic else { return }
        let cell = tableView.cellForRow(at: indexPath)
        switch characteristicType {
        case .device_serial,
             .device_firmware_revision,
             .device_hardware_revision,
             .device_manufacturer:
            characteristic.readValue().subscribe(onNext: {
                if let data = $0.value {
                    dispatch_to_main {
                        cell?.detailTextLabel?.text = String(data: data, encoding: .utf8)
                    }
                }
            }).disposed(by: disposeBag)
        case .cmd_upload, .cmd_download:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "CommandViewController") as? CommandViewController {
                vc.service = services[indexPath.section]
                navigationController?.show(vc, sender: self)
            }
        case .battery_level:
            characteristic.readValue().subscribe(onNext: {
                if let data = $0.value {
                    dispatch_to_main {
                        var bytes = [UInt8](repeating: 0, count: data.count)
                        data.copyBytes(to: &bytes, count: data.count)
                        cell?.detailTextLabel?.text = String(format: "%d%%", bytes[0])
                    }
                }
            }).disposed(by: disposeBag)
            break
        case .eeg_data:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "EEGViewController") as? EEGViewController {
                vc.service = services[indexPath.section]
                navigationController?.show(vc, sender: self)
            }
            break
        default:
            break
        }
    }
}

extension Service: Displayable {
    var displayName: String {
        return (self.uuid.uuid as! ServiceType).displayName
    }
}

extension Characteristic: Displayable {
    var displayName: String {
        return (self.uuid.uuid as! CharacteristicType).displayName
    }
}

extension Characteristic {
    var showValue: String {
        if let value = self.value {
            if self.uuid.whichCharacteristic == CharacteristicType.battery_level {
                var bytes = [UInt8](repeating: 0, count: value.count)
                value.copyBytes(to: &bytes, count: value.count)
                return String(format: "%d%%", bytes[0])
            }
            if let str = String(data: value, encoding: .utf8) {
                return str
            }
        }
        return self.uuid.uuidString
    }
}
