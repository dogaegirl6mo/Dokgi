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

class TimePickerViewController: BaseAlarmSettingSheetViewController {
    
    lazy var writeBool = true
    
    let timePicker = UIPickerView().then {
        $0.backgroundColor = .white
        $0.setValue(UIColor.black, forKey: "textColor")
    }
    
    // MARK: - Layout
    override func setLayout() {
        super.setLayout()
        
        view.addSubview(timePicker)
        
        timePicker.snp.makeConstraints {
            $0.top.equalTo(titleStack.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(95)
        }
        timePicker.selectRow((viewModel.selectTime[0] - 1) + 12 * 50, inComponent: 0, animated: false)
        timePicker.selectRow(viewModel.selectTime[1] + 60 * 50, inComponent: 1, animated: false)
        timePicker.selectRow(viewModel.selectTime[2], inComponent: 2, animated: false)
    }
    
    override func initialize() {
        if writeBool == true {
            viewModel.selectTime = DayTimeViewModel.writeTime.value
        } else {
            viewModel.selectTime = DayTimeViewModel.remindTime.value
        }
        timePicker.delegate = self
        timePicker.dataSource = self
    }
    
    override func saveAction() {
        self.viewModel.saveTime(write: self.writeBool)
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
