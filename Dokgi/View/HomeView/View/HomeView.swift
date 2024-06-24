//
//  HomeView.swift
//  Dokgi
//
//  Created by IMHYEONJEONG on 6/21/24.
//

import SnapKit
import Then
import UIKit

protocol HomeViewDelegate: AnyObject {
    func didTapSettingButton()
}

class HomeView: UIView {
    weak var delegate: HomeViewDelegate?
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    let contentView = UIView()
    
    let settingButton = UIButton().then {
        $0.setImage(.setting, for: .normal)
        $0.tintColor = .charcoalBlue
    }
    
    let currentLengthLabel = UILabel().then {
        $0.text = "현재 구절 길이"
        $0.font = Pretendard.semibold.dynamicFont(style: .title3)
        $0.textColor = .black
    }

    let currentLevelCollectionView = UICollectionView(frame: .zero, collectionViewLayout: CurrentLevelCollectionFlowLayout()).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.decelerationRate = .fast
    }
    
    let nextLengthLabel = UILabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.textColor = .black
    }
    
    let lengthSlider = UISlider().then {
        if let thumbImage = UIImage(named: "currentThum") {
            $0.setThumbImage(thumbImage, for: .normal)
            $0.setThumbImage(thumbImage, for: .highlighted)
        }
        $0.isUserInteractionEnabled = false
    }
    
    let currentLevelBubble = UIImageView().then {
        $0.image = .speechBubble1
        $0.clipsToBounds = true
    }
    
    let currentLevelImage = UIImageView().then {
        $0.backgroundColor = .clear
        $0.image = .grape
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFit
    }
    
    let nextLevelBubble = UIImageView().then {
        $0.image = .speechBubble2
        $0.clipsToBounds = true
        $0.layer.masksToBounds = true
    }
    
    let questionMark = UILabel().then {
        $0.font = .systemFont(ofSize: 30, weight: .heavy)
        $0.textColor = .deepSkyBlue
        $0.text = "?"
        $0.textAlignment = .center
    }
    
    let todayVersesLabel = UILabel().then {
        $0.text = "오늘의 구절"
        $0.font = Pretendard.semibold.dynamicFont(style: .title3)
        $0.textColor = .black
    }
    
    let todayVersesColletionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
    }).then {
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.isPagingEnabled = true
        $0.layer.cornerRadius = 10
    }
    
    var indicatorDots = UIPageControl().then {
        $0.pageIndicatorTintColor = UIColor(.dotGray).withAlphaComponent(0.3)
        $0.currentPageIndicatorTintColor = UIColor(.dotBlue)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        [settingButton,
         currentLengthLabel,
         currentLevelCollectionView,
         nextLengthLabel,
         lengthSlider,
         currentLevelBubble,
         nextLevelBubble,
         todayVersesLabel,
         todayVersesColletionView,
         indicatorDots].forEach {
            contentView.addSubview($0)
        }
        
        currentLevelBubble.addSubview(currentLevelImage)
        nextLevelBubble.addSubview(questionMark)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.bottom.width.equalToSuperview()
        }
        
        settingButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(3)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        currentLengthLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(58)
            $0.leading.equalToSuperview().offset(29)
        }
        
        currentLevelCollectionView.snp.makeConstraints {
            $0.top.equalTo(currentLengthLabel.snp.bottom).offset(15)
            $0.leading.trailing.centerX.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        nextLengthLabel.snp.makeConstraints {
            $0.top.equalTo(currentLevelCollectionView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(35)
        }
        
        lengthSlider.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(35)
            $0.top.equalTo(nextLengthLabel.snp.bottom).offset(18)
        }
        
        currentLevelBubble.snp.makeConstraints {
            $0.width.equalTo(38)
            $0.height.equalTo(41)
            $0.top.equalTo(lengthSlider.snp.bottom)
            $0.centerX.equalTo(lengthSlider.snp.trailing).multipliedBy(1)
        }
        
        currentLevelImage.snp.makeConstraints {
            $0.width.height.equalTo(28)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(1)
        }
        
        nextLevelBubble.snp.makeConstraints {
            $0.width.equalTo(38)
            $0.height.equalTo(41)
            $0.top.equalTo(lengthSlider.snp.bottom)
            $0.trailing.equalTo(lengthSlider.snp.trailing).offset(17)
        }
        
        questionMark.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview().offset(0.5)
        }
        
        todayVersesLabel.snp.makeConstraints {
            $0.top.equalTo(currentLevelBubble.snp.bottom).offset(53)
            $0.leading.equalTo(currentLengthLabel.snp.leading)
        }
        
        todayVersesColletionView.snp.makeConstraints {
            $0.top.equalTo(todayVersesLabel.snp.bottom).offset(14)
            $0.bottom.equalToSuperview().offset(-63)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(158)
        }
        
        indicatorDots.snp.makeConstraints {
            $0.centerX.equalTo(todayVersesColletionView.snp.centerX)
            $0.bottom.equalTo(todayVersesColletionView.snp.bottom).offset(-8)
        }
    }
    
    func setConfigureUI(viewModel: HomeViewModel) {
        settingButton.addTarget(self, action: #selector(didTapSetting), for: .touchUpInside)
        nextLengthLabel.text = "다음 레벨까지 \(Int(Float(viewModel.currentLevelPercent.value) * 100)) % 달성했습니다!"
        indicatorDots.numberOfPages = viewModel.randomVerses.value.count
    }
    
    @objc func didTapSetting() {
        delegate?.didTapSettingButton()
    }
}
