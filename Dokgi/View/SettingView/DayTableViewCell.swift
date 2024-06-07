//
//  DayTableViewCell.swift
//  Dokgi
//
//  Created by 송정훈 on 6/5/24.
//

import UIKit

class DayTableViewCell: UITableViewCell {
    
    static let identifier = "DayTableViewCell"
    
    let dayLabel = UILabel().then {
        $0.text = ""
        $0.font = Pretendard.regular.dynamicFont(style: .body, size: 17)
    }
    
    let check = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(dayLabel)
        addSubview(check)
        
        dayLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.safeAreaLayoutGuide.snp.centerY)
            $0.leading.equalTo(self.safeAreaLayoutGuide.snp.leading).inset(20)
        }
        
        check.snp.makeConstraints {
            $0.centerY.equalTo(dayLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(10)
            $0.height.width.equalTo(24)
        }
    }
    
}
