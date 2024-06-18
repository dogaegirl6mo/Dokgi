//
//  CurrentLevelCell.swift
//  Dokgi
//
//  Created by IMHYEONJEONG on 6/5/24.
//

import SnapKit
import UIKit

class CurrentLevelCell: UICollectionViewCell {
    static let identifier = "CurrentLevelCell"
    
    let cardView = UIView()
    let textView = UIView()
    let levelView = UIView()
    let levelLabel = UILabel()
    let descrptionLabel = UILabel()
    let lengthLabel = UILabel()
    let cardImageView = UIImageView()
    var blurEffectView = UIVisualEffectView()
    let hideView = UIView()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupConstraints()
        setUpShadow()
//        setupBlur(alpha: 0.8)
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
            $0.leading.equalToSuperview()
            $0.top.equalToSuperview()
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
    }
    
    func configureUI() {
        contentView.layer.cornerRadius = 8
        cardView.backgroundColor = .white
        
        cardImageView.backgroundColor = .clear
        cardImageView.contentMode = .scaleAspectFit
        textView.backgroundColor = .clear
        
        levelView.backgroundColor = .lightSkyBlue
        levelView.layer.cornerRadius = 10
        
        levelLabel.textColor = .mediumSkyBlue
        levelLabel.font = Pretendard.extrabold.dynamicFont(style: .caption1)
        
        descrptionLabel.font = Pretendard.regular.dynamicFont(style: .callout)
        descrptionLabel.numberOfLines = 2
        
        lengthLabel.textColor = .mediumSkyBlue
        lengthLabel.font = Pretendard.extrabold.dynamicFont(style: .title1)
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

    func setupBlur(alpha: CGFloat = 0.5) {
        // 블러 효과 생성
        let blurEffect = UIBlurEffect(style: .systemThinMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        // 블러 효과 뷰의 크기와 위치 설정
        blurEffectView.frame = self.contentView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.backgroundColor = .white.withAlphaComponent(0.5)
        
        // 블러 효과 뷰를 셀의 contentView에 추가
        self.contentView.addSubview(blurEffectView)
        
        // 블러 효과의 알파값 설정
        blurEffectView.alpha = alpha
        
        self.blurEffectView = blurEffectView
    }
    
    func setupNextLevelCell(_ level : Int) {
        hideView.backgroundColor = .white
        let nextLevel = UILabel()
        let currentLevel = UILabel()
        let questionMark = UILabel()
        
        contentView.addSubview(hideView)
        [nextLevel, currentLevel, questionMark].forEach {
            hideView.addSubview($0)
        }
        
        nextLevel.text = "Level \(level + 1)"
        nextLevel.font = Pretendard.bold.dynamicFont(style: .title3)
        currentLevel.text = "Level \(level)을 다 달성하면 보입니다"
        currentLevel.font = Pretendard.regular.dynamicFont(style: .callout)
        currentLevel.textColor = .alarmSettingText
        questionMark.font = .systemFont(ofSize: 60, weight: .heavy)
        questionMark.textColor = .deepSkyBlue
        questionMark.text = "?"
        
        hideView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nextLevel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
        }
        
        currentLevel.snp.makeConstraints {
            $0.top.equalTo(nextLevel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        
        questionMark.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(currentLevel.snp.bottom)
        }
        
    }
}

