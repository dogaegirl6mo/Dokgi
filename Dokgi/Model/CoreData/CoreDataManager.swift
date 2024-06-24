//
//  CoreDataManager.swift
//  Dokgi
//
//  Created by 송정훈 on 6/10/24.
//
import CoreData
import RxCocoa
import RxSwift
import UIKit
import WidgetKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    var bookData = BehaviorRelay<[Book]>(value: [])
    var passageData = BehaviorRelay<[Passage]>(value: [])
    
    var persistent: NSPersistentContainer? = {
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.dogaegeol6mo.Dokgi")!.appendingPathComponent("Dokgi.sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        let container = NSPersistentContainer(name: "Dokgi")
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveData(author: String, image: String, passage: Passage) {
        guard let context = self.persistent?.viewContext else { return }

        do {
            let newPassage = PassageEntity(context: context)
            newPassage.book?.title = passage.title
            newPassage.book?.author = author
            newPassage.book?.image = image
            newPassage.passage = passage.passage
            newPassage.page = Int32(passage.page)
            newPassage.pageType = passage.pageType
            newPassage.date = passage.date
            newPassage.keywords = passage.keywords
            try context.save()
//            WidgetCenter.shared.reloadTimelines(ofKind: "DokgiWidget")
        } catch {
            print("Failed to fetch or save data: \(error)")
        }
        readBook()
        CoreDataManager.shared.passageData.accept(CoreDataManager.shared.passageData.value + [passage])
    }
    
    //text는 검색 그냥일때는 ""
    func readBook(text: String = "") {
        guard let context = self.persistent?.viewContext else { return }
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        if text.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS[c] %@", text)
        }
        
        do {
            let books = try context.fetch(fetchRequest)
            var bookArr = [Book]()
            for book in books {
                bookArr.append(Book(title: book.title!, author: book.author!, image: book.author!, passages: (book.passages?.array as? [Passage])!))
            }
            bookData.accept(bookArr)
        } catch {
            print("Failed to fetch or read data: \(error)")
        }
    }
    
    //text는 검색 그냥일때는 ""
    func readPassage(text: String = "") {
        guard let context = self.persistent?.viewContext else { return }
        let fetchRequest: NSFetchRequest<PassageEntity> = PassageEntity.fetchRequest()
        if text.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "passage CONTAINS[c] %@", text)
        }
        
        do {
            let passages = try context.fetch(fetchRequest)
            var passageArr = [Passage]()
            for passage in passages {
                passageArr.append(Passage(title: passage.book?.title, passage: passage.passage!, page: Int(passage.page), pageType: passage.pageType, date: passage.date!, keywords: passage.keywords!))
            }
            passageData.accept(passageArr)
        } catch {
            print("Failed to fetch or read data: \(error)")
        }
    }
    
    func deleteData(passage: Passage) {
        guard let context = self.persistent?.viewContext else { return }
        let fetchRequest: NSFetchRequest<PassageEntity> = PassageEntity.fetchRequest()
        let titlePredicate = NSPredicate(format: "book.title == %@", passage.title!)
        let datePredicate = NSPredicate(format: "date == %@", passage.date as NSDate)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [titlePredicate, datePredicate])

        do {
            let passages = try context.fetch(fetchRequest)
            if let passageEntity = passages.first {
                if passageEntity.book?.passages?.count == 1 {
                    let bookRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
                    let bookTitlePredicate = NSPredicate(format: "title == %@", (passageEntity.book?.title)!)
                    let authorPredicate = NSPredicate(format: "author == %@", passageEntity.book!.author!)
                    bookRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [bookTitlePredicate, authorPredicate])
                    let books = try context.fetch(bookRequest)
                    if let bookEntity = books.first {
                        context.delete(bookEntity)
                        try context.save()
                    }
                } else {
                    context.delete(passageEntity)
                    try context.save()
                }
            }
        } catch {
            print("Failed to fetch or delete data: \(error)")
        }
    }
    
    func updateData(passage: Passage) {
        guard let context = self.persistent?.viewContext else { return }
        let fetchRequest: NSFetchRequest<PassageEntity> = PassageEntity.fetchRequest()
        let titlePredicate = NSPredicate(format: "name == %@", passage.title!)
        let datePredicate = NSPredicate(format: "date == %@", passage.date as NSDate)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [titlePredicate, datePredicate])

        do {
            let passages = try context.fetch(fetchRequest)
            if passages.first != nil {
                let passageEntity = passages.first
                passageEntity?.passage = passage.passage
                passageEntity?.keywords = passage.keywords
                passageEntity?.page = Int32(passage.page)
                passageEntity?.pageType = passage.pageType
            }
        } catch {
            print("Failed to fetch or update data: \(error)")
        }
    }
}
