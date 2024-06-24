//
//  AddPassageButton.swift
//  Dokgi
//
//  Created by 예슬 on 6/22/24.
//

import SnapKit
import UIKit

class AddPassageButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setButton()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setButton() {
        self.setTitle("기록 하기", for: .normal)
        self.titleLabel?.font = Pretendard.bold.dynamicFont(style: .headline)
        self.setTitleColor(.white, for: .normal)
        self.backgroundColor = .charcoalBlue
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.width.equalTo(353)
            $0.height.equalTo(53)
        }
    }
    
    func setButtonTitle(_ title: String) {
        self.setTitle(title, for: .normal)
    }
}
