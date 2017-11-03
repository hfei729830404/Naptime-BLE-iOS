//
//  CommandService.swift
//  NaptimeBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public class CommandService: Service {
    public typealias ST = CommandService
}

extension CommandService: Writable, Notifiable {

    public typealias WriteType = Characteristic.Command.Write

    public typealias NotifyType = Characteristic.Command.Notify
}

func aa() {
    let device = CommandService()
    device.notify(characteristic: .receive)
}
