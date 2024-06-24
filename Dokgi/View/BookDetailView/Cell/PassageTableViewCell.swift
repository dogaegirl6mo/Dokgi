//
//  PassageTableViewCell.swift
//  Dokgi
//
//  Created by 예슬 on 6/11/24.
//

import SnapKit
import Then
import UIKit

class PassageTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: PassageTableViewCell.self)
    private let viewModel = BookDetailViewModel()
    
    private let circleView = UIView().then {
        $0.backgroundColor = .charcoalBlue
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = .timeLineGray
    }
    
    private let pageLabel = UILabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .caption1)
        $0.textColor = .black
    }
    
    private let passageLabel = PaddingLabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.textAlignment = .left
        $0.backgroundColor = .lightPastelBlue
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.numberOfLines = 4
        $0.textColor = .black
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        [lineView, circleView, pageLabel, passageLabel].forEach {
            contentView.addSubview($0)
        }
        
        circleView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
            $0.height.width.equalTo(16)
        }
        
        lineView.snp.makeConstraints {
            $0.centerX.equalTo(circleView)
            $0.width.equalTo(1)
            $0.verticalEdges.equalToSuperview()
        }
        
        pageLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        pageLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(circleView.snp.trailing).offset(11)
            $0.trailing.lessThanOrEqualTo(passageLabel.snp.leading).offset(-10)
        }
        
        passageLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(6)
            $0.leading.equalTo(pageLabel.snp.trailing).offset(10)
            $0.trailing.equalToSuperview()
        }
    }
    
    func setPassageData(passage: Passage) {
        let pageNumber = passage.pageNumber
        let pageType = passage.pageType
        
        pageLabel.text = String(pageNumber) + viewModel.pageTypeToP(pageType)
        passageLabel.text = passage.text
    }
}
