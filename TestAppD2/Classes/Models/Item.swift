//
//  Item.swift
//  TestAppD2
//
//  Created by Sergei Popyvanov on 18.02.2021.
//  Copyright © 2021 Григорий Соловьев. All rights reserved.
//

import Foundation

/// Модель вопроса
struct Item: Decodable {
    let owner: Owner?
    let answer_count: Int?
    let question_id: Int?
    let last_activity_date: Int?
    let title: String?
    var smartDateFormat: String? {
        return Item.timeAgoString(from: Date.init(timeIntervalSince1970: TimeInterval(exactly: self.last_activity_date!)!) ?? Date())
    }
    
    static func timeAgoString(from date: Date?) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        let now = Date()
        let calendar = Calendar.current
        var components: DateComponents
        if let aDate = date {
            components = calendar.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute, .second], from: aDate, to: now)
            if components.year! > 0 {
                formatter.allowedUnits = NSCalendar.Unit.year
            } else if components.month! > 0 {
                formatter.allowedUnits = .month
            } else if components.weekOfMonth! > 0 {
                formatter.allowedUnits = .weekOfMonth
            } else if components.day! > 0 {
                formatter.allowedUnits = .day
            } else if components.hour! > 0 {
                formatter.allowedUnits = .hour
            } else if components.minute! > 0 {
                formatter.allowedUnits = .minute
            } else {
                formatter.allowedUnits = .second
            }
            return "  \(formatter.string(from: components) ?? "") ago"
        }
        return ""
    }
}
