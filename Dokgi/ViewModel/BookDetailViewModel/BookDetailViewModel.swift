//
//  BookDetailViewModel.swift
//  Dokgi
//
//  Created by 예슬 on 6/13/24.
//

import Foundation
import RxCocoa

class BookDetailViewModel {
    
    var bookInfo = BehaviorRelay(value: Book(title: "", author: "", image: "", passages: []))
    
    func setFirstRecordDate() -> String {
        let sortedPassages = bookInfo.value.passages.sorted(by: { $0.date < $1.date })
        return sortedPassages.first?.date.toString() ?? ""
    }
    
    func pageTypeToString(_ pageType: Bool) -> String {
        return pageType ? "P" : "%"
    }
    
    func makeAddVerseViewData() -> Item {
        return Item(title: bookInfo.value.title, image: bookInfo.value.image, author: bookInfo.value.author)
    }
}
