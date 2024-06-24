//
//  UICollectionViewCellExtension.swift
//  Dokgi
//
//  Created by IMHYEONJEONG on 6/20/24.
//

import Foundation

import UIKit

extension UICollectionViewCell {
    // 셀이 작아지게 설정
    func transformToSmall() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    // 기본 셀 크기로 지정
    func transformToStandard() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }
}
