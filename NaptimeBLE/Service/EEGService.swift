//
//  EEGService.swift
//  NaptimeBLE
//
//  Created by HyanCat on 02/11/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

public class EEGService: Service {
    public typealias ST = EEGService
}

extension EEGService: Notifiable {
    public typealias NotifyType = Characteristic.EEG
}
