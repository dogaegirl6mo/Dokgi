//
//  BaseLibraryAndPassageViewController.swift
//  Dokgi
//
//  Created by 예슬 on 6/21/24.
//

import RxSwift
import SnapKit
import Then
import UIKit

class BaseLibraryAndPassageViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private let searchBar = SearchBar()
    private let sortButton = SortButton()
    private let sortMenuView = SortMenuView()
    
    private let titleLabel = UILabel().then {
        $0.font = Pretendard.bold.dynamicFont(style: .title1)
        $0.textColor = .black
        $0.text = "구절"
    }
    
    private let noResultsLabel = UILabel().then {
        $0.text = "기록한 구절이 없어요\n구절을 등록해 보세요"
        let paragraphStyle = NSMutableParagraphStyle()
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.black,
            .font: Pretendard.regular.dynamicFont(style: .subheadline)
        ]
        let attrString = NSMutableAttributedString(string: $0.text!, attributes: attributes)
        $0.isHidden = true
        $0.numberOfLines = 0
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 4
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        $0.attributedText = attrString
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setLayout()
        setSortMenuView()
        tappedButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UI
    
    private func setLayout() {
        [titleLabel, searchBar, sortButton, sortMenuView, noResultsLabel].forEach {
            self.view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(41)
        }
        
        searchBar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        sortButton.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        sortMenuView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(3)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        noResultsLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func setSortMenuView() {
        sortMenuView.isHidden = true
        sortMenuView.latestCheckImage.isHidden = false
        sortMenuView.oldestCheckImage.isHidden = true
    }
    
    // 구절, 서재 각 뷰 컨트롤러에서 사용
    func setLabelText(title: String, placeholder: String, noResultsMessage: String) {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.searchBarDarkGray,
            NSAttributedString.Key.font: Pretendard.regular.dynamicFont(style: .subheadline)
        ]
        
        titleLabel.text = title
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        noResultsLabel.text = noResultsMessage
    }
    
    private func tappedButton() {
        sortButton.rx.tap.subscribe(with: self) { (self, _) in
            if self.sortMenuView.isHidden {
                self.sortMenuView.isHidden = false
                self.view.bringSubviewToFront(self.sortMenuView)
            } else {
                self.sortMenuView.isHidden = true
            }
        }.disposed(by: disposeBag)
        
        sortMenuView.latestButton.rx.tap.subscribe(with: self) { (self, _) in
            self.sortButton.sortButtonTitleLabel.text = "최신순"
            self.sortMenuView.latestCheckImage.isHidden = false
            self.sortMenuView.oldestCheckImage.isHidden = true
            self.latestButtonAction()
            self.sortMenuView.isHidden = true
        }.disposed(by: disposeBag)
        
        sortMenuView.oldestButton.rx.tap.subscribe(with: self) { (self, _) in
            self.sortButton.sortButtonTitleLabel.text = "오래된순"
            self.sortMenuView.latestCheckImage.isHidden = true
            self.sortMenuView.oldestCheckImage.isHidden = false
            self.oldestButtonAction()
            self.sortMenuView.isHidden = true
        }.disposed(by: disposeBag)
    }
    
    // 이 함수 override 해서 saveAction 작성해주시면 될 것 같아요
    func latestButtonAction() {}
    func oldestButtonAction() {}
}
