//
//  InfoView.swift
//  Dokgi
//
//  Created by 한철희 on 6/24/24.
//

import UIKit

class InfoView: UIView {

    var imageView = UIImageView().then {
        $0.image = UIImage(resource: .empty).withRenderingMode(.alwaysTemplate)
        $0.tintColor = .buttonLightGray
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
    }
    
    var titleLabel = UILabel().then {
        $0.text = "책 제목"
        $0.font = Pretendard.bold.dynamicFont(style: .body)
        $0.textColor = .bookTextGray
        $0.numberOfLines = 2
    }
    
    var authorLabel = UILabel().then {
        $0.text = "저자"
        $0.font = Pretendard.bold.dynamicFont(style: .body)
        $0.textColor = .bookTextGray
        $0.numberOfLines = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [imageView, titleLabel, authorLabel].forEach { addSubview($0) }
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 103, height: 146))
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-16)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        authorLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}
