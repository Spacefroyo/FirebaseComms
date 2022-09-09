//
//  ExpandedBroadcastView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/11/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import EventKit
import EventKitUI
import SwiftUI
import UIKit

struct ExpandedBroadcastView: View, Identifiable {
    let id: Int
    @State var broadcast: Broadcast
    @State var from: BroadcastView? = nil
    @State var expand: Bool = false
    @State var attendanceExpand: Bool = false
    @State var inAttendance: Bool = false
    @State var _public: Bool = true
    @State var read: Bool = true
//    @State var cid: Int = -1
//    @State var _public: Bool = true
    @Environment(\.dismiss) private var dismiss
    @State var posted = false
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                VStack {
        //            Text("\(broadcast.data["id"] as? Int ?? 0)")
                    ScrollView {
                        VStack {
                            switch utils.broadcastType(broadcast: broadcast) {
                            case "announcement":
                                announcement
                                    .navigationBarBackButtonHidden(true)
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarLeading) {
                                            BackButtonView(dismiss: self.dismiss)
                                        }
                                    }
                            case "event":
                                event
                                    .navigationBarBackButtonHidden(true)
                                    .toolbar {
                                        ToolbarItem(placement: .navigationBarLeading) {
                                            BackButtonView(dismiss: self.dismiss)
                                        }
                                    }
                            default:
                                Text("Unrecognized broadcast type")
                                    .font(.system(size:24, weight:.bold))
                                    .foregroundColor(Color.red)
                                    .padding([.leading, .trailing, .bottom])
                            }
                            
                            Picker(selection: $_public, label: Text("Picker here")) {
                                Text("Public")
                                    .tag(true)
                                Text("Private/Attendance\(read ? "" : " 🔴")")
                                    .tag(false)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .onReceive([self._public].publisher.first()){ _public in
                                attendanceExpand = !inAttendance && !_public && FirebaseManager.shared.auth.currentUser?.email ?? "" == broadcast.data["email"] as? String ?? ""
                            }
                            .onAppear(perform: isRead)
                            
                            Divider()
                                .padding(.top)
                            
                            if _public {
                                CommentsView(broadcast: broadcast, path:
                                                FirebaseManager.shared.firestore
                                                    .collection("broadcasts")
                                                    .document(broadcast.data["email"] as? String ?? "")
                                                    .collection("sent")
                                                    .document("\(broadcast.data["id"] as? Int ?? -1)")
                                                    .collection("comments"))
                            } else if !attendanceExpand {
                                if utils.broadcastType(broadcast: broadcast) == "event" {
                                    Picker(selection: $attendance, label: Text("Attendance status")) {
                                        Text(UserListView.attendanceStrings[0])
                                            .foregroundColor(Color.theme.attendanceColors[0])
                                            .tag(0)
                                        Text(UserListView.attendanceStrings[1])
                                            .foregroundColor(Color.theme.attendanceColors[1])
                                            .tag(1)
                                        Text(UserListView.attendanceStrings[2])
                                            .foregroundColor(Color.theme.attendanceColors[2])
                                            .tag(2)
                                    }.pickerStyle(SegmentedPickerStyle())
                                        .onAppear(perform: getAttendance)
                                        .onReceive([self.attendance].publisher.first()) { attendance in
                                            if loaded {
                                                updateAttendance(attendance: attendance)
                                            }
                                        }
                                }
                                CommentsView(broadcast: broadcast, email: broadcast.data["email"] as? String ?? "", path:
                                                FirebaseManager.shared.firestore
                                                    .collection("broadcasts")
                                                    .document(broadcast.data["email"] as? String ?? "")
                                                    .collection("sent")
                                                    .document("\(broadcast.data["id"] as? Int ?? -1)")
                                                    .collection("privateChannels")
                                                    .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                                                    .collection("comments"))
                                    .onAppear(perform: {
                                        if broadcast.data["email"] as? String ?? "" != FirebaseManager.shared.auth.currentUser?.email ?? "" {
                                            read = true
                                        }
                                    })
                            }
                            
//                            comments
                        }
                    }

        //            Spacer()
                    
