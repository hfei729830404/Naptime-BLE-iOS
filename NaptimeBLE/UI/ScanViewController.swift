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

struct PeripheralItem {
    let peripheral: CBPeripheral
    var rssi: NSNumber
    var mac: String?
}

class ScanViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    private let deviceCellIdentifier = "deviceCellIdentifier"

    var deviceList: [PeripheralItem] = []
    var manager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 88.0
        tableView.rowHeight = UITableViewAutomaticDimension

        manager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .default))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        manager.stopScan()
    }

    @IBAction func closeButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Delegates

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: deviceCellIdentifier, for: indexPath)
        let item = deviceList[indexPath.row]
        cell.textLabel?.text = item.peripheral.showName
        cell.detailTextLabel?.text = item.rssi.stringValue
        cell.imageView?.image = (item.peripheral.state == .connected ? #imageLiteral(resourceName: "icon_bluetooth") : #imageLiteral(resourceName: "icon_bluetooth_disconnect"))
        cell.imageView?.highlightedImage = cell.imageView?.image
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = deviceList[indexPath.row]
        switch item.peripheral.state {
        case .connected:
            manager.cancelPeripheralConnection(item.peripheral)
        case .disconnected:
            SVProgressHUD.show(withStatus: "正在连接: \(item.peripheral.showName)")
            manager.connect(item.peripheral, options: nil)
        default:
            break
        }
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
        default:
            break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if deviceList.contains(where: { $0.peripheral.identifier == peripheral.identifier }) {
            return
        }
        let item = PeripheralItem(peripheral: peripheral, rssi: RSSI, mac: nil)

        dispatch_to_main {
            self.deviceList.append(item)
            let indexPath = IndexPath(row: self.deviceList.count-1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .bottom)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        SVProgressHUD.showSuccess(withStatus: "连接成功: \(peripheral.showName)")

        updatePeripheralIfNeeded(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        SVProgressHUD.showError(withStatus: "连接失败: \(peripheral.showName)")

        updatePeripheralIfNeeded(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        SVProgressHUD.showInfo(withStatus: "已断开连接: \(peripheral.showName)")

        updatePeripheralIfNeeded(peripheral)
    }

    private func updatePeripheralIfNeeded(_ peripheral: CBPeripheral) {
        if let index = self.deviceList.index(where: {$0.peripheral.identifier == peripheral.identifier }) {
            let indexPath = IndexPath(row: index, section: 0)
            dispatch_to_main {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

extension CBPeripheral {
    var showName: String {
        return self.name ?? "NULL"
    }
}
