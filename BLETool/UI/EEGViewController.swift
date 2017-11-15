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
import AVFoundation

class EEGViewController: UITableViewController {
    var eegService: EEGService!
    var commandService: CommandService!

    private let _player: AVAudioPlayer = {
        let url = Bundle.main.url(forResource: "1-minute-of-silence", withExtension: "mp3")!
        let player = try! AVAudioPlayer(contentsOf: url)
        player.numberOfLoops = 10000
        return player
    }()

    private var _isSampling: Bool = false
    private var _disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "采集", style: .plain, target: self, action: #selector(sampleButtonTouched))
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none

        _player.play()

        self.eegService.notify(characteristic: .contact)
            .observeOn(MainScheduler())
            .subscribe(onNext: {
                SVProgressHUD.showInfo(withStatus: "佩戴状态: \($0)")
            }, onError: { _ in
                SVProgressHUD.showInfo(withStatus: "监测佩戴状态失败")
            }).disposed(by: _disposeBag)
    }

    deinit {
        _player.stop()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if _isSampling {
            stopSample()
        }
    }

    @objc
    private func sampleButtonTouched() {
        if _isSampling {
            commandService.write(data: Data(bytes: [0x02]), to: .send).then {
                dispatch_to_main { [unowned self] in
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "采集", style: .plain, target: self, action: #selector(self.sampleButtonTouched))
                    self.stopSample()
                    self._isSampling = !self._isSampling
                }
                }.catch { _ in
                    SVProgressHUD.showError(withStatus: "发送停止指令失败")
            }
        } else {
            dataList.removeAll()
            tableView.reloadData()
            commandService.write(data: Data(bytes: [0x01]), to: .send).then {
                dispatch_to_main { [unowned self] in
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "停止", style: .plain, target: self, action: #selector(self.sampleButtonTouched))

                    self._timerDisposable = self.startSample()
                        .observeOn(MainScheduler())
                        .subscribe(onNext: {
                            self.render(data: $0)
                        })
                    self._isSampling = !self._isSampling
                }
                }.catch { _ in
                    SVProgressHUD.showError(withStatus: "发送开始指令失败")
            }
        }
    }

    private var _eegDisposable: Disposable?
    private var _timerDisposable: Disposable?

    private func startSample() -> Observable<Data> {
        SVProgressHUD.showInfo(withStatus: "UI 只循环显示 10s 的数据\n不然内存要炸了💥💥")
        EEGFileManager.shared.create()

        let dataPool = DataPool()
        _eegDisposable = self.eegService.notify(characteristic: .data)
            .subscribe(onNext: {
                var received = $0
                received.removeFirst(2)
                let data = Data(bytes: received)
                dataPool.push(data: data)
            }, onError: { _ in
                SVProgressHUD.showError(withStatus: "监听脑波数据失败")
            })

        return Observable<Data>.create { observer -> Disposable in
            let timer = Timer.every(1.0, {
                if dataPool.isAvailable {
                    // 每次取 750 个字节，即 1s 的数据量
                    let data = dataPool.pop(length: 750)
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
        _eegDisposable?.dispose()
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
