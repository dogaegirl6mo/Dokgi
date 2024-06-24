//
//  AddVerseContainerLayout.swift
//  Dokgi
//
//  Created by 한철희 on 6/17/24.
//

import Kingfisher
import SnapKit
import Then
import UIKit

class AddPassageContainerView: UIView {
    
    // MARK: - UI
    let scanButton = UIButton(configuration: .filled(), primaryAction: nil).then {
        $0.configurationUpdateHandler = { button in
            var configuration = button.configuration
            configuration?.title = "구절 스캔"
            configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = Pretendard.bold.dynamicFont(style: .subheadline)
                return outgoing
            }
            configuration?.baseForegroundColor = .charcoalBlue
            configuration?.baseBackgroundColor = .lightSkyBlue
            configuration?.image = UIImage(resource: .camera).withTintColor(UIColor(resource: .charcoalBlue), renderingMode: .alwaysOriginal)
            configuration?.imagePadding = 10
            button.configuration = configuration
        }
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
    }
    
    let infoView = InfoView()
    
    let infoViewOverLapView = UIView().then {
        $0.backgroundColor = UIColor.lightSkyBlue.withAlphaComponent(0.5)
        $0.layer.cornerRadius = 15
    }
    
    let searchButton = UIButton(type: .system).then {
        var config = UIButton.Configuration.filled()
        config.title = "책 검색"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .charcoalBlue
        config.image = .magnifyingglass
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 15)
        $0.titleLabel?.font = Pretendard.semibold.dynamicFont(style: .headline)
        $0.configuration = config
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
        $0.titleLabel?.numberOfLines = 1
    }

    let textViewBoder = UIView().then {
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.7).cgColor
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    lazy var verseTextView = UITextView().then {
        $0.text = "텍스트를 입력하세요"
        $0.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        $0.font = Pretendard.regular.dynamicFont(style: .body)
        $0.showsVerticalScrollIndicator = false
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8.0
        let attributedString = NSAttributedString(string: $0.text ?? "", attributes: [.paragraphStyle: paragraphStyle])
        $0.attributedText = attributedString
        $0.textColor = .placeholderText
    }
    
    let characterCountLabel = UILabel().then {
        $0.textColor = .textFieldGray
        $0.font = Pretendard.bold.dynamicFont(style: .footnote)
    }
    
    private let pencilImageView = UIImageView().then {
        $0.image = UIImage(named: "pencil")
        $0.contentMode = .scaleAspectFit
    }
    
    let keywordLabel = UILabel().then {
        $0.attributedText = createAttributedString(for: "키워드 (선택)")
        $0.textAlignment = .left
    }
    
    let keywordField = UITextField().then {
        $0.placeholder = "키워드를 입력해 주세요"
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.textColor = .textFieldGray
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.borderGray.cgColor
    }
    
    lazy var keywordCollectionView = UICollectionView(frame: .zero, collectionViewLayout: {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        return layout
    }()).then {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
    }
    
    let pageLabel = UILabel().then {
        $0.text = "페이지"
        $0.font = Pretendard.semibold.dynamicFont(style: .headline)
        $0.textColor = .black
    }
    
    let pageNumberTextField = UITextField().then {
        $0.placeholder = "페이지"
        $0.textColor = .textFieldGray
        $0.textAlignment = .center
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.borderStyle = .roundedRect
    }
    
    let pageSegment = SegmentControlView().then {
        $0.selectedIndex = 0
    }
    
    let recordButton = AddPassageButton().then {
        $0.setButtonTitle("기록 하기")
    }
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        initLayout()
        setkeywordTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setupViews
    private func setupViews() {
        [scanButton, infoView, textViewBoder, verseTextView, characterCountLabel, pencilImageView, keywordLabel, keywordField, keywordCollectionView, pageLabel, pageNumberTextField, pageSegment, recordButton].forEach { addSubview($0) }
        
        infoView.addSubview(infoViewOverLapView)
        infoViewOverLapView.addSubview(searchButton)
    }
    
    // MARK: - 제약조건
    private func initLayout() {
        scanButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(16)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(scanButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(200)
        }
        
        infoViewOverLapView.snp.makeConstraints {
            $0.edges.equalTo(infoView)
        }
        
        searchButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(35)
        }

        textViewBoder.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(329)
        }
        
        verseTextView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom).offset(35)
            $0.horizontalEdges.equalToSuperview().inset(18)
            $0.bottom.equalTo(pencilImageView.snp.top).inset(8)
        }
        
        characterCountLabel.snp.makeConstraints {
            $0.trailing.bottom.equalTo(textViewBoder).inset(16)
        }
        
        pencilImageView.snp.makeConstraints {
            $0.leading.bottom.equalTo(textViewBoder).inset(16)
        }
        
        keywordLabel.snp.makeConstraints {
            $0.top.equalTo(textViewBoder.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        keywordField.snp.makeConstraints {
            $0.top.equalTo(keywordLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(36)
        }
        
        keywordCollectionView.snp.makeConstraints {
            $0.top.equalTo(keywordField.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(35)
        }
        
        pageLabel.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom).offset(50)
            $0.leading.equalToSuperview().offset(16)
        }
        
        pageNumberTextField.snp.makeConstraints {
            $0.centerY.equalTo(pageLabel.snp.centerY)
            $0.leading.equalTo(pageLabel.snp.trailing).offset(8)
            $0.width.equalTo(60)
            $0.height.equalTo(30)
        }
        
        pageSegment.snp.makeConstraints {
            $0.centerY.equalTo(pageLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(30)
            $0.width.equalTo(120)
        }
        
        recordButton.snp.makeConstraints {
            $0.top.equalTo(pageLabel.snp.bottom).offset(60)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
    }
    
    func setkeywordTextField() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: keywordField.frame.height))
        keywordField.leftView = paddingView
        keywordField.leftViewMode = .always
        keywordField.rightView = paddingView
        keywordField.rightViewMode = .always
    }
}

extension AddPassageContainerView {
    static func createAttributedString(for text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        // "키워드" 부분 설정
        let keywordRange = (text as NSString).range(of: "키워드")
        attributedString.addAttributes([.font: Pretendard.semibold.dynamicFont(style: .headline)], range: keywordRange)
        
        // "(선택)" 부분 설정
        let selectionRange = (text as NSString).range(of: "(선택)")
        attributedString.addAttributes([.font: Pretendard.regular.dynamicFont(style: .headline), .foregroundColor: UIColor.gray], range: selectionRange)
        
        return attributedString
    }
}
