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
        cell.textLabel?.text = characteristic?.uuid.description
        cell.detailTextLabel?.text = characteristic?.uuid.uuidString
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: _serviceHeaderReuseIdentifier) as! ServiceHeaderView
        let service = services[section]
        header.title = service.showName
        header.detail = service.uuid.uuidString
        return header
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let service = self.services[indexPath.section]
        let characteristic = self.characteristics[service.uuid]?[indexPath.row]

        characteristic?.readValue().subscribe(onNext: {
            if let data = $0.value {
                dispatch_to_main {
                    let cell = tableView.cellForRow(at: indexPath)
                    var bytes = [UInt8](repeating: 0, count: data.count)
                    data.copyBytes(to: &bytes, count: data.count)
                    cell?.detailTextLabel?.text = String(format: "%d", bytes[0])
                }
            }
        }).disposed(by: disposeBag)
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
}

extension Service {
    var showName: String {
        let map = [
            "1800": "基础信息服务",
            "1801": "Generic Attribute 服务",
            "00000000-1212-EFDE-1523-785FEABCD123": "指令传输服务",
            "180F": "电量服务",
            "00000011-1212-EFDE-1523-785FEABCD123": "脑电服务",
            "00001530-1212-EFDE-1523-785FEABCD123": "DFU 服务",
            "180A": "设备信息服务",
            ]
        if let name = map[self.uuid.uuidString] {
            return name
        }
        return self.uuid.description
    }
}
