//
//  ParagraphViewModel.swift
//  Dokgi
//
//  Created by 예슬 on 6/17/24.
//

import Foundation
import RxCocoa
import RxSwift

final class PassageViewModel {
    func dataLatest() {
        let sortedData = CoreDataManager.shared.passageData.value.sorted { $0.date > $1.date }
        CoreDataManager.shared.passageData.accept(sortedData)
    }
      
      func dataOldest() {
          let sortedData = CoreDataManager.shared.passageData.value.sorted { $0.date < $1.date }
          CoreDataManager.shared.passageData.accept(sortedData)
      }
}
