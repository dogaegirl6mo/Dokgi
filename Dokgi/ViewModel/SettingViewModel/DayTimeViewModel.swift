//
//  DayTimeViewModel.swift
//  Dokgi
//
//  Created by 송정훈 on 6/5/24.
//

import Foundation
import RxSwift
import RxCocoa
import NotificationCenter

class DayTimeViewModel {
    
    static var dayCheck = BehaviorRelay<[Int]>(value: UserDefaults.standard.array(forKey: "writeWeek") as? [Int] ?? [1, 1, 1, 1, 1, 1, 1])
    static var remindTime = BehaviorRelay<[Int]>(value: UserDefaults.standard.array(forKey: "remindTime") as? [Int] ?? [3, 00, 1])
    static var writeTime = BehaviorRelay<[Int]>(value: UserDefaults.standard.array(forKey: "writeTime") as? [Int] ?? [3, 00, 1])
    
    let hourArr = [Int](1...12)
    let minArr = [Int](00...59).map { String($0).count == 1 ? "0\($0)" : "\($0)" }
    let ampmArr = ["AM", "PM"]
    let DayArr = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
    var selectday = [Int](1...7)
    var selectTime : [Int] = [3, 00, 1]
    
    func setTime(row: Int , component: Int) {
        switch component {
        case 0:
            selectTime[0] = hourArr[row % hourArr.count]
        case 1:
            selectTime[1] = Int(minArr[row % minArr.count])!
        case 2:
            selectTime[2] = row % ampmArr.count
        default:
            print(0)
        }
    }
    
    func saveTime(write: Bool) {
        if write == true {
            DayTimeViewModel.writeTime.accept(selectTime)
        } else {
            DayTimeViewModel.remindTime.accept(selectTime)
        }
    }
    
    func dayimage(row: Int) {
        if self.selectday[row] != 0 {
            self.selectday[row] = 0
        } else {
            self.selectday[row] = 1
        }
    }
    
    func sendLocalPushRemind(identifier: String, time: [Int]) {
        let gujur : [String] = CoreDataManager.shared.passageData.value.count == 0 ? ["누군가를 있는 그대로 존중한다는 것은 그만큼 어려운 일이다.", "본질을 아는 것보다, 본질을 알기 위해 있는 그대로를 보기 위해 노력하는 것이 중요하다고, 그것이 바로 그 대상에 대한 존중이라고."] : CoreDataManager.shared.passageData.value.map { $0.passage }
        UserDefaults.standard.set(time, forKey: UserDefaultsKeys.remindTime.rawValue)
        for i in 1...31 {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "오늘의 구절", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: gujur.randomElement() ?? "", arguments: nil)
            content.sound = UNNotificationSound.default
            
            var dateInfo = DateComponents()
            dateInfo.calendar = Calendar.current
            dateInfo.hour = time[2] == 1 ? time[0] + 12 : time[0]
            dateInfo.minute = time[1]
            dateInfo.day = i
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
            let request = UNNotificationRequest(identifier: "\(identifier)_\(i)", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            
            center.add(request) { (error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    func sendLocalPushWrite(identifier: String, time: [Int], day: [Int]) {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "오늘 독서 어때요?", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "독서를 하고 마음에 드는 구절을 기록해봐요!", arguments: nil)
        content.sound = UNNotificationSound.default
        UserDefaults.standard.set(day, forKey: UserDefaultsKeys.writeWeek.rawValue)
        UserDefaults.standard.set(time, forKey: UserDefaultsKeys.writeTime.rawValue)
        for i in 0...6 {
            if day[i] == 0 {
                UNUserNotificationCenter
                        .current()
                        .removePendingNotificationRequests(withIdentifiers: ["\(identifier)_\(i)"])
            }
            var dateInfo = DateComponents()
            dateInfo.calendar = Calendar.current
            dateInfo.hour = time[2] == 1 ? time[0] + 12 : time[0]
            dateInfo.minute = time[1]
            dateInfo.weekday = i + 1
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
            let request = UNNotificationRequest(identifier: "\(identifier)_\(i)", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            
            center.add(request) { (error) in
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    func removePendingNotification(identifiers: String, time: [Int], on: Bool ) {
        if on == true {
            if identifiers == "remindTime" {
                UserDefaults.standard.set(on, forKey: UserDefaultsKeys.remindSwitch.rawValue)
                self.sendLocalPushRemind(identifier: identifiers, time: time)
            } else {
                UserDefaults.standard.set(on, forKey: UserDefaultsKeys.writeSwitch.rawValue)
                self.sendLocalPushWrite(identifier: identifiers, time: time, day: DayTimeViewModel.dayCheck.value)
            }
        } else {
            if identifiers == "remindTime" {
                UserDefaults.standard.set(on, forKey: UserDefaultsKeys.remindSwitch.rawValue)
                for i in 0...6 {
                    UNUserNotificationCenter
                            .current()
                            .removePendingNotificationRequests(withIdentifiers: ["\(identifiers)_\(i)"])
                }
            } else {
                for i in 0...6 {
                    UserDefaults.standard.set(on, forKey: UserDefaultsKeys.writeSwitch.rawValue)
                    if DayTimeViewModel.dayCheck.value[i] == 1 {
                        UNUserNotificationCenter
                            .current()
                            .removePendingNotificationRequests(withIdentifiers: ["\(identifiers)_\(i)"])
                    }
                }
            }
        }
    }
}
