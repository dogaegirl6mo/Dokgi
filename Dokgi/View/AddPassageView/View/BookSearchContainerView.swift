//
//  BookSearchContainerView.swift
//  Dokgi
//
//  Created by 한철희 on 6/21/24.
//

import SnapKit
import Then
import UIKit

class BookSearchContainerView: UIView {
    
    // MARK: - UI
    let tableView = UITableView().then {
        $0.rowHeight = 150
        $0.showsVerticalScrollIndicator = false
        $0.isHidden = true
    }
    
    let searchBar = SearchBar().then {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.searchBarDarkGray,
            NSAttributedString.Key.font: Pretendard.regular.dynamicFont(style: .subheadline)
        ]
        $0.searchTextField.attributedPlaceholder = NSAttributedString(string: "책을 검색해보세요", attributes: attributes)
    }
    
    let recentSearchLabel = UILabel().then {
        $0.font = Pretendard.semibold.dynamicFont(style: .headline)
        let poundKeyImage: UIImage? = .poundKey
        if let image = poundKeyImage {
            let attachment = NSTextAttachment()
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -3, width: image.size.width, height: image.size.height)
            let attachmentString = NSAttributedString(attachment: attachment)
            let mutableAttributedString = NSMutableAttributedString(string: " ")
            mutableAttributedString.append(attachmentString)
            mutableAttributedString.append(NSAttributedString(string: " 최근 검색어"))
            $0.attributedText = mutableAttributedString
        }
    }
    
    let clearAllButton = UIButton(configuration: .plain()).then {
        $0.setTitle("전체 삭제", for: .normal)
        $0.titleLabel?.font = Pretendard.regular.dynamicFont(style: .footnote)
        $0.setTitleColor(.placeholderText, for: .normal)
        $0.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
    }

    let noResultsLabel = UILabel().then {
        $0.text = "검색어와 일치하는 책이 없습니다"
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    let recentSearchStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 8
    }
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 30)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.backgroundColor = .white
            $0.isHidden = false
            $0.showsHorizontalScrollIndicator = false
        }
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - addSubView
    private func addSubView() {
        [tableView, searchBar, noResultsLabel, recentSearchStackView,collectionView].forEach { addSubview($0) }
        
        [recentSearchLabel, clearAllButton].forEach {
            recentSearchStackView.addArrangedSubview($0)
        }
    }
    
    // MARK: - setConstraints
    private func setConstraints() {
        searchBar.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
        }
        
        recentSearchStackView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(17)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(recentSearchStackView.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        noResultsLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
