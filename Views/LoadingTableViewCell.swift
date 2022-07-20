//
//  LoadingTableViewCell.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 15/07/22.
//

import Foundation
import UIKit

class LoadingTableViewCell: UITableViewCell {
    static let identifier = "LoadingTableViewCell"
    
    @IBOutlet weak var textLabl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
