//
//  CurrentLevelCell.swift
//  Dokgi
//
//  Created by IMHYEONJEONG on 6/5/24.
//

import SnapKit
import Then
import UIKit

class CurrentLevelCell: UICollectionViewCell {
    static let identifier = "CurrentLevelCell"
    
    let cardView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let textView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    let levelView = UIView().then {
        $0.backgroundColor = .lightSkyBlue
        $0.layer.cornerRadius = 10
    }
    
    let levelLabel = UILabel().then {
        $0.textColor = .mediumSkyBlue
        $0.font = Pretendard.extrabold.dynamicFont(style: .caption1)
    }
    
    let descrptionLabel = UILabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .callout)
        $0.numberOfLines = 2
        $0.textColor = .black
    }
    
    let lengthLabel = UILabel().then {
        $0.textColor = .mediumSkyBlue
        $0.font = Pretendard.extrabold.dynamicFont(style: .title1)
    }
    
    let cardImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
    }
    
    let hideView = UIView()
    
    let nextLevel = PaddingLabel(padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)).then {
        $0.font = Pretendard.bold.dynamicFont(style: .title3)
        $0.textColor = .black
    }
    
    let currentLevel = UILabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .callout)
        $0.textColor = .alarmSettingText
        $0.textAlignment = .center
    }
    
    let questionMark = PaddingLabel(padding: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)).then {
        $0.font = .systemFont(ofSize: 60, weight: .heavy)
        $0.textColor = .deepSkyBlue
        $0.text = "?"
    }
    
    lazy var stackView = UIStackView(arrangedSubviews: [nextLevel, currentLevel, questionMark]).then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupConstraints()
        setUpShadow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        contentView.addSubview(cardView)
        [textView, cardImageView].forEach {
            cardView.addSubview($0)
        }
        
        [levelView, levelLabel, descrptionLabel, lengthLabel].forEach {
            textView.addSubview($0)
        }
        
        contentView.addSubview(hideView)
        [stackView].forEach { hideView.addSubview($0) }
        
        cardView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        cardImageView.snp.makeConstraints {
            $0.height.width.equalTo(107)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        textView.snp.makeConstraints {
            $0.centerY.equalTo(cardImageView.snp.centerY)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(cardImageView.snp.leading)
        }
        
        levelView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
        }
        
        levelLabel.snp.makeConstraints {
            $0.center.equalTo(levelView)
            $0.top.equalTo(levelView.snp.top).offset(4)
            $0.bottom.equalTo(levelView.snp.bottom).offset(-4)
            $0.leading.equalTo(levelView.snp.leading).offset(8)
            $0.trailing.equalTo(levelView.snp.trailing).offset(-8)
        }
        
        descrptionLabel.snp.makeConstraints {
            $0.top.equalTo(levelView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
        }
        
        lengthLabel.snp.makeConstraints {
            $0.top.equalTo(descrptionLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        hideView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.centerY.horizontalEdges.equalToSuperview()
        }
    }
    
    func configureUI() {
        contentView.layer.cornerRadius = 8
    }
    
    func setCellConfig(_ cardData: Card) {
        if let cardImage = cardData.cardImage {
            cardImageView.image = cardImage
        }
        
        let formattedLength = MetricUtil.formatLength(length: cardData.length)
        levelLabel.text = "LEVEL " + String(cardData.level)
        descrptionLabel.text = "\(cardData.descrption) 만큼 (\(formattedLength))"
        lengthLabel.text = String(formattedLength)
    }
    
    // 그림자 설정
    func setUpShadow() {
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 9
        layer.shadowOffset = CGSize(width: 0, height: 0)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
    }

    // 다음 레벨셀 설정
    func setupNextLevelCell(_ level : Int) {
        hideView.backgroundColor = .white
        nextLevel.text = "Level \(level + 1)"
        currentLevel.text = "Level \(level)을 다 달성하면 보입니다"
    }
    
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
