//
//  SettingViewController.swift
//  Dokgi
//
//  Created by 송정훈 on 6/4/24.
//

import NotificationCenter
import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

class SettingViewController: UIViewController{
    let disposeBag = DisposeBag()
    let alarmView = AlarmView()
    let viewModel = DayTimeViewModel()
    let titleLbl = UILabel().then {
        $0.text = "설정"
        $0.font = Pretendard.bold.dynamicFont(style: .title2)
        $0.textColor = .black
    }
    
    let backButton = BackButton()
    
    //MARK: - lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        dataBind()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        NotificationCenter.default.addObserver(self, selector: #selector(checkNotificationSetting), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.alarmView.switchHidden(onoff: UserDefaults.standard.bool(forKey: UserDefaultsKeys.notification.rawValue))
    }
    
    // MARK: - Layout
    func setupLayout() {
        view.addSubview(titleLbl)
        view.addSubview(alarmView)
        
        titleLbl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(20)
        }
        
        alarmView.snp.makeConstraints {
            $0.top.equalTo(titleLbl.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        alarmView.remindSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.remindSwitch.rawValue)
        alarmView.writeSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.writeSwitch.rawValue)
    }
    
    func dataBind() {
        backButton.rx.tap.subscribe(with: self) { (self, _) in
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        alarmView.remindTimeBtn.rx.tap.subscribe { _ in
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.remindSwitch.rawValue) == true {
                let remindVC = TimePickerViewController()
                remindVC.writeBool = false
                self.present(remindVC, animated: true)
            }
        }.disposed(by: disposeBag)
        
        alarmView.weekBtn.rx.tap.subscribe { _ in
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.writeSwitch.rawValue) == true {
                self.present(DaySelectViewController(), animated: true)
            }
        }.disposed(by: disposeBag)
        
        alarmView.writeTimeBtn.rx.tap.subscribe { _ in
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.writeSwitch.rawValue) == true {
                let writeVC = TimePickerViewController()
                writeVC.writeBool = true
                self.present(writeVC, animated: true)
            }
        }.disposed(by: disposeBag)
        
        DayTimeViewModel.remindTime.subscribe(with: self) { (self, Time) in
            self.updateButtonTitleAndSendNotification(button: self.alarmView.remindTimeBtn, title: Time.timeToString(), switchControl: self.alarmView.remindSwitch.isOn, identifier: "remindTime", time: Time, day: [])
        }.disposed(by: disposeBag)
        
        DayTimeViewModel.writeTime.subscribe(with: self) { (self, Time) in
            self.updateButtonTitleAndSendNotification(button: self.alarmView.writeTimeBtn, title: Time.timeToString(), switchControl: self.alarmView.writeSwitch.isOn, identifier: "writeTime", time: Time, day: DayTimeViewModel.dayCheck.value)
        }.disposed(by: disposeBag)
        
        DayTimeViewModel.dayCheck.subscribe(with: self) { (self, week) in
            self.alarmView.writeSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.writeSwitch.rawValue)
            self.updateButtonTitleAndSendNotification(button: self.alarmView.weekBtn, title: DayTimeViewModel.dayCheck.value.dayToString(), switchControl: self.alarmView.writeSwitch.isOn, identifier: "writeTime", time: DayTimeViewModel.writeTime.value, day: week)
        }.disposed(by: disposeBag)
        
        alarmView.remindSwitch.rx.isOn.subscribe(with: self) { (self, bool) in
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.notification.rawValue) == true {
                self.viewModel.removePendingNotification(identifiers: "remindTime", time: DayTimeViewModel.remindTime.value, on: bool)
            }
            if bool == false {
                self.alarmView.remindTimeStack.isHidden = true
            } else {
                self.alarmView.remindTimeStack.isHidden = false
            }
        }.disposed(by: disposeBag)
        
        alarmView.remindSwitchBtn.rx.tap.subscribe { _ in
            self.switchAlert()
        }.disposed(by: disposeBag)
        
        alarmView.writeSwitch.rx.isOn.subscribe(with: self) { (self, bool) in
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.notification.rawValue) == true {
                self.viewModel.removePendingNotification(identifiers: "writeTime", time: DayTimeViewModel.remindTime.value, on: bool)
            }
            if bool == false {
                self.alarmView.writeTimeStack.isHidden = true
                self.alarmView.writeWeekStack.isHidden = true
            } else {
                self.alarmView.writeTimeStack.isHidden = false
                self.alarmView.writeWeekStack.isHidden = false
            }
        }.disposed(by: disposeBag)
        
        alarmView.writeSwitchBtn.rx.tap.subscribe { _ in
            self.switchAlert()
        }.disposed(by: disposeBag)
    }
    
    private func updateButtonTitleAndSendNotification(button: UIButton, title: String, switchControl: Bool, identifier: String, time: [Int], day: [Int]) {
        button.setTitle(title, for: .normal)
        if switchControl == true {
            if identifier == "remindTime" {
                viewModel.sendLocalPushRemind(identifier: identifier, time: time)
            } else if identifier == "writeTime" {
                viewModel.sendLocalPushWrite(identifier: identifier, time: time, day: day)
            }
        }
    }
    
    func switchAlert() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                guard settings.authorizationStatus == .authorized else {
                    
                    let alert = UIAlertController(title: "알림", message: "기기 내 [설정]>[독기]>[알림]에서\n알림을 허용해주세요.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
                    
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                            
                            let settingUrl = NSURL(string: UIApplication.openSettingsURLString)!
                            
                            if UIApplication.shared.canOpenURL(settingUrl as URL) {
                                
                                
                                UIApplication.shared.open(settingUrl as URL, options: self.convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { istrue in })
                            }
                    }))
                    self.present(alert, animated: true)
                    return
                }
            }
        }
    }
    
    func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {

        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)
        })
    }
    
    @objc func checkNotificationSetting() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notification.rawValue)
                    self.alarmView.switchHidden(onoff: true)
                } else if settings.authorizationStatus == .denied {
                    UserDefaults.standard.set(false, forKey: UserDefaultsKeys.notification.rawValue)
                    UserDefaults.standard.set(false, forKey: UserDefaultsKeys.writeSwitch.rawValue)
                    UserDefaults.standard.set(false, forKey: UserDefaultsKeys.remindSwitch.rawValue)
                    self.alarmView.switchHidden(onoff: false)
                }
            }
        }
    }
}
