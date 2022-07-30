//
//  ContentView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/6/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_Status") var log_Status = false
    @AppStorage("view_Id") var view_Id = 0
    var body: some View {
        if log_Status{
            VStack {
                if view_Id == 0 {
                    BroadcastsView()//.transition(.slide)
                } else if view_Id == 1 {
                    SettingsView()//.transition(.slide)
                } else if view_Id == 2 {
                    NewBroadcastView()//.transition(.slide)
                }
                
                Picker(selection: $view_Id, label: Text("Picker here")) {
                    Image(systemName: "plus.circle.fill")
                        .tag(2)
                    Image(systemName: "megaphone.fill")
                        .tag(0)
                    Image(systemName: "gear")
                        .tag(1)
                }.pickerStyle(SegmentedPickerStyle())
            }
        } else{
            LoginView()
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

