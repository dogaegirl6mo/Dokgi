//
//  TimePickerView.swift
//  Dokgi
//
//  Created by 송정훈 on 6/5/24.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class TimePickerViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    lazy var writeBool = true
    
    private let viewModel = DayTimeViewModel()
    
    let cancelBtn = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.brightRed, for: .normal)
        $0.titleLabel?.font = Pretendard.regular.dynamicFont(style: .body)
    }
    
    let titleLbl = UILabel().then {
        $0.text = "알림 시간 설정"
        $0.font = Pretendard.semibold.dynamicFont(style: .title3)
        $0.textAlignment = .center
    }
    
    let saveBtn = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.setTitleColor(.skyBlue, for: .normal)
        $0.titleLabel?.font = Pretendard.regular.dynamicFont(style: .body)
    }
    
    let titleStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
    }
    
    let timePicker = UIPickerView().then {
        $0.backgroundColor = .white
    }
    //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if writeBool == true {
            viewModel.selectTime = DayTimeViewModel.writeTime.value
        } else {
            viewModel.selectTime = DayTimeViewModel.remindTime.value
        }
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
        timePicker.delegate = self
        timePicker.dataSource = self
        setupLayout()
        dataBind()
    }
    // MARK: - Layout
    func setupLayout() {
        
        [cancelBtn, titleLbl, saveBtn].forEach {
            titleStack.addArrangedSubview($0)
        }
        
        view.addSubview(titleStack)
        view.addSubview(timePicker)
        
        titleStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        timePicker.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(95)
        }
        timePicker.selectRow((viewModel.selectTime[0] - 1) + 12 * 50, inComponent: 0, animated: false)
        timePicker.selectRow(viewModel.selectTime[1] + 60 * 50, inComponent: 1, animated: false)
        timePicker.selectRow(viewModel.selectTime[2], inComponent: 2, animated: false)
    }
    
    func dataBind() {
        cancelBtn.rx.tap.subscribe { [weak self] _ in
            self?.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        saveBtn.rx.tap.subscribe { [weak self] _ in
            self?.dismiss(animated: true)
            self?.viewModel.saveTime(write: self?.writeBool ?? false)
        }.disposed(by: disposeBag)
    }
}
// MARK: - PickerView DataSource, Delegate
extension TimePickerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return viewModel.hourArr.count * 100
        case 1:
            return viewModel.minArr.count * 100
        case 2:
            return viewModel.ampmArr.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(viewModel.hourArr[row % viewModel.hourArr.count])
        case 1:
            return String(viewModel.minArr[row % viewModel.minArr.count])
        case 2:
            return String(viewModel.ampmArr[row])
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.setTime(row: row, component: component)
        print(viewModel.selectTime)
    }
}
