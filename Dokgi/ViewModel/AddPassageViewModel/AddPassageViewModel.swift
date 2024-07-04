//
//  AddVerseViewModel.swift
//  Dokgi
//
//  Created by 한철희 on 6/17/24.
//

import UIKit

class AddPassageViewModel {
    // MARK: - Properties
    weak var delegate: BookSelectionDelegate?
    var selectedBook: Item?
    var keywords: [String] = []
    var pageType: Bool = true
    var showUi: Bool = false
    
    // MARK: - func
    func removeEmptyKeywords() {
        keywords = keywords.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
        
    func validatePassage(passageText: String, pageNumberText: String?) -> (Bool, String) {
        if selectedBook == nil {
            return (false, "책 검색을 눌러 책 정보를 기록해주세요")
        }
        
        if passageText.isEmpty || passageText == "텍스트를 입력하세요" {
            return (false, "구절을 입력해 주세요")
        }
        
        if passageText.count > 200 {
            return (false, "구절을 200자 이하로 작성해 주세요")
        }
        
        guard let pageNumberText = pageNumberText, let pageNumber = Int(pageNumberText) else {
            return (false, "숫자를 입력하세요.")
        }
        
        if pageType == true && pageNumber <= 0 {
            return (false, "0 이상을 입력하세요.")
        } else if pageType == false && (pageNumber < 0 || pageNumber > 100) {
            return (false, "0이상 100이하를 입력하세요.")
        }
        
        return (true, "")
    }
    
    func savePassage(selectedBook: Item?, passageText: String, pageNumberText: String?, pageType: Bool, keywords: [String], completion: @escaping (Bool) -> Void) {
        guard let book = selectedBook,
              let pageNumberText = pageNumberText,
              let pageNumber = Int(pageNumberText),
              !passageText.isEmpty,
              passageText != "텍스트를 입력하세요" else {
            completion(false)
            return
        }
        
        let currentDate = Date()
        
        // Verse 인스턴스 생성
        let passage = Passage(title: book.title, passage: passageText, page: pageNumber, pageType: pageType, date: currentDate, keywords: keywords)
        
        CoreDataManager.shared.saveData(author: book.formattedAuthor, image: book.image, passage: passage)
        completion(true)
    }
    
    func updateCharacterCountText(for text: String?, label: UILabel) {
        let count = text?.count ?? 0
        let currentCount = text == "텍스트를 입력하세요" ? 0 : count
        label.text = "\(currentCount)/200"
        label.textColor = count > 200 ? .red : .textFieldGray
    }
}
