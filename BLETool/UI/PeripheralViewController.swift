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
import NaptimeBLE
import PromiseKit

class PeripheralViewController: UITableViewController {

    var peripheral: Peripheral!
    var services: [RxBluetoothKit.Service] = []
    var characteristics: [CBUUID: [RxBluetoothKit.Characteristic]] = [:]

    let disposeBag: DisposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    var connector: Connector!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设备 " + peripheral.displayName

        tableView.tableFooterView = UIView()

        SVProgressHUD.show(withStatus: "正在连接:\n \(peripheral.displayName)")

        connector = Connector(peripheral: peripheral)
        connector.tryConnect { (succeeded) in
            if succeeded {
                SVProgressHUD.show(withStatus: "连接成功\n开始握手")

                self.connector.handshake().then {
                    SVProgressHUD.showSuccess(withStatus: "握手成功")
                }.catch { error in
                    SVProgressHUD.showError(withStatus: "握手失败")
                }
            } else {
                SVProgressHUD.showError(withStatus: "连接失败")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCellIdentifier", for: indexPath)
        let service = self.services[indexPath.row]
        cell.textLabel?.text = service.displayName
        cell.detailTextLabel?.text = service.uuid.uuidString
        return cell
    }

    private var _selectedService: RxBluetoothKit.Service?

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        _selectedService = self.services[indexPath.row]
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! CharacteristicViewController
        vc.service = _selectedService
    }
}