                    if broadcast.data["email"] as? String ?? "" == FirebaseManager.shared.auth.currentUser?.email {
                        Button {
                            expand = true
                        } label: {
                            Text("Edit")
                        }
                    }
                }
                .fullScreenCover(isPresented: $attendanceExpand, content: {
                    NavigationView {
                        UserListView(broadcast: broadcast, connectionType: "followers", path:
                                        FirebaseManager.shared.firestore
                                            .collection("broadcasts")
                                            .document(broadcast.data["email"] as? String ?? "")
                                            .collection("sent")
                                            .document("\(broadcast.data["id"] as? Int ?? -1)")
                                            .collection("privateChannels"), expandable: true, isPresented: true)
                            .onAppear(perform: {
                                inAttendance = true
                            })
                            .onDisappear(perform: {
                                isRead()
                                _public = true
                                inAttendance = false
                            })
                            .navigationTitle("Attendance/Private Messages")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                })
                .fullScreenCover(isPresented: $expand) {
                    switch utils.broadcastType(broadcast: broadcast) {
                    case "announcement":
                        NewBroadcastView(broadcastType: utils.broadcastType(broadcast: broadcast), description: broadcast.data["name"] as? String ?? "", id: broadcast.data["id"] as? Int ?? -1, from: self)
                            .onDisappear {
//                                print(posted)
                                if posted {
                                    self.dismiss()
                                }
                            }
                    case "event":
                        NewBroadcastView(broadcastType: utils.broadcastType(broadcast: broadcast), name: broadcast.data["name"] as? String ?? "", description: broadcast.data["description"] as? String ?? "", startDate: (broadcast.data["startDate"] as? Timestamp ?? Timestamp()).dateValue(), endDate: (broadcast.data["endDate"] as? Timestamp ?? Timestamp()).dateValue(), location: broadcast.data["location"] as? String ?? "", attachments: broadcast.data["attachments"] as? [URL?] ?? [], id: broadcast.data["id"] as? Int ?? -1, from: self)
                            .onDisappear {
//                                print(posted)
                                if posted {
                                    self.dismiss()
                                }
                            }
                    default:
                        Text("Unrecognized broadcast type")
                            .font(.system(size:24, weight:.bold))
                            .foregroundColor(Color.red)
                            .padding([.leading, .trailing, .bottom])
                    }
                }
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
//        .onTapGesture {
//            if (publicComment == "") {
//                publicComment = ExpandedBroadcastView.publicCommentDefault
//            }
//        }
    }
    
    @State var loaded: Bool = false
    @State var attendance: Int = 0
    private func updateAttendance(attendance: Int) {
        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        FirebaseManager.shared.firestore
            .collection("broadcasts")
            .document(broadcast.data["email"] as? String ?? "")
            .collection("sent")
            .document("\(broadcast.data["id"] as? Int ?? -1)")
            .collection("privateChannels")
            .document(email)
            .setData(["attendance": attendance], merge: true)
    }
    
    private func getAttendance() {
        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        FirebaseManager.shared.firestore
            .collection("broadcasts")
            .document(broadcast.data["email"] as? String ?? "")
            .collection("sent")
            .document("\(broadcast.data["id"] as? Int ?? -1)")
            .collection("privateChannels")
            .document(email)
            .getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch commentId document: ", error)
                    return
                }
                guard let data = snapshot?.data() else {return}
                attendance = data["attendance"] as? Int ?? 0
                loaded = true
            }
    }
    
    private func isRead() {
        if broadcast.data["email"] as? String ?? "" != FirebaseManager.shared.auth.currentUser?.email ?? "" {
            FirebaseManager.shared.firestore
                .collection("broadcasts")
                .document(broadcast.data["email"] as? String ?? "")
                .collection("sent")
                .document("\(broadcast.data["id"] as? Int ?? -1)")
                .collection("privateChannels")
                .document(FirebaseManager.shared.auth.currentUser?.email ?? "")
                .getDocument { snapshot, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    read = snapshot?.data()?["commentsReadByReceiver"] as? Bool ?? false
                }
        } else {
            read = true
            FirebaseManager.shared.firestore.collection("connections").document(FirebaseManager.shared.auth.currentUser?.email ?? "").getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch current user: ", error)
                    return
                }
                let followers = snapshot?.data()?["followers"] as? [String] ?? []
                for follower in followers {
                    FirebaseManager.shared.firestore
                        .collection("broadcasts")
                        .document(broadcast.data["email"] as? String ?? "")
                        .collection("sent")
                        .document("\(broadcast.data["id"] as? Int ?? -1)")
                        .collection("privateChannels")
                        .document(follower)
                        .getDocument { snapshot, error in
                            if let error = error {
                                print(error)
                                return
                            }
                            read = snapshot?.data()?["commentsReadBySender"] as? Bool ?? false && read
                        }
                }
            }
        }
    }
    
    var announcement: some View {
//        NavigationView {
//            ScrollView {
                VStack (spacing: 16){
                    HStack {
                        Text("\(broadcast.data["name"] as? String ?? "")")
        //                    .frame(height: 100, alignment: .top)
                            .padding()
                            .foregroundColor(Color.theme.foreground)
//                          .background(Color.white)
                        
                        Spacer()
                    }
                    
                    Group {
                        let imageUrls = broadcast.data["images"] as? [String] ?? []
                        if !imageUrls.isEmpty {
                            Text("Images")
                                .padding()
                            ScrollView(.horizontal) {
                                HStack(spacing: 20) {
                                    ForEach(0..<imageUrls.count, id: \.self) { i in
                                        VStack {
                                            Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: imageUrls[i]) ?? constants.defaultUrl))!)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipped()
                                                .frame(height: 256)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.theme.accent)
                        }
                    }
                    
                    Text("Posted \((broadcast.data["timestamp"] as? Timestamp ?? Timestamp()).dateValue())")
                        .foregroundColor(Color.theme.accent)
                    
    //                Spacer()
                }
                .navigationTitle("Announcement")
