//
//  ServiceHeaderView.swift
//  NaptimeBLE
//
//  Created by NyanCat on 26/10/2017.
//  Copyright © 2017 EnterTech. All rights reserved.
//

import UIKit

class ServiceHeaderView: UIView {

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

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 1.0
    }
}
