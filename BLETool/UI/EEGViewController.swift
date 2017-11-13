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

class EEGViewController: UIViewController {
    var service: EEGService!

    var isSampling: Bool = false
    private let disposeBag = DisposeBag()

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "采集", style: .plain, target: self, action: #selector(sampleButtonTouched))
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
            self.textView.text.removeAll()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "停止", style: .plain, target: self, action: #selector(sampleButtonTouched))

            startSample()
                .observeOn(MainScheduler())
                .subscribe(onNext: {
                    self.updateTempToTextView(data: $0)
                })
                .disposed(by: disposeBag)
        }
        isSampling = !isSampling
    }

    var _timer: Timer?

    private func startSample() -> Observable<Data> {
        EEGFileManager.shared.create()
        let dataPool = DataPool()
        self.service.notify(characteristic: .data)
            .subscribe(onNext: {
                let data = Data(bytes: $0)
                dataPool.push(data: data)
            }, onError: { _ in
                SVProgressHUD.showError(withStatus: "监听脑波数据失败")
            })
            .disposed(by: disposeBag)

        return Observable<Data>.create { observer -> Disposable in
            let timer = Timer.every(0.5, {
                if dataPool.isAvailable {
                    let data = dataPool.pop(length: 1000)
                    self.saveToFile(data: data)
                    observer.onNext(data)
                }
            })
            return Disposables.create {
                timer.invalidate()
            }
        }
    }

    private func stopSample() {
        self.service.stopNotify(characteristic: .data)
        _timer?.invalidate()
        _timer = nil
        let fileName = EEGFileManager.shared.fileName
        EEGFileManager.shared.close()
        SVProgressHUD.showSuccess(withStatus: "保存文件成功: \(fileName!)")
    }


    private func updateTempToTextView(data: Data) {
        self.textView.text.append(data.hexString)
        self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.count-1, 1))
    }

    private func saveToFile(data: Data) {
        EEGFileManager.shared.save(data: data)
    }
}
