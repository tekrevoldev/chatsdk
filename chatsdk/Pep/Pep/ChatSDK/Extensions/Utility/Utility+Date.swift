//
//  Utility+Date.swift
//  BasicStructureUpdate
//
//  Created by Muzzamil on 15/08/2019.
//  Copyright © 2019 Muzammil. All rights reserved.
//

import Foundation
extension Utility {
    class func milliToDate(milliDate: Int64) -> Date {
        return Date(timeIntervalSince1970: (Double(milliDate) / 1000.0))
    }
    
    class func milliToDate(milliDate: Int64, format: DateFormats = DateFormats.DateTime) -> String {
        let date = Date(timeIntervalSince1970: (Double(milliDate) / 1000.0))
        if format == .Brief {
            return timeAgoSinceDate(date)
        }
        return date.getDate(format: format)
    }
    
    class func isSameDay(dateOne: Date, dateTwo: Date) -> Bool {
        let order = Calendar.current.compare(dateOne, to: dateTwo, toGranularity: .day)
        return order == .orderedSame
    }
    
    class func timeAgoSinceDate(_ date:Date,currentDate:Date = Date(), numericDates:Bool = false) -> String {
        let calendar = Calendar.current
        let now = currentDate
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return date.getDate(format: .Date)
        } else if (components.year! >= 1){
            return date.getDate(format: .Date)
        } else if (components.month! >= 2) {
            return date.getDate(format: .Date)
        } else if (components.month! >= 1){
            return date.getDate(format: .Date)
        } else if (components.weekOfYear! >= 2) {
            return date.getDate(format: .Date)
        } else if (components.weekOfYear! >= 1){
            return date.getDate(format: .Date)
        } else if (components.day! >= 2) {
            return date.getDate(format: .Date)
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return date.getDate(format: .Time)
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "an hour ago"
            }
        } else if (components.minute! >= 2) {
            return date.getDate(format: .Time)
        }  else {
            return "Just now"
        }
        
    }
}
