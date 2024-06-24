//
//  SortMenuView.swift
//  Dokgi
//
//  Created by 예슬 on 6/21/24.
//

import SnapKit
import Then
import UIKit

class SortMenuView: UIView {
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.backgroundColor = .white
        $0.alignment = .leading
    }
    
    let latestButton = UIButton().then {
        $0.backgroundColor = .white
    }
    
    let latestCheckImage = UIImageView().then {
        $0.image = .check
    }
    
    private let latestLabel = UILabel().then {
        $0.text = "최신순"
        $0.font = Pretendard.regular.dynamicFont(style: .footnote)
        $0.textColor = .charcoalBlue
    }
    
    let oldestButton = UIButton().then {
        $0.backgroundColor = .white
    }
    
    let oldestCheckImage = UIImageView().then {
        $0.image = .check
    }
    
    private let oldestLabel = UILabel().then {
        $0.text = "오래된순"
        $0.font = Pretendard.regular.dynamicFont(style: .footnote)
        $0.textColor = .charcoalBlue
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 2
    }
    
    private func setLayout() {
        self.addSubview(stackView)
        
        [latestButton, oldestButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        [latestCheckImage, latestLabel].forEach {
            latestButton.addSubview($0)
        }
        
        [oldestCheckImage, oldestLabel].forEach {
            oldestButton.addSubview($0)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(6)
            $0.horizontalEdges.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        latestButton.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        latestCheckImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
            $0.height.width.equalTo(10)
        }
        
        latestLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(27)
            $0.leading.equalTo(latestCheckImage.snp.trailing).offset(6)
        }
        
        oldestButton.snp.makeConstraints {
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        oldestCheckImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(12)
            $0.height.width.equalTo(10)
        }
        
        oldestLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(27)
            $0.leading.equalTo(oldestCheckImage.snp.trailing).offset(6)
        }
    }
}
