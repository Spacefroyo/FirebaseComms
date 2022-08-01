//
//  FirebaseCommsApp.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/6/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn

@main
struct FirebaseCommsApp: App {
    @AppStorage("view_Id") var view_Id = 0
//    @AppStorage("log_Status") var log_Status = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {view_Id = 0})
        }
    }
//    var displayEvent: Bool = true
//    var body: some Scene {
//        WindowGroup {
//        if displayEvent {
//                ExpandedBroadcastView(broadcast: Broadcast(data: ["name": "testEvent", "id": -1, "uid": "DNE", "timestamp": Timestamp(), "description": "testEvent description goes something like this. blah blah blah blah blah", "startDate": Date(), "endDate": Date(), "location": "testLocation"]))
//            } else {
//                ExpandedBroadcastView(broadcast: Broadcast(data: ["name": "testAnnouncement goes something like this. blah blah blah blah blah", "id": -1, "uid": "DNE", "timestamp": Timestamp()]))
//            }
//        }
//    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
