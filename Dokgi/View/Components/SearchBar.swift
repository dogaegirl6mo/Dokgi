//
//  SearchBar.swift
//  Dokgi
//
//  Created by 예슬 on 6/21/24.
//

import UIKit

class SearchBar: UISearchBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSearchBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSearchBar() {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.searchBarDarkGray,
            NSAttributedString.Key.font: Pretendard.regular.dynamicFont(style: .subheadline)
        ]
        
        if let leftView = self.searchTextField.leftView as? UIImageView {
                        leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                        leftView.tintColor = UIColor.searchBarDarkGray
                    }
        
        self.searchBarStyle = .minimal
        self.setPositionAdjustment(UIOffset(horizontal: 8, vertical: 0), for: .search)
        self.setPositionAdjustment(UIOffset(horizontal: -8, vertical: 0), for: .clear)
        self.searchTextField.borderStyle = .line
        self.searchTextField.layer.borderWidth = 1
        self.searchTextField.layer.borderColor = UIColor(resource: .searchBarLightGray).cgColor
        self.searchTextField.layer.backgroundColor = UIColor.white.cgColor
        self.searchTextField.layer.cornerRadius = 18
        self.searchTextField.layer.masksToBounds = true
        self.searchTextField.font = Pretendard.regular.dynamicFont(style: .subheadline)
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: "기록한 구절을 검색해보세요", attributes: attributes)
    }
}
