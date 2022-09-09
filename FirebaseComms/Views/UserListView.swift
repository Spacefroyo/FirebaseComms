//
//  AttendanceView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 8/30/22.
//

import SwiftUI
import FirebaseFirestore

struct UserListView: View {
    let broadcast: Broadcast
    let connectionType: String
    let path: CollectionReference
    var appendView: (String) -> AnyView?
    let expandable: Bool
    let isPresented: Bool
    @State var userData: [[String: Any?]] = []
    @State var expand: Bool = false
    @State var email: String = ""
    @State var error: String = ""
    @State var loading: Bool = true
    
    @Environment(\.dismiss) private var dismiss
    
    init(broadcast: Broadcast, connectionType: String, path: CollectionReference, appendView: @escaping (String) -> AnyView? = {(email: String) -> AnyView? in return nil}, expandable: Bool = false, isPresented: Bool = false) {
        self.broadcast = broadcast
        self.connectionType = connectionType
        self.path = path
        self.appendView = appendView
        self.expandable = expandable
        self.isPresented = isPresented
    }
    
    let group = DispatchGroup()
    func getUserData(after: @escaping ()->Void = {() -> Void in return}) {
        loading = true
        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        var userData: [[String: Any?]] = []
        group.enter()
        FirebaseManager.shared.firestore.collection("connections").document(email).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch \(connectionType): ", error)
                return
            }
            let users = snapshot?.data()?[connectionType] as? [String] ?? []
            for user in users {
                var userSort: [String] = [email, user]
                userSort.sort (by: {
                    $0.compare($1) == .orderedAscending
                })
                let document = path.parent?.documentID ?? "" == email ?
                path.parent?.parent
                    .document(userSort[0])
                    .collection("privateChannels")
                    .document(userSort[1])
                : path
                    .document(user)
                document?
                    .getDocument { snapshot, error in
                        if let snapshot = snapshot, snapshot.exists {
                            } else {
                                document?.setData(["attendance": 0, "read": true, "commentsReadBySender": true, "commentsReadByReceiver": true])
                            }
                    }
                group.enter()
            }
            for user in users {
                FirebaseManager.getUserData(email: user) { data in
                    var addData = data
                    var userSort: [String] = [email, user]
                    userSort.sort (by: {
                        $0.compare($1) == .orderedAscending
                    })
                    let document = path.parent?.documentID ?? "" == email ?
                    path.parent?.parent
                        .document(userSort[0])
                        .collection("privateChannels")
                        .document(userSort[1])
                    : path
                        .document(user)
                    document?
                        .getDocument { snapshot, error in
                            if let error = error {
                                print("Failed to fetch commentId document: ", error)
                                return
                            }
                            guard let data = snapshot?.data() else {return}
                            addData["commentsReadBySender"] = data["commentsReadBySender"]
                            addData["commentsReadByReceiver"] = data["commentsReadByReceiver"]
                            addData["attendance"] = data["attendance"]
                            document?
                                .collection("comments")
                                .getDocuments { snapshot, error in
                                    if let error = error {
                                        print("Failed to fetch private comments: ", error)
                                        return
                                    }
                                    let documents: [QueryDocumentSnapshot] = snapshot?.documents ?? []
                                    if documents.count > 0 {
                                        let data = documents[documents.count-1].data()
                                        addData["lastMessage"] = data["name"]
                                        addData["timestamp"] = data["timestamp"]
                                    }
                                    userData.append(addData)
//                                    print(addData)
                                    group.leave()
                                }
                        }
                }
            }
            group.leave()
        }
        group.notify(queue: .main) {
            userData.sort (by: {
                utils.stringsInOrder(a: [$0["familyName"], $0["givenName"], $0["email"]], b: [$1["familyName"], $1["givenName"], $1["email"]])
//                ($0["familyName"] as? String ?? "").compare($1["familyName"] as? String ?? "") == .orderedAscending
//                && (($0["familyName"] as? String ?? "").compare($1["familyName"] as? String ?? "") != .orderedSame
//                    || (($0["givenName"] as? String ?? "").compare($1["givenName"] as? String ?? "") == .orderedAscending
//                        && (($0["givenName"] as? String ?? "").compare($1["givenName"] as? String ?? "") != .orderedSame
//                            || ($0["email"] as? String ?? "").compare($1["email"] as? String ?? "") == .orderedAscending)))
            })
            self.userData = userData
            after()
            loading = false
        }
    }
    
    static let attendanceStrings = ["Undecided", "Will Attend", "Will Not Attend"]
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            if userData.count > 0 {
                ScrollView {
                    VStack {
                        Text(error)
                            .foregroundColor(Color.red)
                        
                        ForEach(0..<userData.count, id: \.self) { i in
                            let data = userData[i]
                            let display = HStack (alignment: .center){
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
                                                Text(UserListView.attendanceStrings[data["attendance"] as? Int ?? 0])
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
                                    
                                    Spacer()
                                    
                                    appendView(data["email"] as? String ?? "")
                                }
                                
                                Spacer()
                                
                                if !(data["commentsReadBy\((FirebaseManager.shared.auth.currentUser?.email ?? "").compare(data["email"] as? String ?? "") == .orderedAscending ? "Sender" : "Receiver")"] as? Bool ?? true) && appendView("") == nil {
                                    Circle()
                                        .foregroundColor(.red)
                                        .frame(width:12, height:12)
                                        .padding()
                                }
                            }
                            VStack(alignment:.leading) {
                                if expandable {
                                    Button {
                                        email = data["email"] as? String ?? ""
                                        userData[i]["read"] = true
                                        expand = true
                                    } label: {
                                        display
                                    }
                                } else {
                                    display
                                }
                                
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
                .fullScreenCover(isPresented: $expand) {
                    NavigationView {
                        CommentsView(broadcast: broadcast, email: email, path:
                                        path
                            .document(email)
                            .collection("comments"))
                    }
                    .onAppear {
                        getUserData()
                    }
                    .onDisappear {
                        getUserData()
                    }
                }
//                .navigationBarBackButtonHidden(true)
//                .toolbar {
//                    ToolbarItem(placement: .navigationBarLeading) {
//                        isPresented ? BackButtonView(dismiss: self.dismiss) : nil
//                    }
//                }
            } else if !connectionType.starts(with: "pending") {
                Text("No \(connectionType) yet")
                    .foregroundColor(Color.theme.accent)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                isPresented ? BackButtonView(dismiss: self.dismiss) : nil
            }
        }
        .onAppear {
            getUserData()
        }
        .overlay(
            ZStack{
                if loading {
                    if isPresented {
                        Color.black
                            .opacity(0.25)
                            .ignoresSafeArea()
                    }
                    
                    ProgressView()
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(Color.theme.background)
                        .ignoresSafeArea()
                        .cornerRadius(10)
                }
            }
        )
//            .task {
//                await getUserData()
//            }
//        .onAppear(perform: getUserData)
        
    }
}

//struct AttendanceView_Previews: PreviewProvider {
//    static var previews: some View {
//        AttendanceView()
//    }
//}
