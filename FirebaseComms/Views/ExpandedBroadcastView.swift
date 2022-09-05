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
                                CommentsView(broadcast: broadcast, email: FirebaseManager.shared.auth.currentUser?.email ?? "", path:
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
                        NewBroadcastView(broadcastType: utils.broadcastType(broadcast: broadcast), name: broadcast.data["name"] as? String ?? "", id: broadcast.data["id"] as? Int ?? -1, from: self)
                            .onDisappear {
//                                print(posted)
                                if posted {
                                    self.dismiss()
                                }
                            }
                    case "event":
                        NewBroadcastView(broadcastType: utils.broadcastType(broadcast: broadcast), name: broadcast.data["name"] as? String ?? "", description: broadcast.data["description"] as? String ?? "", startDate: (broadcast.data["startDate"] as? Timestamp ?? Timestamp()).dateValue(), endDate: (broadcast.data["endDate"] as? Timestamp ?? Timestamp()).dateValue(), location: broadcast.data["location"] as? String ?? "", id: broadcast.data["id"] as? Int ?? -1, from: self)
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
    
//    private func setBroadcast() {
//        FirebaseManager.shared.firestore
//            .collection("broadcasts")
//            .document(broadcast.data["email"] as? String ?? "")
//            .collection("sent")
//            .document("\(broadcast.data["id"] as? Int ?? -1)")
//            .getDocument { snapshot, error in
//                <#code#>
//            }
//    }
    
//    static let publicCommentDefault: String = "Add Public Comment"
//    @State var publicComment: String = ""
//
//    static let privateCommentDefault: String = "Add Private Comment"
//    @State var privateComment: String = privateCommentDefault
//    var comments: some View {
//        VStack {
//
//            Divider()
//                .padding(.top)
//
//            HStack {
//                VStack {
//                    HStack {
//                        ZStack (alignment: .leading){
//                            Text("Add Public Comment")
//                                .foregroundColor(Color.theme.accent)
////                                .padding(.leading, 18)
//                                .padding()
//                                .opacity(publicComment == "" ? 1 : 0)
//
//                            TextEditor(text: $publicComment)
////                                .padding([.leading, .trailing])
//                                .padding([.leading, .trailing], 11)
//                                .padding([.top, .bottom], 8)
//                                .lineLimit(5)
//                        }
//
//                        Spacer()
//
//
//                        Button {
//                            makeComment()
//                        } label: {
//                            Image(systemName: "arrow.right")
//                        }
//                        .disabled(publicComment.isEmpty)
//                        .padding([.top, .bottom], 2)
//                        .padding([.trailing])
//                    }
//
//                    Divider()
//
////                    ForEach(commentData, commentUserData, id: \.self) { i in
////                    Text(String(commentData.count))
//                    VStack {
//                        ForEach(0..<commentData.count, id: \.self) { i in
//    //                    for i in 0..<commentData.count {
//                            let comment = commentData[i]
//                            let data = commentUserData[i]
//                            VStack(alignment:.leading) {
//                                HStack(alignment: .top, spacing:16) {
//                                    Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: data["profilePicUrl"] as? String ?? constants.defaultUrlString)!))!)
//                                        .resizable()
//                                        .clipped()
//                                        .frame(width: 32, height: 32)
//                                        .cornerRadius(16)
//                    //                    .padding(8)
//                                        .overlay(RoundedRectangle(cornerRadius: 16)
//                                            .stroke(Color.theme.foreground, lineWidth: 1))
//                                        .padding(.leading)
//                    //                        .frame(width: 32, height: 32))
//                                    VStack(alignment:.leading){
//                                        HStack(alignment:.center) {
//                                            Text("\(data["givenName"] as? String ?? "Anon") \(data["familyName"] as? String ?? "Anon")")
//                                                .font(.system(size:16, weight:.semibold))
//                                                .foregroundColor(Color.theme.foreground)
//                                            Text("\(utils.getDateFormat(format: "mdy").string(from: (comment.data["Timestamp"] as? Timestamp ?? Timestamp()).dateValue()))")
//                                                .font(.system(size:12))
//                                                .foregroundColor(Color.theme.accent)
//                                        }
//                                        Text(comment.data["name"] as? String ?? "Unknown Content")
//                                            .font(.system(size:14))
//                                            .foregroundColor(Color.theme.foreground)
//                                    }
//    //                                Spacer()
//    //
//    //                                HStack{
//    //                                    Circle()
//    //                                        .foregroundColor(.red)
//    //                                        .frame(width:12, height:12)
//    //                                    Text(utils.timeSince(timestamp:comment.data["timestamp"] as? Timestamp ?? Timestamp()))
//    //                                        .font(.system(size:14, weight:.semibold))
//    //                                        .foregroundColor(Color.black)
//    //                                        .padding(.trailing)
//    //                                }
//                                }
//                                Divider()
//                                    .padding(.vertical, 8)
//                            }
//
//                        }
//                    }
//
////                    Spacer()
//                }
//
////                Divider()
////
////                VStack {
////                    TextField("Add Private Comment", text: $privateComment)
////
////                    Spacer()
////                }
//            }
//        }
//        .onAppear(perform: {
//            getComments()
//        })
//    }
    
//    private func getCommentsPath(id: Int, email: String, emailB: String) -> CollectionReference{
//        let broadcastDocument = FirebaseManager.shared.firestore
//            .collection("broadcasts")
//            .document(emailB)
//            .collection("sent")
//            .document("\(id)")
//
//        return _public ?
//        broadcastDocument
//            .collection("comments")
//        : broadcastDocument
//            .collection("privateChannels")
//            .document(email)
//            .collection("comments")
//    }
    
    //essentially id is always defined but cid isn't so do something about it
    //maybe have it be fetched when you click on the comment?
    
//    private func makeComment() {
//        let name = _public ? publicComment : privateComment
//        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
//        let emailB = broadcast.data["email"] as? String ?? ""
//        let id = broadcast.data["id"] as? Int ?? -1
//        fetchId()
//        group.notify(queue: .main) {
//            let comment = Comment(data: ["email": email, "id": cid, "name": name, "timestamp": Timestamp()] as [String: Any])
//            commentData.append(comment)
//            commentUserData.append(FirebaseManager.shared.data)
//            getCommentsPath(id: id, email: email, emailB: emailB)
//                .document("\(cid)")
//                .setData(comment.data) { err in
//                    if let err = err {
//                        print(err)
//                        return
//                    }
//                    if _public {
//                        publicComment = ""
//                    } else {
//                        privateComment = ""
//                    }
//                }
//        }
//    }
    
//    private let group = DispatchGroup()
//    private func fetchId(){
//        print("Fetch")
//        group.enter()
//        DispatchQueue.main.async {
//            let document = FirebaseManager.shared.firestore
//                .collection("data")
//                .document("commentId")
//            document.getDocument { snapshot, error in
//                if let error = error {
//                    print("Failed to fetch commentId document: ", error)
//                    return
//                }
//                
//                guard let data = snapshot?.data() else {return}
//                cid = data["id"] as? Int ?? 0
//                print("Fetched ", cid)
//                document.setData(["id": cid+1]) { err in
//                    if let err = err {
//                        print(err)
//                        return
//                    }
//                    group.leave()
//                }
//                
//            }
//        }
//    }
    
//    @State var commentData: [Comment] = []
//    @State var commentUserData: [[String: Any?]] = []
//    func getComments() {
//        
//        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
//        let emailB = broadcast.data["email"] as? String ?? ""
//        let id = broadcast.data["id"] as? Int ?? -1
//        getCommentsPath(id: id, email: email, emailB: emailB)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print(error)
//                    return
//                }
//                
//                let documents: [QueryDocumentSnapshot] = snapshot?.documents ?? []
//                var commentData: [Comment] = []
//                for document in documents {
////                    let data = document.data()
//                    commentData.append(Comment(data: document.data()))
////                    if _public || (data["email"] as? String ?? "") == email || (data["email"] as? String ?? "") == emailB {
////                        commentData.append(Comment(data: document.data()))
////
////                    }
//                }
//                
//                let commentGroup = DispatchGroup()
////                var FirebaseManager.seenUsers: [String: [String: Any]] = [:]
//                var commentUserData: [[String: Any?]?] = Array(repeating: nil, count: commentData.count)
//                for i in 0..<commentData.count {
////                for comment in commentData {
//                    let comment = commentData[i]
//                    commentGroup.enter()
//                    let email = comment.data["email"] as! String
//                    let data = FirebaseManager.seenUsers[email] ?? [:]
//                    if data.isEmpty {
//                        FirebaseManager.getUserData(email: email) { data in
//                            commentUserData[i] = data
////                            viewId += 1
//                            commentGroup.leave()
//                        }
//                    } else {
//                        commentUserData[i] = data
////                        viewId += 1
//                        commentGroup.leave()
//                    }
//                }
//                commentGroup.notify(queue: .main) {
//                    self.commentData = commentData
//                    self.commentUserData = commentUserData as! [[String: Any?]]
//                }
//            }
//    }
//    
//    func deleteComment(comment: Comment) {
//        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
//        let emailB = broadcast.data["email"] as? String ?? ""
//        let id = broadcast.data["id"] as? Int ?? -1
//        getCommentsPath(id: id, email: email, emailB: emailB)
//            .document("\(cid)").delete() { err in
//                if let err = err {
//                    print(err)
//                    return
//                }
//            }
//    }
    
    var announcement: some View {
//        NavigationView {
//            ScrollView {
                VStack (spacing: 16){
                    Text("\(broadcast.data["name"] as? String ?? "")")
    //                    .frame(height: 100, alignment: .top)
                        .padding()
                        .foregroundColor(Color.theme.foreground)
//                        .background(Color.white)
                    
                    
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
                    
                    Text("Attachments")
                    
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
