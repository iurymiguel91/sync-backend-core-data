//
//  HolidayListViewModel.swift
//  SyncCoreData
//
//  Created by Iury da Rocha Miguel on 28/06/24.
//

import CoreData

final class HolidayListViewModel {
    private let service: BackForAppServiceProtocol
    private let context: NSManagedObjectContext

    init(service: BackForAppServiceProtocol, context: NSManagedObjectContext) {
        self.service = service
        self.context = context
    }

    func getHolidays() async throws {
        let holidays = try await service.getAllRecords(ofType: Holiday.self, updatedAfterDate: nil)
        print(holidays)
    }
}
