//
//  AlarmView.swift
//  Dokgi
//
//  Created by 송정훈 on 6/4/24.
//

import SnapKit
import Then
import UIKit

class AlarmView: UIView {
    
    let alarmTitle = UILabel().then {
        $0.text = "알림 설정"
        $0.font = Pretendard.bold.dynamicFont(style: .title3)
        $0.textColor = .black
    }
    
    let remindSwitch = UISwitch().then {
        $0.isOn = true
        $0.onTintColor = .brightBlue
    }
    
    lazy var remindSwitchBtn = UIButton(frame: remindSwitch.frame).then {
        $0.backgroundColor = .clear
    }
    
    let remindTitle = UILabel().then {
        $0.text = "리마인드 알림"
        $0.font = Pretendard.regular.dynamicFont(style: .body)
        $0.textColor = .black
    }
    
    let remindDescription = UILabel().then {
        $0.text = "구절을 리마인드 해주는 알림"
        $0.textColor = .alarmMemoGray
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
    }
    
    let remindStack = UIStackView().then {
        $0.spacing = 5
        $0.axis = .vertical
    }
    
    let remindTimeLbl = UILabel().then {
        $0.text = "알림 시간"
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.textColor = .alarmSettingText
    }
    
    let remindTimeBtn = UIButton().then {
        $0.setTitle("PM 15 : 00", for: .normal)
        $0.setTitleColor(.alarmSettingText, for: .normal)
        $0.titleLabel?.font = Pretendard.regular.dynamicFont(style: .subheadline)
    }
    
    let border = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.8588235294, green: 0.8431372549, blue: 0.8431372549, alpha: 1)
    }
    
    let remindTimeStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
    }
    
    let borderStack = UIStackView().then {
        $0.spacing = 20
        $0.axis = .vertical
    }
    
    let writeSwitch = UISwitch().then {
        $0.isOn = true
        $0.onTintColor = .brightBlue
    }
    
    lazy var writeSwitchBtn = UIButton(frame: writeSwitch.frame).then {
        $0.backgroundColor = .clear
    }
    
    let writeTitle = UILabel().then {
        $0.text = "기록하기 알림"
        $0.textColor = .black
        $0.font = Pretendard.regular.dynamicFont(style: .body)
    }
    
    let writeDescription = UILabel().then {
        $0.text = "독서 알림"
        $0.textColor = .alarmMemoGray
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
    }
    
    let writeStack = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 5
    }
    
    let writeWeek = UILabel().then {
        $0.text = "알림 요일"
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.textColor = .alarmSettingText
    }
    
    let weekBtn = UIButton().then {
        $0.setTitle("매일", for: .normal)
        $0.setTitleColor(.alarmSettingText, for: .normal)
        $0.titleLabel?.font = Pretendard.regular.dynamicFont(style: .subheadline)
    }
    
    let writeWeekStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .equalSpacing
    }
    
    let writeTimeLbl = UILabel().then {
        $0.text = "알림 시간"
        $0.font = Pretendard.regular.dynamicFont(style: .subheadline)
        $0.textColor = .alarmSettingText
    }
    
    let writeTimeBtn = UIButton().then {
        $0.setTitle("PM 15 : 00", for: .normal)
        $0.setTitleColor(.alarmSettingText, for: .normal)
        $0.titleLabel?.font = Pretendard.regular.dynamicFont(style: .subheadline)
    }
    
    let writeTimeStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(alarmTitle)
        addSubview(remindSwitch)
        addSubview(remindSwitchBtn)
        addSubview(remindStack)
        [remindTitle, remindDescription].forEach {
            remindStack.addArrangedSubview($0)
        }
        addSubview(borderStack)
        [remindTimeStack, border].forEach {
            borderStack.addArrangedSubview($0)
        }
        
        [remindTimeLbl, remindTimeBtn].forEach {
            remindTimeStack.addArrangedSubview($0)
        }
        
        addSubview(writeSwitch)
        addSubview(writeSwitchBtn)
        addSubview(writeStack)
        [writeTitle, writeDescription].forEach {
            writeStack.addArrangedSubview($0)
        }
        
        addSubview(writeWeekStack)
        [writeWeek, weekBtn].forEach {
            writeWeekStack.addArrangedSubview($0)
        }
        
        addSubview(writeTimeStack)
        [writeTimeLbl, writeTimeBtn].forEach {
            writeTimeStack.addArrangedSubview($0)
        }
        
        alarmTitle.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(27)
            
        }
        remindStack.snp.makeConstraints {
            $0.top.equalTo(alarmTitle.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(27)
        }
        
        remindSwitch.snp.makeConstraints {
            $0.centerY.equalTo(remindStack)
            $0.leading.equalTo(remindStack.snp.trailing).offset(27)
            $0.trailing.equalToSuperview().inset(27)
        }
        
        remindSwitchBtn.snp.makeConstraints {
            $0.centerY.equalTo(remindStack)
            $0.trailing.equalToSuperview().inset(27)
        }
        
        borderStack.snp.makeConstraints {
            $0.top.equalTo(remindStack.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(27)
        }
        
        border.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        
        writeStack.snp.makeConstraints {
            $0.top.equalTo(border.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(27)
        }
        
        writeSwitch.snp.makeConstraints {
            $0.centerY.equalTo(writeStack)
            $0.trailing.equalToSuperview().inset(27)
        }
        
        writeSwitchBtn.snp.makeConstraints {
            $0.centerY.equalTo(writeStack)
            $0.trailing.equalToSuperview().inset(27)
        }
        
        writeWeekStack.snp.makeConstraints {
            $0.top.equalTo(writeStack.snp.bottom).offset(33)
            $0.leading.trailing.equalToSuperview().inset(27)
        }
        
        writeTimeStack.snp.makeConstraints {
            $0.top.equalTo(writeWeekStack.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview().inset(27)
        }
    }
    
    func switchHidden(onoff: Bool) {
        self.remindSwitch.isEnabled = onoff
        self.writeSwitch.isEnabled = onoff
        self.writeSwitchBtn.isHidden = onoff
        self.remindSwitchBtn.isHidden = onoff
    }
}
