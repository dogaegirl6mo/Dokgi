//
//  addSubviewsExtension.swift
//  Dokgi
//
//  Created by 한철희 on 6/21/24.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
}
