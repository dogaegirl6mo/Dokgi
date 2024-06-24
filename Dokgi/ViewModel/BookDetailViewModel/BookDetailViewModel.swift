//
//  BookDetailViewModel.swift
//  Dokgi
//
//  Created by 예슬 on 6/13/24.
//

import Foundation
import RxCocoa

class BookDetailViewModel {
    
    var bookInfo = BehaviorRelay(value: Verse(name: "", author: "", image: "", text: "", pageNumber: 0, pageType: "", keywords: [], date: Date()))
    var passagesData = BehaviorRelay(value: [Passage(text: "", pageType: "", pageNumber: 0)])
    
    func makePassageDataOfBook() {
        let sameTitleBook =  CoreDataManager.shared.bookData.value.filter { $0.name == bookInfo.value.name }
        passagesData.accept(sameTitleBook.map { book in
            Passage(text: book.text, pageType: book.pageType, pageNumber: book.pageNumber)
        })
    }
    
    func pageTypeToP(_ pageType: String) -> String {
        return (pageType.lowercased() == "page") ? "P" : pageType
    }
    
    func makeAddVerseViewData() -> Item {
        return Item(title: bookInfo.value.name, image: bookInfo.value.image, author: bookInfo.value.author)
    }
}

struct Passage {
    var text: String
    var pageType: String
    var pageNumber: Int
}
