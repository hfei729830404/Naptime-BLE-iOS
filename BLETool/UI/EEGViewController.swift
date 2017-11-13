//
//  EEGViewController.swift
//  NaptimeBLE
//
//  Created by NyanCat on 27/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxBluetoothKit
import RxSwift
import SVProgressHUD
import SwiftyTimer
import NaptimeBLE

class EEGViewController: UITableViewController {
    var service: EEGService!

    var isSampling: Bool = false
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "采集", style: .plain, target: self, action: #selector(sampleButtonTouched))
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isSampling {
            stopSample()
        }
    }

    @objc
    private func sampleButtonTouched() {
        if isSampling {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "采集", style: .plain, target: self, action: #selector(sampleButtonTouched))
            stopSample()
        } else {
            dataList.removeAll()
            tableView.reloadData()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "停止", style: .plain, target: self, action: #selector(sampleButtonTouched))

            _timerDisposable = startSample()
                .observeOn(MainScheduler())
                .subscribe(onNext: {
                    self.render(data: $0)
                })
        }
        isSampling = !isSampling
    }

    private var _notifyDisposable: Disposable?
    private var _timerDisposable: Disposable?

    private func startSample() -> Observable<Data> {
        SVProgressHUD.showInfo(withStatus: "UI 只循环显示 10s 的数据\n不然内存要炸了💥💥")
        EEGFileManager.shared.create()
        let dataPool = DataPool()
        _notifyDisposable = self.service.notify(characteristic: .data)
            .subscribe(onNext: {
                let data = Data(bytes: $0)
                dataPool.push(data: data)
            }, onError: { _ in
                SVProgressHUD.showError(withStatus: "监听脑波数据失败")
            })

        return Observable<Data>.create { observer -> Disposable in
            let timer = Timer.every(1.0, {
                if dataPool.isAvailable {
                    // 每次取 850 个字节，即 1s 的数据量
                    let data = dataPool.pop(length: 850)
                    self.saveToFile(data: data)
                    observer.onNext(data)
                }
            })
            return Disposables.create {
                timer.invalidate()
                dataPool.dry()
            }
        }
    }

    private func stopSample() {
        _notifyDisposable?.dispose()
        _timerDisposable?.dispose()
        let fileName = EEGFileManager.shared.fileName
        EEGFileManager.shared.close()
        SVProgressHUD.showSuccess(withStatus: "保存文件成功: \(fileName!)")
    }

    var dataList: [Data] = []

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eegCellReuseIdentifier", for: indexPath) as! EEGCell
        let data = dataList[indexPath.row]
        cell.dataLabel.text = data.hexString
        return cell
    }

    private func render(data: Data) {
        if dataList.count >= 10 {
            dataList.removeAll()
            tableView.reloadData()
        }
        dataList.append(data)
        let indexPath = IndexPath(row: dataList.count-1, section: 0)
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    private func saveToFile(data: Data) {
        EEGFileManager.shared.save(data: data)
    }
}

class EEGCell: UITableViewCell {
    @IBOutlet weak var dataLabel: UILabel!
}
