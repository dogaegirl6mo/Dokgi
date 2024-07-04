//
//  BaseLibraryAndPassageViewController.swift
//  Dokgi
//
//  Created by 예슬 on 6/21/24.
//
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class BaseLibraryAndPassageViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let searchBar = SearchBar()
    let sortButton = SortButton()
    private let sortMenuView = SortMenuView()
    
    let titleLabel = UILabel().then {
        $0.font = Pretendard.bold.dynamicFont(style: .title1)
        $0.textColor = .black
    }
    
    let noResultsLabel = UILabel().then {
        $0.text = "기록한 책이 없어요\n구절을 등록해 보세요"
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
        setFloatingButton()
        configureUI()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        searchBar.delegate?.searchBarCancelButtonClicked?(searchBar)
        sortMenuView.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
    }
    
    // MARK: - UI
    
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
    
    func setBinding() {
        searchBar.searchTextField.rx.controlEvent(.editingDidBegin).subscribe(with: self) { (self, _) in
            self.searchBar.showsCancelButton = true
        }.disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked.subscribe(with: self) { (self, _) in
            self.searchBar.text = ""
            self.searchBar.resignFirstResponder()
            self.searchBar.showsCancelButton = false
        }.disposed(by: disposeBag)
        
        searchBar.rx.searchButtonClicked.subscribe(with: self) { (self, _) in
            self.searchBar.resignFirstResponder()
            self.searchBar.showsCancelButton = false
        }.disposed(by: disposeBag)
    }
    
    func configureUI() {}
    func latestButtonAction() {}
    func oldestButtonAction() {}
}

private extension BaseLibraryAndPassageViewController {
    func setLayout() {
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
            $0.top.equalTo(sortButton.snp.bottom).offset(5)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        noResultsLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setSortMenuView() {
        sortMenuView.isHidden = true
        sortMenuView.latestCheckImage.isHidden = false
        sortMenuView.oldestCheckImage.isHidden = true
    }
    
    func tappedButton() {
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
}
