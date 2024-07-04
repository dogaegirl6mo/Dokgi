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

class CoreDataManager {
    static let shared = CoreDataManager()
    
    var bookData = BehaviorRelay<[Book]>(value: [])
    var passageData = BehaviorRelay<[Passage]>(value: [])
    
    var persistent: NSPersistentCloudKitContainer? = {
        let container = NSPersistentCloudKitContainer(name: "Dokgi")
        
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.dogaegeol6mo.Dokgi")!.appendingPathComponent("Dokgi.sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.dogaegeol6mo.Dokgi")
        
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        do {
              try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
             fatalError("Failed to pin viewContext to the current generation:\(error)")
        }
        
        return container
    }()
    
    func saveData(author: String, image: String, passage: Passage) {
        guard let context = self.persistent?.viewContext else { return }
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        let titlePredicate = NSPredicate(format: "title == %@", passage.title!)
        let authorPredicate = NSPredicate(format: "author == %@", author)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [titlePredicate, authorPredicate])
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
            
            let books = try context.fetch(fetchRequest)
            if books.isEmpty == true {
                let newBook = BookEntity(context: context)
                newBook.title = passage.title
                newBook.author = author
                newBook.image = image
                newBook.addToPassages(newPassage)
                try context.save()
            } else {
                books.first?.addToPassages(newPassage)
                try context.save()
            }
//                        WidgetCenter.shared.reloadTimelines(ofKind: "DokgiWidget")
        } catch {
            print("Failed to fetch or save data: \(error)")
        }
        readBook()
        CoreDataManager.shared.passageData.accept(CoreDataManager.shared.passageData.value + [passage])
    }
    
    func saveContext () {
        let context = persistent!.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //text는 검색 그냥일때는 ""
    func readBook(text: String = "") {
        guard let context = self.persistent?.viewContext else { return }
        let fetchRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        if text != "" {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", text)
            let authorPredicate = NSPredicate(format: "author CONTAINS[c] %@", text)
            fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, authorPredicate])
        }
        
        do {
            let books = try context.fetch(fetchRequest)
            var bookArr = [Book]()
            for book in books {
                if let passagesSet = book.passages {
                    var passagesArray = [Passage]()
                    for passage in passagesSet {
                        if let passageText = (passage as AnyObject).value(forKey: "passage") as? String, let page = (passage as AnyObject).value(forKey: "page") as? Int, let pageType = (passage as AnyObject).value(forKey: "pageType") as? Bool, let date = (passage as AnyObject).value(forKey: "date") as? Date, let keywords = (passage as AnyObject).value(forKey: "keywords") as? [String] {
                            
                            let passageInstance = Passage(title: book.title, passage: passageText, page: page, pageType: pageType, date: date, keywords: keywords)
                            
                            passagesArray.append(passageInstance)
                        } else {
                            print("Failed to extract passage attributes from NSManagedObject")
                        }
                    }
                    passagesArray.sort { $0.date > $1.date }
                    // 이제 passagesArray를 사용할 수 있습니다.
                    bookArr.append(Book(title: book.title!, author: book.author!, image: book.image!, passages: passagesArray))
                }
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
            
            self.passageData.accept(passageArr)
            
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
                    let bookRequest: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
                    let bookTitlePredicate = NSPredicate(format: "title == %@", (passageEntity.book?.title)!)
                    let authorPredicate = NSPredicate(format: "author == %@", passageEntity.book!.author!)
                    bookRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [bookTitlePredicate, authorPredicate])
                    let books = try context.fetch(bookRequest)
                    if let bookEntity = books.first {
                        context.delete(passageEntity)
                        bookEntity.removeFromPassages(passageEntity)
                        try context.save()
                    }
                }
            }
        } catch {
            print("Failed to fetch or delete data: \(error)")
        }
    }
    
    func updateData(passage: Passage) {
        guard let context = self.persistent?.viewContext else { return }
        let fetchRequest: NSFetchRequest<PassageEntity> = PassageEntity.fetchRequest()
        let titlePredicate = NSPredicate(format: "book.title == %@", passage.title!)
        let datePredicate = NSPredicate(format: "date == %@", passage.date as NSDate)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [titlePredicate, datePredicate])
        
        do {
            let passages = try context.fetch(fetchRequest)
            if !passages.isEmpty {
                let passageEntity = passages.first
                passageEntity?.passage = passage.passage
                passageEntity?.keywords = passage.keywords
                passageEntity?.page = Int32(passage.page)
                passageEntity?.pageType = passage.pageType
            }
            try context.save()
        } catch {
            print("Failed to fetch or update data: \(error)")
        }
    }
}
