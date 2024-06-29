//
//  Holiday.swift
//  SyncCoreData
//
//  Created by Iury da Rocha Miguel on 28/06/24.
//

import CoreData
import Foundation

struct Holiday: Class {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let name: String
    let wikipediaLink: String
    let details: String
    let date: Date
    let observedBy: [String]

    enum CodingKeys: String, CodingKey {
        case id = "objectId"
        case createdAt
        case updatedAt
        case name
        case wikipediaLink
        case details
        case date
        case observedBy
    }

    enum DateCodingKeys: String, CodingKey {
        case iso
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        name = try container.decode(String.self, forKey: .name)
        wikipediaLink = try container.decode(String.self, forKey: .wikipediaLink)
        details = try container.decode(String.self, forKey: .details)
        observedBy = try container.decode([String].self, forKey: .observedBy)
        let dateContainer = try container.nestedContainer(keyedBy: DateCodingKeys.self, forKey: .date)
        date = try dateContainer.decode(Date.self, forKey: .iso)
    }
}

extension Holiday {
    @objc(Holiday)
    public final class Entity: NSManagedObjectEntity {
        @NSManaged public var name: String?
        @NSManaged public var wikipediaLink: String?
        @NSManaged public var details: String?
        @NSManaged public var date: Date?
        @NSManaged public var observedBy: NSObject?
    }

    init(entity: Holiday.Entity) {
        self.id = entity.id ?? UUID().uuidString
        self.createdAt = entity.createdAt ?? Date()
        self.updatedAt = entity.updatedAt ?? Date()
        self.name = entity.name ?? ""
        self.wikipediaLink = entity.wikipediaLink ?? ""
        self.details = entity.details ?? ""
        self.date = entity.date ?? Date()
        self.observedBy = entity.observedBy as? [String] ?? []
    }

    @discardableResult
    func toEntity(context: NSManagedObjectContext) -> Holiday.Entity {
        let entity = Holiday.Entity(context: context)
        entity.id = self.id
        entity.createdAt = self.createdAt
        entity.updatedAt = self.updatedAt
        entity.name = self.name
        entity.wikipediaLink = self.wikipediaLink
        entity.details = self.details
        entity.date = self.date
        entity.observedBy = self.observedBy as NSObject
        return entity
    }
}
