//
//  Withable.swift
//  SyncCoreData
//
//  Created by Iury da Rocha Miguel on 30/06/24.
//

import Foundation

protocol Withable {}

extension Withable {
    func with(_ completion: (Self) -> Void) -> Self {
        completion(self)
        return self
    }
}

extension NSObject: Withable {}
