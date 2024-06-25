//
//  BaseAlarmSettingSheetViewController.swift
//  Dokgi
//
//  Created by 예슬 on 6/21/24.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class BaseAlarmSettingSheetViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = DayTimeViewModel()
    var titleString = "알림 시간 설정"
    private let cancelBtn = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.brightRed, for: .normal)
        $0.titleLabel?.font = Pretendard.regular.dynamicFont(style: .body)
    }
    
    private let titleLbl = UILabel().then {
        $0.font = Pretendard.semibold.dynamicFont(style: .title3)
        $0.textAlignment = .center
        $0.textColor = .black
    }
    
    private let saveBtn = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.setTitleColor(.skyBlue, for: .normal)
        $0.titleLabel?.font = Pretendard.regular.dynamicFont(style: .body)
    }
    
    let titleStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initialize()
        setSheet()
        buttonTapped()
        setLayout()
        titleLbl.text = titleString
    }
    
    func initialize() {
        
    }
    // MARK: - UI
    
    private func setSheet() {
        let smallId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
            return UIScreen.main.bounds.size.height - 450
        }
        
        if let sheet = sheetPresentationController {
            sheet.detents = [smallDetent]
            sheet.largestUndimmedDetentIdentifier = smallId
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 8
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }
    
    func buttonTapped() {
        cancelBtn.rx.tap.subscribe(with: self) { (self, _) in
            self.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        saveBtn.rx.tap.subscribe(with: self) { (self, _) in
            self.dismiss(animated: true)
            self.saveAction()
        }.disposed(by: disposeBag)
    }
    
    func setLayout() {
        view.addSubview(titleStack)
        [cancelBtn, titleLbl, saveBtn].forEach {
            titleStack.addArrangedSubview($0)
        }
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
    }
    
    func saveAction() {
        // 이 함수 override 해서 saveAction 작성해주시면 될 것 같아요
    }
}
