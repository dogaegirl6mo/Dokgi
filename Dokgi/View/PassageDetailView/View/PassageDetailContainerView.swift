//
//  ParagrapScrollView.swift
//  Dokgi
//
//  Created by 송정훈 on 6/7/24.
//

import SnapKit
import Then
import UIKit

class PassageDetailContainerView: UIView {
    let textView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .lightPastelBlue
    }
    
    lazy var passageScrollView = UIScrollView().then {
        $0.backgroundColor = .clear
    }
    
    lazy var passageTextLbl = UILabel().then {
        $0.textAlignment = .left
        $0.font = Pretendard.regular.dynamicFont(style: .callout)
        $0.numberOfLines = 20
        $0.textColor = .black
    }
    
    let copyButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setImage(.copyicon, for: .normal)
    }
    
    let keywordStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 7
    }
    
    let keywordLabelStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
    }
    
    let keywordLabel = UILabel().then {
        $0.text = "키워드"
        $0.font = Pretendard.semibold.dynamicFont(style: .body)
        $0.textColor = .black
    }
    
    let noKeywordLabel = UILabel().then {
        $0.text = "키워드가 없습니다"
        $0.font = Pretendard.regular.dynamicFont(style: .callout)
        $0.textColor = .bookTextGray
    }
    
    lazy var keywordCollectionView = UICollectionView(frame: self.bounds, collectionViewLayout: createBasicListLayout()).then {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = false
        $0.isScrollEnabled = true
        $0.snp.makeConstraints {
            $0.height.equalTo(52)
        }
    }
    
    let writeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
    }
    
    let writeDateTitle = UILabel().then {
        $0.text = "기록날짜"
        $0.font = Pretendard.semibold.dynamicFont(style: .body)
        $0.textColor = .black
    }
    
    lazy var writeDateDay = UILabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .body)
        $0.textColor = .alarmSettingText
    }
    
    let pageStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
    }
    
    let pageTitle = UILabel().then {
        $0.text = "페이지"
        $0.font = Pretendard.semibold.dynamicFont(style: .body)
        $0.textColor = .black
    }
    
    lazy var pageWriteLbl = UILabel().then {
        $0.font = Pretendard.regular.dynamicFont(style: .body)
        $0.textColor = .alarmSettingText
    }
    
    let passageTextField = UITextView().then {
        $0.font = Pretendard.regular.dynamicFont(style: .callout)
        $0.backgroundColor = .clear
        $0.isScrollEnabled = true
        $0.textContainer.lineBreakMode = .byWordWrapping
        $0.isHidden = true
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
        $0.textColor = .black
    }
    
    let keywordTextField = UITextField().then {
        $0.font = Pretendard.regular.dynamicFont(style: .callout)
        $0.attributedPlaceholder = NSAttributedString(string: "키워드를 입력해 주세요", attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldGray])
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(resource: .keywordBorder).cgColor
        $0.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 22.0, height: 0.0))
        $0.leftViewMode = .always
        $0.isHidden = true
        $0.textColor = .black
        $0.snp.makeConstraints {
            $0.height.equalTo(33)
        }
    }
    
    let pageTextStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    
    let pageTextField = UITextField().then {
        $0.font = Pretendard.regular.dynamicFont(style: .callout)
        $0.placeholder = "페이지"
        $0.textColor = .black
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(resource: .borderGray).cgColor
        $0.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 18.0, height: 0.0))
        $0.leftViewMode = .always
        $0.isHidden = true
        $0.snp.makeConstraints {
            $0.width.equalTo(60)
        }
    }
    
    let pageSegment = SegmentControlView().then {
        $0.isHidden = true
        $0.selectedIndex = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    func setupLayout() {
        addSubview(textView)
        textView.addSubview(passageScrollView)
        passageScrollView.addSubview(passageTextLbl)
        textView.addSubview(passageTextField)
        textView.addSubview(copyButton)
        addSubview(keywordStackView)
        [keywordLabel, noKeywordLabel].forEach {
            keywordLabelStackView.addArrangedSubview($0)
        }
        [keywordLabelStackView, keywordTextField, keywordCollectionView].forEach {
            keywordStackView.addArrangedSubview($0)
        }
        addSubview(writeStackView)
        [writeDateTitle, writeDateDay].forEach {
            writeStackView.addArrangedSubview($0)
        }
        addSubview(pageTextStack)
        [pageTitle, pageTextField].forEach {
            pageTextStack.addArrangedSubview($0)
        }
        addSubview(pageStackView)
        [pageTextStack, pageSegment, pageWriteLbl].forEach {
            pageStackView.addArrangedSubview($0)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(276)
        }
        
        passageScrollView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(15)
            $0.bottom.equalToSuperview().inset(46)
        }
        
        passageTextLbl.snp.makeConstraints {
            $0.top.width.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
        }
        
        passageTextField.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.verticalEdges.equalToSuperview().inset(15)
        }
        
        copyButton.snp.makeConstraints {
            $0.top.equalTo(passageScrollView.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(24)
        }
        
        writeStackView.snp.makeConstraints {
            $0.top.equalTo(textView.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        pageStackView.snp.makeConstraints {
            $0.top.equalTo(writeStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        keywordStackView.snp.makeConstraints {
            $0.top.equalTo(pageStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    func createBasicListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .estimated(34))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .absolute(32))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(7)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 7
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func editLayout() {
        passageTextField.becomeFirstResponder()
        [passageTextField, keywordTextField, pageTextField, pageSegment].forEach {
            $0.isHidden = false
        }
        passageTextField.text = passageTextLbl.text
        [passageTextLbl, copyButton, pageWriteLbl].forEach {
            $0.isHidden = true
        }
    }
    
    func editCompleteLayout() {
        [passageTextField, keywordTextField, pageTextField, pageSegment].forEach {
            $0.isHidden = true
        }
        [passageTextLbl, copyButton, pageWriteLbl].forEach {
            $0.isHidden = false
        }
    }
    
    func paragrapTextLimit(_ str : String) {
        if str.count > 200 {
            let index = str.index(str.startIndex, offsetBy: 200)
            self.passageTextField.text = String(str[..<index])
        }
    }
    
    func keywordTextLimit(_ str : String) {
        if str.count > 20 {
            let index = str.index(str.startIndex, offsetBy: 20)
            self.keywordTextField.text = String(str[..<index])
        }
    }
}
