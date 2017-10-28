//
//  ScanViewController.swift
//  NaptimeBLE
//
//  Created by NyanCat on 25/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import CoreBluetooth
import SVProgressHUD
import RxBluetoothKit
import RxSwift

extension DispatchQueue {
    static let ble: DispatchQueue = DispatchQueue(label: "cn.entertech.naptimeBLE.BLE")
}

class ScanViewController: UITableViewController {

    let disposeBag: DisposeBag = DisposeBag()

    let manager: BluetoothManager = BluetoothManager(queue: .ble)
    var isScanning: Bool = false

    var peripheralList: [ScannedPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        stopScan()
    }

    @IBAction func scanButtonTouched(_ sender: UIBarButtonItem) {
        if isScanning {
            stopScan()
        } else {
            startScan()
        }
        isScanning = !isScanning
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pushToService" {
            let vc = segue.destination as! PeripheralViewController
            vc.peripheral = _selectedPeripheral
        }
    }

    // MARK: - Delegates

    // MARK: TableView Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCellIdentifier", for: indexPath)
        let item = peripheralList[indexPath.row]
        cell.textLabel?.text = item.peripheral.cbPeripheral.showName
        cell.detailTextLabel?.text = item.rssi.stringValue
        cell.imageView?.image = (item.peripheral.state == .connected ? #imageLiteral(resourceName: "icon_bluetooth") : #imageLiteral(resourceName: "icon_bluetooth_disconnect"))
        cell.imageView?.highlightedImage = cell.imageView?.image
        return cell
    }

    private var _selectedPeripheral: Peripheral?

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        _selectedPeripheral = peripheralList[indexPath.row].peripheral
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func updatePeripheralIfNeeded(_ peripheral: CBPeripheral) {
        if let index = self.peripheralList.index(where: {$0.peripheral.identifier == peripheral.identifier }) {
            let indexPath = IndexPath(row: index, section: 0)
            dispatch_to_main {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }

    private func startScan() {
        clear()
        self.navigationItem.rightBarButtonItem?.title = "停止"
        manager.scanForPeripherals(withServices: nil).filter {
            // 只显示有 name 的
            $0.peripheral.name != nil
        }.subscribe (onNext: { [weak self] (peripheral) in
            guard let `self` = self else { return }

            dispatch_to_main {
                self.peripheralList.append(peripheral)
                let indexPath = IndexPath(row: self.peripheralList.count-1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .bottom)
            }
        }).disposed(by: disposeBag)
    }

    private func stopScan() {
        let timerScheduler = MainScheduler()
        _ = manager.scanForPeripherals(withServices: nil).timeout(0.5, scheduler: timerScheduler)
        self.navigationItem.rightBarButtonItem?.title = "扫描"
    }

    private func clear() {
        self.peripheralList = []
        self.tableView.reloadData()
    }

    private func disconnect(peripheral: Peripheral, at indexPath: IndexPath) {
        peripheral.cancelConnection().subscribe { [weak self] in
            guard let `self` = self else { return }

            dispatch_to_main {
                SVProgressHUD.showSuccess(withStatus: "连接断开:\n \(peripheral.cbPeripheral.showName)")
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            }.disposed(by: disposeBag)
    }
}

extension CBPeripheral {
    var showName: String {
        return self.name ?? "NULL"
    }
}
