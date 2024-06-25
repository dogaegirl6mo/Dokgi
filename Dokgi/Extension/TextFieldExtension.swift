//
//  TextFieldExtension.swift
//  Dokgi
//
//  Created by 송정훈 on 6/24/24.
//

import UIKit

extension UITextField {
    func selectAlert(pageType: Int) -> UIAlertController {
        var title: String = ""
        var message: String = ""
        
        if self.text!.isEmpty == true {
            title = "페이지"
            message = "페이지를 입력해 주세요"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            return alert
        }
        
        if let pageNumberText = self.text, let _ = Int(pageNumberText) {
            if pageType == 0 && Int((self.text)!) ?? 0 <= 0 {
                title = "페이지 값 오류"
                message = "0 이상을 입력하세요."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                return alert
            } else if pageType == 1 && Int((self.text)!) ?? 101 > 100 {
                title = "% 값 오류"
                message = "100이하를 입력하세요."
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                return alert
            }
        } else {
            title = "입력 값 오류"
            message = "숫자를 입력하세요."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            return alert
        }
        return UIAlertController()
    }
}
