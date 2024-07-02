//
//  BackButton.swift
//  Dokgi
//
//  Created by 송정훈 on 7/2/24.
//

import UIKit

class BackButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setImage(UIImage.backicon, for: .normal)
        self.setTitle("Back", for: .normal)
        self.setTitleColor(.brightBlue, for: .normal) // Set title color
        self.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        self.sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
