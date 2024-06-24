//
//  RecentSearchCell.swift
//  Dokgi
//
//  Created by 한철희 on 6/18/24.
//

import SnapKit
import Then
import UIKit

class RecentSearchCell: UICollectionViewCell {
    
    static let identifier = "RecentSearchCell"
    var viewModel: BookSearchViewModel!
    
    private let label = UILabel().then {
        $0.textColor = .brightBlue
        $0.font = Pretendard.regular.dynamicFont(style: .callout)
    }
    
    private let deleteButton = UIButton().then {
        $0.setImage(.deleteRecentSearch, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(label)
        addSubview(deleteButton)
        
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    private func setupCell() {
        layer.cornerRadius = 14
        clipsToBounds = true
        layer.borderColor = UIColor.lightSkyBlue.cgColor
        layer.borderWidth = 2
    }
    
    func configure(with text: String, viewModel: BookSearchViewModel) {
        self.viewModel = viewModel
        label.text = text
    }
    
    @objc private func deleteButtonTapped() {
        guard let collectionView = superview as? UICollectionView else { return }
        guard let indexPath = collectionView.indexPath(for: self) else { return }
        
        viewModel.removeRecentSearch(at: indexPath)
        
        collectionView.reloadData()
    }
}
