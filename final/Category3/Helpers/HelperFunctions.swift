//
//  HelperFunctions.swift
//  final
//
//  Created by Sara Khalaf on 05/12/2024.
//

import Foundation


func dateComponentsToDate(_ dateComponents: DateComponents) -> Date? {
    guard let _ = dateComponents.year,
          let _ = dateComponents.month,
          let _ = dateComponents.day
    else {return nil}
    let calendar = Calendar.current
    let date = calendar.date(from: dateComponents)
    return date
}


func dateComponentsToTime(_ dateComponents: DateComponents) -> String? {
    guard let _ = dateComponents.hour,
          let _ = dateComponents.minute
    else {return nil}
    let calendar = Calendar.current
    let date = calendar.date(from: dateComponents)
    return date?.formatted(date: Date.FormatStyle.DateStyle.omitted, time: Date.FormatStyle.TimeStyle.shortened)
    
}
