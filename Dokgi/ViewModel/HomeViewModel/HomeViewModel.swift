//
//  HomeViewModel.swift
//  Dokgi
//
//  Created by IMHYEONJEONG on 6/5/24.
//

import RxSwift
import RxCocoa
import UIKit

class HomeViewModel {
    let disposeBag = DisposeBag()
    var levelCards: [Card] { DataManager.shared.cards }
    
    let currentLevel = BehaviorRelay<Int>(value: 1)
    let currentLevelPercent = BehaviorRelay<Double>(value: 0)
    let passages = BehaviorRelay<[Passage]>(value: [])
    let currentLevelImage = BehaviorRelay<UIImage?>(value: UIImage(named: " "))
    let randomVerses = BehaviorRelay<[String]>(value: [])
    
    let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
    
    // 구절 길이 계산
    func getVerseLength(from verses: [String]) -> Int {
        verses.reduce(0) { result, verse in result + verse.count }
    }
    
    // 현재 구절 길이 기반으로 현재 레벨 계산
    func getVerseLevel(for verseLength: Int) -> Int {
        for (index, card) in levelCards.enumerated() {
            if verseLength < card.length {
                return index + 1
            }
        }
        return 1
    }
    
    init() {
        
        passages
            .map { $0.map { $0.passage } }
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                
                // 현재 구절길이와 레벨
                let verseLength = self.getVerseLength(from: value)
                let verseLevel = self.getVerseLevel(for: verseLength)
                
                // 현재 레벨 퍼센트
                let prevLevelCardLength = verseLevel == 1 ? 0 : self.levelCards[verseLevel - 2].length
                let currentLevelCardLength = self.levelCards[verseLevel - 1].length
                let currentLevelPercent = Double(verseLength - prevLevelCardLength) / Double(currentLevelCardLength - prevLevelCardLength)
                
                // 현재, 다음레벨 이미지 적용
                let currentLevelImage = self.levelCards[max(0, verseLevel - 1)].cardImage
                
                self.currentLevel.accept(verseLevel)
                self.currentLevelPercent.accept(currentLevelPercent)
                self.currentLevelImage.accept(currentLevelImage)
            })
            .disposed(by: disposeBag)
        
        // 구절 추가 업데이트
        CoreDataManager.shared.passageData
            .subscribe(onNext: { [weak self] passages in
                DispatchQueue.main.async {
                    self?.passages.accept(passages)
                    self?.loadTodayVerses()
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Today's verese
    func loadTodayVerses() {
        let savedDate = UserDefaults.standard.string(forKey: UserDefaultsKeys.todayDate.rawValue)
        
        guard let savedVerses = UserDefaults.standard.array(forKey: UserDefaultsKeys.shuffledPassage.rawValue) as? [String] else {
            shuffleAndSaveVerses() 
            return
        }
        
        if savedVerses.count == 5 { // 5개 일 때 실행
            // 날짜에 따른 구절 업데이트
            if today != savedDate { // 5개 이고 다른 날 일때
                shuffleAndSaveVerses()
            } else { // 5개 이고 같은 날일 때
                randomVerses.accept(savedVerses)
            }
        } else { // 5개 이하 혹은 초과 일 때
            shuffleAndSaveVerses()
        }
    }
    
    func shuffleAndSaveVerses() {
        let versesCount = self.passages.value.count
        
        guard versesCount > 0 else {
            print("No verses recorded")
            return
        }
        
        let shuffledCount = min(5, versesCount)
        let shuffled = passages.value.shuffled().prefix(shuffledCount).map { $0.passage }
        
        randomVerses.accept(shuffled)
        UserDefaults.standard.set(today, forKey: UserDefaultsKeys.todayDate.rawValue)
        UserDefaults.standard.set(shuffled, forKey: UserDefaultsKeys.shuffledPassage.rawValue)
    }
}

