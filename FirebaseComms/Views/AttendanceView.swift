//
//  AttendanceView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 8/30/22.
//

import SwiftUI
import FirebaseFirestore

struct AttendanceView: View {
    let broadcast: Broadcast
    let sender: Bool
    @State var followerData: [[String: Any?]] = []
    @State var expand: Bool = false
    @State var email: String = ""
    @State var attendance: Int = 0
    @State var loaded: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(broadcast: Broadcast) {
        self.broadcast = broadcast
        self.sender = FirebaseManager.shared.auth.currentUser?.email ?? "" == broadcast.data["email"] as? String ?? ""
    }
    
    let group = DispatchGroup()
    private func getFollowerData() {
        print("STarted")
        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        var followerData: [[String: Any?]] = []
        group.enter()
        print("ENTER")
        FirebaseManager.shared.firestore.collection("followers").document(email).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch followers: ", error)
                return
            }
            let followers = snapshot?.data()?["followers"] as? [String] ?? []
            for _ in followers {
                group.enter()
                print("enter")
            }
            for follower in followers {
                FirebaseManager.getUserData(email: follower) { data in
                    var addData = data
                    let document = FirebaseManager.shared.firestore
                        .collection("broadcasts")
                        .document(broadcast.data["email"] as? String ?? "")
                        .collection("sent")
                        .document("\(broadcast.data["id"] as? Int ?? -1)")
                        .collection("privateChannels")
                        .document(follower)
                    document
                        .getDocument { snapshot, error in
                            if let error = error {
                                print("Failed to fetch commentId document: ", error)
                                return
                            }
                            guard let data = snapshot?.data() else {return}
                            addData["readBySender"] = data["readBySender"]
                            addData["readByReceiver"] = data["readByReceiver"]
                            addData["attendance"] = data["attendance"]
                            document
                                .collection("comments")
                                .getDocuments { snapshot, error in
                                    if let error = error {
                                        print("Failed to fetch private comments: ", error)
                                        return
                                    }
                                    let documents: [QueryDocumentSnapshot] = snapshot?.documents ?? []
                                    if documents.count > 0 {
                                        let data = documents[0].data()
                                        addData["lastMessage"] = data["name"]
                                        addData["timestamp"] = data["timestamp"]
                                    }
                                    followerData.append(addData)
                                    print(addData)
                                    group.leave()
                                    print("leave")
                                }
                        }
                }
            }
            group.leave()
            print("LEAVE")
        }
        group.notify(queue: .main) {
            followerData.sort (by: {
                utils.stringsInOrder(a: [$0["familyName"], $0["givenName"], $0["email"]], b: [$1["familyName"], $1["givenName"], $1["email"]])
//                ($0["familyName"] as? String ?? "").compare($1["familyName"] as? String ?? "") == .orderedAscending
//                && (($0["familyName"] as? String ?? "").compare($1["familyName"] as? String ?? "") != .orderedSame
//                    || (($0["givenName"] as? String ?? "").compare($1["givenName"] as? String ?? "") == .orderedAscending
//                        && (($0["givenName"] as? String ?? "").compare($1["givenName"] as? String ?? "") != .orderedSame
//                            || ($0["email"] as? String ?? "").compare($1["email"] as? String ?? "") == .orderedAscending)))
            })
            print(followerData)
            self.followerData = followerData
        }
    }

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
    
    static let attendanceStrings = ["Undecided", "Will Attend", "Will Not Attend"]
    
    var body: some View {
//        NavigationView {
        if !sender {
            Picker(selection: $attendance, label: Text("Attendance status")) {
                Text(AttendanceView.attendanceStrings[0])
                    .foregroundColor(Color.theme.attendanceColors[0])
                    .tag(0)
                Text(AttendanceView.attendanceStrings[1])
                    .foregroundColor(Color.theme.attendanceColors[1])
                    .tag(1)
                Text(AttendanceView.attendanceStrings[2])
                    .foregroundColor(Color.theme.attendanceColors[2])
                    .tag(2)
            }.pickerStyle(SegmentedPickerStyle())
                .onAppear(perform: getAttendance)
                .onReceive([self.attendance].publisher.first()) { attendance in
                    if loaded {
                        updateAttendance(attendance: attendance)
                    }
                }
        } else {
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    ScrollView {
                        VStack {
                            ForEach(0..<followerData.count, id: \.self) { i in
                                let data = followerData[i]
                                VStack(alignment:.leading) {
                                    Button {
                                        email = data["email"] as? String ?? ""
                                        followerData[i]["read"] = true
                                        expand = true
                                    } label: {
                                        HStack (alignment: .center){
                                            HStack(alignment: .top, spacing:16) {
                                                Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: data["profilePicUrl"] as? String ?? constants.defaultUrlString)!))!)
                                                    .resizable()
                                                    .clipped()
                                                    .frame(width: 32, height: 32)
                                                    .cornerRadius(16)
                                                    .overlay(RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.theme.foreground, lineWidth: 1))
                                                    .padding(.leading)
                                                
                                                VStack (alignment: .leading){
                                                    HStack(alignment:.center) {
                                                        Text("\(data["familyName"] as? String ?? "Anon"), \(data["givenName"] as? String ?? "Anon")")
                                                            .font(.system(size:16, weight:.semibold))
                                                            .foregroundColor(Color.theme.foreground)
                                                        if data["Timestamp"] != nil {
                                                            Text("\(utils.getDateFormat(format: "mdy").string(from: (data["Timestamp"] as? Timestamp ?? Timestamp()).dateValue()))")
                                                                .font(.system(size:12))
                                                                .foregroundColor(Color.theme.accent)
                                                        }
                                                        if data["attendance"] as? Int ?? 0 != 0 {
                                                            Text(AttendanceView.attendanceStrings[data["attendance"] as? Int ?? 0])
                                                                .font(.system(size:12, weight:.bold))
                                                                .foregroundColor(Color.theme.attendanceColors[data["attendance"] as? Int ?? 0])
                                                        }
                                                    }
                                                    if data["lastMessage"] != nil {
                                                        Text(data["lastMessage"] as? String ?? "Unknown Content")
                                                            .font(.system(size:14))
                                                            .foregroundColor(Color.theme.foreground)
                                                    }
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            if !(data["read"] as? Bool ?? true) {
                                                Circle()
                                                    .foregroundColor(.red)
                                                    .frame(width:12, height:12)
                                            }
                                        }
                                    }
                                    
                                    Divider()
                                        .padding(.vertical, 8)
                                }
//                                .background(Color.theme.attendanceColors[data["attendance"] as? Int ?? 0])
                            }
                            .padding(.top)
                        }
                    }
                    .fullScreenCover(isPresented: $expand) {
                        NavigationView {
                            CommentsView(broadcast: broadcast, email: email, isFullScreen: true)
                        }
                    }
                    .navigationTitle("Attendance/Private Messages")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            BackButtonView(dismiss: self.dismiss)
                        }
                }
                }
            }
            .onAppear(perform: getFollowerData)
        }
//        }
        
    }
}

//struct AttendanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        AttendanceView()
//    }
//}
