//
//  CommandViewController.swift
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

class CommandViewController: UIViewController {

    let disposeBag = DisposeBag()

    var service: Service!
    var uploadCharacteristic: Characteristic?
    var downloadCharacteristic: Characteristic?

    @IBOutlet weak var textView: UITextView!

    var isNotifing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = false

        textView.text.append("\n")

        service.characteristics?.forEach { _ in
//            if $0.uuid.whichCharacteristic == .cmd_download {
//                self.downloadCharacteristic = $0
//            } else if $0.uuid.whichCharacteristic == .cmd_upload {
//                self.uploadCharacteristic = $0
//            }
        }

        notifyIfNeeded()
    }

    @IBAction func commandAButtonTouched(_ sender: UIBarButtonItem) {
        send(data: Data(bytes: [0x0A]))
    }

    @IBAction func commandBButtonTouched(_ sender: UIBarButtonItem) {
        send(data: Data(bytes: [0x0B]))
    }

    @IBAction func commandRandomButtonTouched(_ sender: UIBarButtonItem) {
        let v = UInt8(arc4random() % 256)
        send(data: Data(bytes: [v]))
    }

    private func notifyIfNeeded() {
        if isNotifing { return }
        self.downloadCharacteristic?.setNotificationAndMonitorUpdates().subscribe { [weak self] in
            guard let `self` = self else { return }
            if let data = $0.element!.value {
                self.received(data: data)
            }
        }.disposed(by: disposeBag)
        isNotifing = true
    }

    private func send(data: Data) {
        if let uploadChar = self.uploadCharacteristic {
            uploadChar.writeValue(data, type: .withResponse).subscribe().disposed(by: disposeBag)
        }
    }

    private func received(data: Data) {
        dispatch_to_main {
            self.textView.text.append(data.hexString)
            self.textView.scrollRangeToVisible(NSMakeRange(self.textView.text.count-1, 1))
        }
    }

}
