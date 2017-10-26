//
//  ServiceHeaderView.swift
//  NaptimeBLE
//
//  Created by NyanCat on 26/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit

class ServiceHeaderView: UITableViewHeaderFooterView {

    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }

    var detail: String = "" {
        didSet {
            detailLabel.text = detail
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
}
