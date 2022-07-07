//
//  FormUtils.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 24/06/22.
//

import Foundation
import UIKit

class FormUtils {
    var fields: [UIControl]
    
    init(fields: [UIControl]) {
        self.fields = fields
    }
    
    func setFieldsStatus(isEnabled: Bool) {
        for field in fields {
            field.isEnabled = isEnabled
        }
    }
}