//            }
//        }
    }
    
//    @State var calendarManager: EKEventEditViewController? = nil
//    @State var expandCalendarManager: Bool = false
    @State var addedToCalendar: Bool = false
    var event: some View {
//        NavigationView {
//            VStack {
                
//                ScrollView {
            VStack (alignment: .leading){
                
                Text("\(broadcast.data["description"] as? String ?? "")")
                    .padding()
                    .foregroundColor(Color.theme.foreground)
                
                Group {
                    let imageUrls = broadcast.data["images"] as? [String] ?? []
                    if !imageUrls.isEmpty {
                        Text("Images")
                            .padding()
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(0..<imageUrls.count, id: \.self) { i in
                                    VStack {
                                        Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: imageUrls[i]) ?? constants.defaultUrl))!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .clipped()
                                            .frame(height: 256)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.theme.accent)
                    }
                }
                
                HStack {
                    Text("Event Information")
                        .font(.title2)
                    .fontWeight(.bold)
                    
                    Spacer()
                    
                    if addedToCalendar {
                        Text("Added to Calendar")
                            .foregroundColor(Color.theme.accent)
                    } else {
                        HStack {
                            Button {
                                let cm = CalendarManager(broadcast: broadcast)
                                cm.addEvent()
                                addedToCalendar = true
                                
                            } label: {
                                Text("Add to Calendar")
                                    .padding([.leading, .trailing], 8)
                            }
                        }
                        .background(Color.theme.accent)
                        .cornerRadius(5)
                    }
                }
                .padding([.top, .leading, .trailing])
                .foregroundColor(Color.theme.foreground)
                
                Divider()
                
                Group {
//                        Text(broadcast.data.description)
                    
                    
//                    Divider().padding(0)
                    
                    Text("From: \(utils.getDateFormat(format: "mdytz").string(from: (broadcast.data["startDate"] as? Timestamp ?? Timestamp()).dateValue()))")
                    
                    Text("To: \(utils.getDateFormat(format: "mdytz").string(from: (broadcast.data["endDate"] as? Timestamp ?? Timestamp()).dateValue()))")
                    
                    Text("Location: \(broadcast.data["location"] as? String ?? "")")
                    
                    let attachments = broadcast.data["attachments"] as? [String] ?? []
                    let attachmentNames = broadcast.data["attachmentNames"] as? [String] ?? []
                    if !attachments.isEmpty {
                        Text("Attachments")
                        ForEach(0...attachments.count-1, id: \.self) { i in
                            URLButton(content:
                                Text(attachmentNames[i])
                                    .padding()
                                    .background(Color.theme.accent)
                                    .foregroundColor(Color.theme.foreground)
                                    .cornerRadius(15), url: attachments[i])
                        }
                        .frame(alignment: .leading)
                    }
                    
                    Text("Posted \((broadcast.data["timestamp"] as? Timestamp ?? Timestamp()).dateValue())")
                        .foregroundColor(Color.theme.accent)
                }
                .padding([.top, .leading, .trailing])
                .foregroundColor(Color.theme.foreground)
            }
            .navigationTitle("\(broadcast.data["name"] as? String ?? "")")
//                }
//            }
//        }
//        .fullScreenCover(isPresented: $expandCalendarManager) {
////            Button {
////                expand = false
////            } label: {
////                Text("< Back")
////            }
//
//            calendarManager?.add
//        }
    }
}

struct ExpandedBroadcastView_Previews: PreviewProvider {
    static var displayEvent: Bool = true
    static var previews: some View {
        if displayEvent {
            ExpandedBroadcastView(id: -1, broadcast: Broadcast(data: ["email": "", "name": "testEvent", "id": -1, "timestamp": Timestamp(), "description": "testEvent description goes something like this. blah blah blah blah blah", "startDate": Date(), "endDate": Date(), "location": "testLocation"])).preferredColorScheme(.dark)
        } else {
            ExpandedBroadcastView(id: -1, broadcast: Broadcast(data: ["email": "", "name": "testAnnouncement goes something like this. blah blah blah blah blah", "id": -1, "timestamp": Timestamp()])).preferredColorScheme(.dark)
        }
    }
}
