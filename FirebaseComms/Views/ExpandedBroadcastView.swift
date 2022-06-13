//
//  ExpandedBroadcastView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/11/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ExpandedBroadcastView: View, Identifiable {
    let id: Int
    let broadcast: Broadcast
    @State var from: BroadcastView? = nil
    @State var expand: Bool = false
    
    
    
    var body: some View {
        
        VStack {
//            Text("\(broadcast.data["id"] as? Int ?? 0)")
            if broadcast.data.count == 4 {
                announcement
            } else {
                event
            }

            Spacer()
            
            if broadcast.data["email"] as? String ?? "" == FirebaseManager.shared.auth.currentUser?.email {
                Button {
                    expand = true
                } label: {
                    Text("Edit")
                }
            }
        }
        .fullScreenCover(isPresented: $expand) {
            Button {
                expand = false
            } label: {
                Text("< Back")
            }
            
            if broadcast.data.count == 4 {
                NewBroadcastView(isEvent: broadcast.data.count != 4, name: broadcast.data["name"] as? String ?? "", id: broadcast.data["id"] as? Int ?? -1, from: self)
            } else {
                NewBroadcastView(isEvent: broadcast.data.count != 4, name: broadcast.data["name"] as? String ?? "", description: broadcast.data["description"] as? String ?? "", startDate: (broadcast.data["startDate"] as? Timestamp ?? Timestamp()).dateValue(), endDate: (broadcast.data["endDate"] as? Timestamp ?? Timestamp()).dateValue(), location: broadcast.data["location"] as? String ?? "", id: broadcast.data["id"] as? Int ?? -1, from: self)
            }
        }
    }
    
    var announcement: some View {
        NavigationView {
            ScrollView {
                VStack (spacing: 16){
                    Text("\(broadcast.data["name"] as? String ?? "")")
    //                    .frame(height: 100, alignment: .top)
                        .padding()
                        .background(Color.white)
                    
                    Text("\((broadcast.data["timestamp"] as? Timestamp ?? Timestamp()).dateValue())")
                        .foregroundColor(Color(.lightGray))
                    
    //                Spacer()
                }
                .navigationTitle("Announcement")
            }
        }
    }
    
    var event: some View {
        NavigationView {
            ScrollView {
                VStack (alignment: .leading){
                    Group {
//                        Text("Event Name: \(broadcast.data["name"] as? String ?? "")")
                        Text("Description: \(broadcast.data["description"] as? String ?? "")")
                    }
                    .background(Color.white)
                    .padding(.top)
                    
                    HStack {
                        Text("Event Information")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.top)
                    
                    Group {
//                        Text(broadcast.data.description)
                        
                        Text("Start Date: \((broadcast.data["startDate"] as? Timestamp ?? Timestamp()).dateValue())")
                        
                        Text("End Date: \((broadcast.data["endDate"] as? Timestamp ?? Timestamp()).dateValue())")
                        
                        Text("Location: \(broadcast.data["location"] as? String ?? "")")
                        
                        Text("Attachments")
                        
                        Text("\((broadcast.data["timestamp"] as? Timestamp ?? Timestamp()).dateValue())")
                            .foregroundColor(Color(.lightGray))
                    }
                    .padding(.top)
                }
                .navigationTitle("\(broadcast.data["name"] as? String ?? "")")
            }
        }
        
    }
}

//struct ExpandedBroadcastView_Previews: PreviewProvider {
//    static var displayEvent: Bool = false
//    static var previews: some View {
//        if displayEvent {
//            ExpandedBroadcastView(displayEvent, id: -1, broadcast: Broadcast(data: ["name": "testEvent", "id": -1, "uid": "DNE", "timestamp": Timestamp(), "description": "testEvent description goes something like this. blah blah blah blah blah", "startDate": Date(), "endDate": Date(), "location": "testLocation"]))
//        } else {
//            ExpandedBroadcastView(id: -1, broadcast: Broadcast(data: ["name": "testAnnouncement goes something like this. blah blah blah blah blah", "id": -1, "uid": "DNE", "timestamp": Timestamp()]))
//        }
//    }
//}
