//
//  utils.swift
//  FirebaseComms
//
//  Created by Peter Gao on 8/6/22.
//

import Foundation
import FirebaseFirestore
import SwiftUI

struct utils {
    static func timeSince(timestamp: Timestamp) -> String {
        let diff = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: timestamp.dateValue(), to: Timestamp().dateValue())
        if diff.year ?? 0 > 0 {
            return "\(diff.year ?? 0)y"
        } else if diff.month ?? 0 > 0 {
            return "\(diff.month ?? 0)mon"
        } else if diff.day ?? 0 > 0 {
            return "\(diff.day ?? 0)d"
        } else if diff.hour ?? 0 > 0 {
            return "\(diff.hour ?? 0)h"
        } else {
            return "\(diff.minute ?? 0)min"
        }
    }
    static let dateFormatters: [String: DateFormatter] = ["mdy": DateFormatter().setFormat(), "mdytz": DateFormatter().setFormat(dateFormat:"MMM dd, yyyy, HH:mm z")]
    static func getDateFormat(format: String) -> DateFormatter {
        return dateFormatters[format, default: DateFormatter().setFormat()]
    }

    static func broadcastType(broadcast: Broadcast) -> String {
        if (broadcast.data.count == 5) {
            return "announcement"
        } else {
            return "event"
        }
    }
    
    static func stringsInOrder(a: [Any??], b: [Any??]) -> Bool {
        for i in 0...a.count-1 {
            if (a[i] as? String ?? "").compare(b[i] as? String ?? "") != .orderedSame {
                return (a[i] as? String ?? "").compare(b[i] as? String ?? "") == .orderedAscending
            }
        }
        return true
    }
}

extension DateFormatter {
    func setFormat(locale: String = "en_US", dateFormat: String = "MMM dd, yyyy") -> DateFormatter {
        self.locale = Locale(identifier: locale)
        self.dateFormat = dateFormat
        return self
    }
}
