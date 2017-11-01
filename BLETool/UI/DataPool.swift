//
//  DataPool.swift
//  NaptimeBLE
//
//  Created by NyanCat on 28/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static let pool = DispatchQueue(label: "cn.entertech.NaptimeBLE.pool")
}

class DataPool {

    private var _data = Data()

    var isEmpty: Bool {
        return _data.count == 0
    }

    var isAvailable: Bool {
        return _data.count > 0
    }

    func push(data: Data) {
        DispatchQueue.pool.sync {
            _data.append(data)
        }
    }

    func pop(length: Int) -> Data {
        var data: Data = Data()
        DispatchQueue.pool.sync {
            let count = min(length, _data.count)
            data = _data.subdata(in: 0..<count)
            _ = _data.dropFirst(count)
        }
        return data
    }

    func dry() {
        DispatchQueue.pool.sync {
            _data.removeAll()
        }
    }

}
