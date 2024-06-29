//
//  SyncCoreDataApp.swift
//  SyncCoreData
//
//  Created by Iury da Rocha Miguel on 28/06/24.
//

import SwiftUI

@main
struct SyncCoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: makeHolidayViewModel())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }

    private func makeHolidayViewModel() -> HolidayListViewModel {
        HolidayListViewModel(service: BackForAppService(networkClient: NetworkClient()), context: persistenceController.container.viewContext)
    }
}
