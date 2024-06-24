//
//  DateExtension.swift
//  Dokgi
//
//  Created by 송정훈 on 6/14/24.
//

import Foundation

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd"
        
        return formatter.string(from: self)
    }
}
