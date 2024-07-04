//
//  TodayVersesCell.swift
//  Dokgi
//
//  Created by IMHYEONJEONG on 6/12/24.
//

import SnapKit
import UIKit

class TodayPassageCell: UICollectionViewCell {
    static let identifier = "TodayVersesCell"
    
    let baseView = UIView()
    let verse = UILabel()
    let bookImage = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        contentView.addSubview(baseView)
        
        [verse, bookImage].forEach {
            baseView.addSubview($0)
        }
        
        baseView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(7.5)
            $0.verticalEdges.equalToSuperview()
        }
        
        verse.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.leading.equalToSuperview().offset(26)
            $0.trailing.equalTo(bookImage.snp.leading).offset(-28).priority(.low)
            $0.bottom.equalToSuperview().inset(35)
            $0.width.equalTo(186)
            $0.height.equalTo(95)
        }
        
        bookImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(19)
            $0.trailing.equalToSuperview().offset(-21)
            $0.bottom.equalToSuperview().inset(32)
            $0.width.equalTo(92)
            $0.height.equalTo(107)
        }
    }
    
    func configureUI() {
        baseView.backgroundColor = .lightSkyBlue
        baseView.layer.cornerRadius = 10
        verse.font = Pretendard.regular.dynamicFont(style: .callout)
        verse.numberOfLines = 4
        verse.textColor = .black
        bookImage.image = .mainBook
    }
}
