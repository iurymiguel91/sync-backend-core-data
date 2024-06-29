//
//  DateFormatterHelper.swift
//  SyncCoreData
//
//  Created by Iury da Rocha Miguel on 28/06/24.
//

import Foundation

enum DateFormatterHelper {
    private static let formatter = DateFormatter()
    private static let defaultFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    static func formatToString(
        from date: Date,
        format: String,
        timeZone: TimeZone? = TimeZone(identifier: "GMT")
    ) -> String {
        formatter.dateFormat = format
        formatter.timeZone = timeZone
        return formatter.string(from: date)
    }

    static func formatToDate(
        from dateString: String,
        format: String = DateFormatterHelper.defaultFormat
    ) -> Date? {
        formatter.dateFormat = format
        return formatter.date(from: dateString)
    }
}
