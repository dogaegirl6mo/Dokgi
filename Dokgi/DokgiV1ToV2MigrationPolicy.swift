//
//  DokgiV1ToV2MigrationPolicy.swift
//  Dokgi
//
//  Created by 송정훈 on 6/21/24.
//

import Foundation
import CoreData

class DokgiV1ToV2MigrationPolicy: NSEntityMigrationPolicy {
    // Create the Book instance in the destination context
    static var bookCache = [String: NSManagedObject]()
    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        // BookEntity 생성
        let bookTitle = sInstance.value(forKey: "name") as? String ?? ""
        let bookAuthor = sInstance.value(forKey: "author") as? String ?? ""
        
        var bookEntity: NSManagedObject
        
        if let cachedBook = DokgiV1ToV2MigrationPolicy.bookCache[bookTitle + bookAuthor] {
            bookEntity = cachedBook
        } else {
            bookEntity = NSEntityDescription.insertNewObject(forEntityName: "BookEntity", into: manager.destinationContext)
            bookEntity.setValue(sInstance.value(forKey: "name"), forKey: "title")
            bookEntity.setValue(sInstance.value(forKey: "author"), forKey: "author")
            bookEntity.setValue(sInstance.value(forKey: "image"), forKey: "image")
            
            DokgiV1ToV2MigrationPolicy.bookCache[bookTitle + bookAuthor] = bookEntity
        }
        
        let passageEntity = NSEntityDescription.insertNewObject(forEntityName: "PassageEntity", into: manager.destinationContext)
        passageEntity.setValue(sInstance.value(forKey: "text"), forKey: "passage")
        passageEntity.setValue(sInstance.value(forKey: "date"), forKey: "date")
        passageEntity.setValue(sInstance.value(forKey: "pageNum"), forKey: "page")
        passageEntity.setValue(sInstance.value(forKey: "pageType"), forKey: "pageType")
        passageEntity.setValue(sInstance.value(forKey: "keywords"), forKey: "keywords")
        passageEntity.setValue(bookEntity, forKey: "book")
        
        if let passages = bookEntity.value(forKey: "passages") as? NSMutableSet {
            passages.add(passageEntity)
        } else {
            bookEntity.setValue(NSMutableSet(object: passageEntity), forKey: "passages")
        }
        
        // Associate the source and destination instances
        manager.associate(sourceInstance: sInstance, withDestinationInstance: passageEntity, for: mapping)
    }
}
