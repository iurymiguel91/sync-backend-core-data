//
//  SyncEngine.swift
//  SyncCoreData
//
//  Created by Iury da Rocha Miguel on 28/06/24.
//

import Foundation

final class SyncEngine {
    private var syncInProgress = false
    private let persistenceController: PersistenceController
    private let backForAppService: BackForAppServiceProtocol
    private var registeredClassesToSync = [any Class.Type]()

    init(persistenceController: PersistenceController,
         backForAppService: BackForAppServiceProtocol) {
        self.persistenceController = persistenceController
        self.backForAppService = backForAppService
    }

    func registerClassToSync<T: Class>(ofType type: T.Type) {
        if !registeredClassesToSync.contains(where: { $0 == type }) {
            registeredClassesToSync.append(type)
        }
    }

    func startSync() {
        if !syncInProgress {
            syncInProgress = true
            Task(priority: .background) {
                await downloadDataForRegisteredClasses(useUpdatedAtDate: true)
            }
        }
    }

    private func getMostRecentUpdatedAtDate<T: Class>(forType type: T.Type) async throws -> Date? {
        var date: Date?
        let request = type.fetchRequest()
        let context = persistenceController.backgroundContext
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        request.fetchLimit = 1
        try await context.perform {
            let results = try context.fetch(request)
            if let last = results.last {
                date = last.updatedAt
            }
        }
        return date
    }

    private func downloadDataForRegisteredClasses(useUpdatedAtDate: Bool) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            for registeredClass in registeredClassesToSync {
                taskGroup.addTask { [unowned self] in
                    do {
                        var mostRecentUpdatedDate: Date?
                        if useUpdatedAtDate {
                            mostRecentUpdatedDate = try await getMostRecentUpdatedAtDate(forType: registeredClass)
                        }
                        let results = try await backForAppService.getAllRecords(
                            ofType: registeredClass,
                            updatedAfterDate: mostRecentUpdatedDate
                        )
                        // Need to write JSON files to disk
                        debugPrint("Response for \(registeredClass.name): \(results)")
                    } catch {
                        debugPrint("Request for \(registeredClass.name) has failed: \(error.localizedDescription)")
                    }
                }
            }
            await taskGroup.waitForAll()
            // Need to process JSON records into Core Data
        }
    }
}
