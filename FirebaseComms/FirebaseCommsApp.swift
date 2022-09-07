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

class Theme {
    static func navigationBarColors(background : UIColor?,
       titleColor : UIColor? = nil, tintColor : UIColor? = nil ){
        
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = background ?? .clear
        
        navigationAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .black]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .black]
       
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance

        UINavigationBar.appearance().tintColor = tintColor ?? titleColor ?? .black
        
        UISegmentedControl.appearance().selectedSegmentTintColor = tintColor
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: titleColor!], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: titleColor!], for: .normal)
//        UISegmentedControl.appearance().
        
        UITextField.appearance().textColor = titleColor
        UITextView.appearance().backgroundColor = .clear
//        UIDatePicker.appearance().tintColor = titleColor
//        UIDatePicker.appearance().backgroundColor = background
//        UIDatePicker.appearance().isOpaque = false

    }
}

@main
struct FirebaseCommsApp: App {
    @AppStorage("view_Id") var view_Id = 0
    @AppStorage("darkmode") var darkmode: Bool = false
//    @AppStorage("log_Status") var log_Status = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    view_Id = 0
                    Theme.navigationBarColors(background: UIColor(Color.theme.background), titleColor: UIColor(Color.theme.foreground), tintColor: UIColor(Color.theme.accent))
                })
                .preferredColorScheme(darkmode ? .dark : .light)
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
