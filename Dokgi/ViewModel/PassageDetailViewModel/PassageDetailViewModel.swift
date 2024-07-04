//
//  ParagraphDetailViewModel.swift
//  Dokgi
//
//  Created by 송정훈 on 6/12/24.
//

import Foundation
import RxCocoa
import RxSwift

protocol DetailViewDismiss {
    func dataSort()
}

class PassageDetailViewModel {

    var detailPassage = BehaviorRelay<Passage>(value: Passage(title: "", passage: "", page: 0, pageType: true, date: Date(), keywords: []))
    var keywords = BehaviorRelay<[String]>(value: [])
    var delegate : DetailViewDismiss?
    func deleteDetailKeyword(keyword: Int) {
        var tmp = self.keywords.value
        if tmp.isEmpty == false {
            tmp.remove(at: keyword)
        }
        keywords.accept(tmp)
    }
    
    func updateDetailKeyword(keyword: String) {
        var keywordTmp = self.keywords.value
        if keywordTmp.isEmpty == false && keyword != "" {
            if keywordTmp.count <= 10 {
                keywordTmp[0] = keyword
            }
        }
        keywords.accept(keywordTmp)
    }
    
    func addDetailKeyword(keyword: String) {
        var keywordTmp = self.keywords.value
        if keywordTmp.count < 10 {
            keywordTmp.insert(keyword, at: 0)
        }
        keywords.accept(keywordTmp)
    }
    
    func saveDetail(paragraph: String, page: String, pageType: Int) {
        var verse = self.detailPassage.value
        if let savedVerses = UserDefaults.standard.array(forKey: UserDefaultsKeys.shuffledPassage.rawValue) as? [String] {
              UserDefaults.standard.set(savedVerses.map{ $0 == verse.passage ? paragraph : $0}, forKey: UserDefaultsKeys.shuffledPassage.rawValue)
            }
        verse.passage = paragraph
        verse.keywords = keywords.value.filter{ $0 != "" }
        verse.pageType = pageType == 0 ? true : false
        verse.page = (pageType == 0 ? Int(page.page()) : Int(page.percent()))!
        detailPassage.accept(verse)
        CoreDataManager.shared.updateData(passage: self.detailPassage.value)
        delegate?.dataSort()
    }
}
