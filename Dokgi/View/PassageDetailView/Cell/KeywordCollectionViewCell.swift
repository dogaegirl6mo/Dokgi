//
//  KeywordCollectionViewCell.swift
//  Dokgi
//
//  Created by 송정훈 on 6/9/24.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class KeywordCollectionViewCell: UICollectionViewCell {
    static let identifier = "KeywordCollectionViewCell"
    var disposeBag = DisposeBag()
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
    }
    
    let keywordLabel = UILabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .callout)
        $0.textColor = .brightBlue
    }
    
    let xButton = UIButton().then {
        $0.setImage(.deleteKeyword, for: .normal)
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentView()
        setupLayout()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    private func setContentView() {
        self.backgroundColor = .white
        self.layer.borderColor = UIColor.keywordBorderBlue.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 14
        self.clipsToBounds = true
    }
    
    private func setupAction() {
        xButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func deleteButtonTapped() {
        guard let collectionView = superview as? UICollectionView else { return }
        guard let indexPath = collectionView.indexPath(for: self) else { return }
        (collectionView.delegate as? AddPassageViewController)?.removeKeyword(at: indexPath)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        addSubview(stackView)
        [keywordLabel, xButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(10)
            $0.verticalEdges.equalToSuperview().inset(5)
        }
    }
}
