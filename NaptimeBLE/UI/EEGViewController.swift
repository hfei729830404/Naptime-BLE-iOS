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

class EEGViewController: UIViewController {
    var service: Service!
    var characteristic: Characteristic?

    var isSampling: Bool = false
    private let disposeBag = DisposeBag()

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "采集", style: .plain, target: self, action: #selector(sampleButtonTouched))

        service.discoverCharacteristics(nil).flatMap { Observable.from($0) }.filter { $0.uuid.whichCharacteristic == .eeg_data }.take(1).subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.characteristic = $0
        }).disposed(by: disposeBag)
    }

    private var _temp: String = ""

    @objc
    private func sampleButtonTouched() {
        if isSampling {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "采集", style: .plain, target: self, action: #selector(sampleButtonTouched))
            self.characteristic?.setNotifyValue(false).subscribe().disposed(by: disposeBag)
            if _temp.count > 0 {
                updateTempToTextView()
            }
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "停止", style: .plain, target: self, action: #selector(sampleButtonTouched))
            self.characteristic?.setNotificationAndMonitorUpdates().subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                if let data = $0.value {
                    self._temp.append(data.hexString)
                    self._temp.append("\n\n")
                    if self._temp.count >= 300 {
                        dispatch_to_main {
                            self.updateTempToTextView()
                        }
                    }
                }
            }, onError: { _ in
                SVProgressHUD.showError(withStatus: "发现特性失败")
            }, onCompleted: { [weak self] in
                guard let `self` = self else { return }
                if self._temp.count > 0 {
                    dispatch_to_main {
                        self.updateTempToTextView()
                    }
                }
            }).disposed(by: disposeBag)
        }
        isSampling = !isSampling
    }

    private func updateTempToTextView() {
        self.textView.text.append(_temp)
        self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.count-1, 1))
        _temp.removeAll()
    }
}
