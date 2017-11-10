//
//  CommandService.swift
//  NaptimeBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation
import CoreBluetooth
import RxSwift
import PromiseKit

public class CommandService: BLEService {
    
}

extension CommandService: Writable {

    public typealias WriteType = Characteristic.Command.Write

}

extension CommandService: Notifiable {

    public typealias NotifyType = Characteristic.Command.Notify

}

func __example() {
//    let device = BLEService<CommandService>.service(type: .command)
//    device.notify(characteristic: .state).subscribe(onNext: { _ in
//
//    }, onError: { _ in
//        //
//    }, onCompleted: {
//
//    }, onDisposed: nil).disposed(by: DisposeBag())
}
