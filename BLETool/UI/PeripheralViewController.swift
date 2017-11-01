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

    let disposeBag: DisposeBag = DisposeBag()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设备 " + peripheral.displayName

        tableView.tableFooterView = UIView()

        SVProgressHUD.show(withStatus: "正在连接:\n \(peripheral.displayName)")
        peripheral.connect()
            .timeout(10, scheduler: MainScheduler())
            .flatMap { $0.discoverServices(nil) }
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.services = $0
            }, onError: { _ in
                SVProgressHUD.showError(withStatus: "连接失败")
            }, onCompleted: {
                SVProgressHUD.dismiss()
                dispatch_to_main {
                    self.tableView.reloadData()
                }
            }, onDisposed: nil).disposed(by: disposeBag)
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

    private var _selectedService: Service?

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
