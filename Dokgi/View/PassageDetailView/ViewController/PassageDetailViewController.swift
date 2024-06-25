//
//  ParagrapViewController.swift
//  Dokgi
//
//  Created by 송정훈 on 6/7/24.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class PassageDetailViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    let viewModel = PassageDetailViewModel()
    
    let titleStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
    }
    
    lazy var titleLbl = UILabel().then {
        $0.font = Pretendard.semibold.dynamicFont(style: .title3)
        $0.textColor = .black
    }
    
    let xBtn = UIButton().then {
        $0.setImage(UIImage(resource: .deleteKeyword).withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .modelxGray
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.backgroundColor = .modelxBackground
        $0.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
    }
    
    let editBtn = UIButton().then {
        $0.setTitle("수정하기", for: .normal)
        $0.titleLabel?.font = Pretendard.regular.dynamicFont(style: .footnote)
        $0.setTitleColor(.black, for: .normal)
        $0.setImage(.modalEdit, for: .normal)
    }
    
    let detailScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    lazy var containerView = PassageDetailContainerView()
    
    let smallId = UISheetPresentationController.Detent.Identifier("small")
    lazy var smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
        return UIScreen.main.bounds.size.height - 228
    }
    let largeId = UISheetPresentationController.Detent.Identifier("large")
    lazy var largeDetent = UISheetPresentationController.Detent.custom(identifier: self.largeId) { context in
        return UIScreen.main.bounds.size.height - 115
    }
    
    //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if let sheet = sheetPresentationController {
            sheet.detents = [smallDetent]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 8
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        containerView.keywordCollectionView.register(KeywordCollectionViewCell.self, forCellWithReuseIdentifier: KeywordCollectionViewCell.identifier)
        setupLayout()
        dataBinding()
    }
    
    // MARK: - Layout
    func setupLayout() {
        view.addSubview(titleStack)
        [titleLbl, xBtn].forEach {
            titleStack.addArrangedSubview($0)
        }
        view.addSubview(editBtn)
        view.addSubview(detailScrollView)
        detailScrollView.addSubview(containerView)
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(28)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        editBtn.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().inset(25)
            $0.height.equalTo(22)
        }
        
        detailScrollView.snp.makeConstraints {
            $0.top.equalTo(editBtn.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(detailScrollView.snp.width)
        }
    }
    
    func dataBinding() {
        viewModel.detailPassage.subscribe(with: self) { (self, data) in
            self.titleLbl.text = data.name
            self.containerView.passageTextLbl.text = data.text
            self.viewModel.keywords.accept(data.keywords)
            self.containerView.pageWriteLbl.text = "\(data.pageNumber) \(data.pageType)"
            self.containerView.writeDateDay.text = data.date.toString()
        }.disposed(by: disposeBag)
        
        self.xBtn.rx.tap.subscribe(with: self) { (self, _) in
            self.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        self.editBtn.rx.tap.subscribe(with: self) { (self, _) in
            if self.editBtn.titleLabel?.text == "수정하기" {
                self.containerView.editLayout()
                self.sheetPresentationController?.detents = [self.largeDetent]
                self.editBtn.setTitle("완료", for: .normal)
                self.editBtn.titleLabel?.font = Pretendard.semibold.dynamicFont(style: .callout)
                self.editBtn.setTitleColor(.skyBlue, for: .normal)
                self.editBtn.setImage(nil, for: .normal)
                self.containerView.pageTextField.text = "\(self.viewModel.detailPassage.value.pageNumber)"
                self.containerView.keywordCollectionView.reloadData()
                if self.viewModel.detailPassage.value.pageType == "%" {
                    self.containerView.pageSegment.selectedIndex = 1
                }
            } else {
                let alert = self.containerView.pageTextField.selectAlert(pageType: self.containerView.pageSegment.selectedIndex)
                if alert.title == nil {
                    self.containerView.editCompleteLayout()
                    self.sheetPresentationController?.detents = [self.smallDetent]
                    self.editBtn.setTitle("수정하기", for: .normal)
                    self.editBtn.titleLabel?.font = Pretendard.regular.dynamicFont(style: .footnote)
                    self.editBtn.setTitleColor(.black, for: .normal)
                    self.editBtn.setImage(.modalEdit, for: .normal)
                    self.viewModel.saveDetail(paragraph: self.containerView.passageTextField.text, page: self.containerView.pageTextField.text ?? "", pageType: self.containerView.pageSegment.selectedIndex)
                } else {
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }.disposed(by: disposeBag)
        
        containerView.copyButton.rx.tap.subscribe(with: self) { (self, _) in
            UIPasteboard.general.string = self.containerView.passageTextLbl.text
        }.disposed(by: disposeBag)
        
        containerView.pageSegment.buttons[0].rx.tap.subscribe { sender in
            self.containerView.pageSegment.selectedIndex = 0
        }.disposed(by: disposeBag)
        
        containerView.pageSegment.buttons[1].rx.tap.subscribe { sender in
            self.containerView.pageSegment.selectedIndex = 1
        }.disposed(by: disposeBag)
        
        containerView.passageTextField.rx.text.orEmpty.subscribe(with: self) { (self, text) in
            self.containerView.paragrapTextLimit(text)
        }.disposed(by: disposeBag)
        
        containerView.keywordTextField.rx.controlEvent(.editingDidBegin).subscribe(with: self) { (self, _) in
            self.viewModel.addDetailKeyword(keyword: "")
            self.containerView.noKeywordLabel.isHidden = true
            self.containerView.keywordCollectionView.isHidden = false
        }.disposed(by: disposeBag)
        
        containerView.keywordTextField.rx.text.orEmpty.subscribe(with: self) { (self, text) in
            self.containerView.keywordTextLimit(text)
            self.viewModel.updateDetailKeyword(keyword: text)
        }.disposed(by: disposeBag)
        
        containerView.keywordTextField.rx.controlEvent(.editingDidEnd).subscribe(with: self) { (self, _) in
            self.containerView.keywordTextField.text = ""
        }.disposed(by: disposeBag)
        
        viewModel.keywords.subscribe(with: self) { (self, data) in
            if data.isEmpty {
                self.containerView.noKeywordLabel.isHidden = false
                self.containerView.keywordCollectionView.isHidden = true
            } else {
                self.containerView.noKeywordLabel.isHidden = true
                self.containerView.keywordCollectionView.isHidden = false
            }
        }.disposed(by: disposeBag)
        
        viewModel.keywords.bind(to: containerView.keywordCollectionView.rx.items(cellIdentifier: KeywordCollectionViewCell.identifier,
                   cellType: KeywordCollectionViewCell.self)) { row, data, cell in
            cell.keywordLabel.text = data
            cell.xButton.rx.tap.subscribe(with: self) { (self, data) in
                self.viewModel.deleteDetailKeyword(keyword: row)
            }.disposed(by: cell.disposeBag)
            
            if self.editBtn.titleLabel?.text == "수정하기" {
                cell.xButton.isHidden = true
            } else {
                cell.xButton.isHidden = false
            }
        }.disposed(by: disposeBag)
    }
}
