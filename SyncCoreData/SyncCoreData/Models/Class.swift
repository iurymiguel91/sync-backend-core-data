//
//  Class.swift
//  SyncCoreData
//
//  Created by Iury da Rocha Miguel on 28/06/24.
//

import CoreData
import Foundation

class NSManagedObjectEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}

protocol Class: Identifiable, Decodable {
    var id: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }

    associatedtype Entity: NSManagedObjectEntity
    static func fetchRequest() -> NSFetchRequest<Entity>
}

extension Class {
    static var name: String {
        String(describing: self)
    }

    static func fetchRequest() -> NSFetchRequest<Entity> {
        NSFetchRequest<Entity>(entityName: name)
    }
}
