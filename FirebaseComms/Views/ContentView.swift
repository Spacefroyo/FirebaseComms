//
//  ContentView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/6/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_Status") var log_Status = true
    @AppStorage("view_Id") var view_Id = 0
//    @State var expand = true
    var body: some View {
        if log_Status{
            //check whether or not email matches uid, set log_Status to false if not
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                VStack {
                    switch view_Id {
                    case 0:
                        BroadcastsView()
                    case 1:
                        SettingsView()
                    case 2:
                        NewBroadcastView()
                    case 3:
                        FollowsView()
                    default:
                        TestView()
                    }
                    
                    Picker(selection: $view_Id, label: Text("Picker here")) {
                        Image(systemName: "quote.bubble.fill")
                            .tag(3)
                        Image(systemName: "plus.circle.fill")
                            .tag(2)
                        Image(systemName: "megaphone.fill")
                            .tag(0)
                        Image(systemName: "gear")
                            .tag(1)
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
        } else{
            LoginView()
        }
    }
    
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

