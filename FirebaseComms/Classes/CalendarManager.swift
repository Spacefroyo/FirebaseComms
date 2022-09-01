//
//  FirebaseManager.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/10/22.
//

import EventKit
import EventKitUI
import SwiftUI
import UIKit

class CalendarManager: NSObject, EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
//        ebv.expandCalendarManager = false
    }
    
    let eventStore = EKEventStore()
    var broadcast: Broadcast
//    var ebv: ExpandedBroadcastView
    var eventController: EKEventEditViewController = EKEventEditViewController()
    
    init(broadcast: Broadcast) {
        self.broadcast = broadcast
//        self.ebv = ebv
    }
    
//    func addEvent() {
//        eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
//                    DispatchQueue.main.async {
//                        if (granted) && (error == nil) {
//                            let eventData = self.broadcast.data
//                            let event = EKEvent(eventStore: self.eventStore)
//                            event.title = eventData["name"] as? String ?? ""
//                            event.startDate = eventData["startDate"] as? Date ?? Date()
//                            event.url = eventData["location"] as? URL
//                            event.location = eventData["location"] as? String ?? ""
//                            event.endDate = eventData["endDate"] as? Date ?? Date()
//                            let eventController = EKEventEditViewController()
//                            eventController.event = event
//                            eventController.eventStore = self.eventStore
//                            eventController.editViewDelegate = self
//                            self.eventController = eventController
//
////                            self.present(eventController, animated: true, completion: nil)
//
//                        }
//                    }
//                })
//    }
    
    func addEvent() {
            
            eventStore.requestAccess(to: .event) { (success, error) in
                if  error == nil {
                    let eventData = self.broadcast.data
                    let event = EKEvent.init(eventStore: self.eventStore)
                    event.title = eventData["name"] as? String ?? ""
                    event.calendar = self.eventStore.defaultCalendarForNewEvents // this will return deafult calendar from device calendars
                    event.startDate = eventData["startDate"] as? Date ?? Date()
                    event.endDate = eventData["endDate"] as? Date ?? Date()
                    event.url = eventData["location"] as? URL
                    event.location = eventData["location"] as? String ?? ""
                    
                    let alarm = EKAlarm.init(absoluteDate: Date.init(timeInterval: -3600, since: event.startDate))
                    event.addAlarm(alarm)
                    
                    do {
                        try self.eventStore.save(event, span: .thisEvent)
                        //event created successfullt to default calendar
                    } catch let error as NSError {
                        print("failed to save event with error : \(error)")
                    }

                } else {
                    //we have error in getting access to device calnedar
                    print("error = \(String(describing: error?.localizedDescription))")
                }
            }
        }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
//                    DispatchQueue.main.async {
//                        if (granted) && (error == nil) {
//                            let eventData = self.broadcast.data
//                            let event = EKEvent(eventStore: self.eventStore)
//                            event.title = eventData["name"] as? String ?? ""
//                            event.startDate = eventData["startDate"] as? Date ?? Date()
//                            event.url = eventData["location"] as? URL
//                            event.location = eventData["location"] as? String ?? ""
//                            event.endDate = eventData["endDate"] as? Date ?? Date()
//                            let eventController = EKEventEditViewController()
//                            eventController.event = event
//                            eventController.eventStore = self.eventStore
//                            eventController.editViewDelegate = self
//                            self.present(eventController, animated: true, completion: nil)
//
//                        }
//                    }
//                })
//    }
}
