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
    @State var cid: Int = -1
    
    
    
    var body: some View {
        
        VStack {
//            Text("\(broadcast.data["id"] as? Int ?? 0)")
            if broadcast.data.count == 4 {
                announcement
            } else {
                event
            }
            
            comments

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
    
    @State var publicComment: String = ""
    @State var privateComment: String = ""
    var comments: some View {
        VStack {
            Divider()
            
            HStack {
                VStack {
                    HStack {
                        TextField("Add Public Comment", text: $publicComment)
                        
                        Button {
                            makeComment(_public: true)
                        } label: {
                            Image(systemName: "arrow.right")
                        }
                        .disabled(publicComment.isEmpty)
                    }
                    
                    Divider()
                    
//                    ForEach(commentData, commentUserData, id: \.self) { i in
                    Text(String(commentData.count))
                    ScrollView {
                        ForEach(0..<commentData.count, id: \.self) { i in
    //                    for i in 0..<commentData.count {
                            let comment = commentData[i]
                            let data = commentUserData[i]
                            VStack {
                                HStack(spacing:16) {
                                    Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: data["profilePicUrl"] as? String ?? constants.defaultUrlString)!))!)
                                        .resizable()
                                        .clipped()
                                        .frame(width: 32, height: 32)
                                        .cornerRadius(16)
                    //                    .padding(8)
                                        .overlay(RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.black, lineWidth: 1))
                                        .padding(.leading)
                    //                        .frame(width: 32, height: 32))
                                    VStack(alignment:.leading){
                                        HStack(alignment:.center) {
                                            Text("\(data["givenName"] as? String ?? "Anon") \(data["familyName"] as? String ?? "Anon")")
                                                .font(.system(size:16, weight:.semibold))
                                                .foregroundColor(Color.black)
                                            Text("\(utils.getDateFormat(format: "mdy").string(from: (comment.data["Timestamp"] as? Timestamp ?? Timestamp()).dateValue()))")
                                                .font(.system(size:12))
                                                .foregroundColor(Color(.lightGray))
                                        }
                                        Text(comment.data["name"] as? String ?? "Unknown Content")
                                            .font(.system(size:14))
                                            .foregroundColor(Color.black)
                                    }
    //                                Spacer()
    //
    //                                HStack{
    //                                    Circle()
    //                                        .foregroundColor(.red)
    //                                        .frame(width:12, height:12)
    //                                    Text(utils.timeSince(timestamp:comment.data["timestamp"] as? Timestamp ?? Timestamp()))
    //                                        .font(.system(size:14, weight:.semibold))
    //                                        .foregroundColor(Color.black)
    //                                        .padding(.trailing)
    //                                }
                                }
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
//                Divider()
//
//                VStack {
//                    TextField("Add Private Comment", text: $privateComment)
//
//                    Spacer()
//                }
            }
        }
        .onAppear(perform: getComments)
    }
    
    //essentially id is always defined but cid isn't so do something about it
    //maybe have it be fetched when you click on the comment?
    
    private func makeComment(_public: Bool) {
        let name = _public ? publicComment : privateComment
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        let emailB = broadcast.data["email"] as? String ?? ""
        let id = broadcast.data["id"] as? Int ?? -1
        fetchId()
        group.notify(queue: .main) {
            let comment = Comment(data: ["email": email, "id": cid, "name": name, "timestamp": Timestamp(), "public": _public] as [String: Any])
            commentData.append(comment)
            commentUserData.append(FirebaseManager.shared.data)
            FirebaseManager.shared.firestore
                .collection("broadcasts")
                .document(emailB)
                .collection("sent")
                .document("\(id)")
                .collection("comments")
                .document("\(cid)")
                .setData(comment.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                }
        }
    }
    
    private let group = DispatchGroup()
    private func fetchId(){
        print("Fetch")
        group.enter()
        DispatchQueue.main.async {
            let document = FirebaseManager.shared.firestore
                .collection("data")
                .document("commentId")
            document.getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch commentId document: ", error)
                    return
                }
                
                guard let data = snapshot?.data() else {return}
                cid = data["id"] as? Int ?? 0
                print("Fetched ", cid)
                document.setData(["id": cid+1]) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                    group.leave()
                }
                
            }
        }
    }
    
    @State var commentData: [Comment] = []
    @State var commentUserData: [[String: Any?]] = []
    func getComments() {
        
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        let emailB = broadcast.data["email"] as? String ?? ""
        let id = broadcast.data["id"] as? Int ?? -1
        FirebaseManager.shared.firestore
            .collection("broadcasts")
            .document(emailB)
            .collection("sent")
            .document("\(id)")
            .collection("comments")
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                let documents: [QueryDocumentSnapshot] = snapshot?.documents ?? []
                var commentData: [Comment] = []
                for document in documents {
                    let data = document.data()
                    if (data["public"] as? Bool ?? false) || (data["email"] as? String ?? "") == email || (data["email"] as? String ?? "") == emailB {
                        commentData.append(Comment(data: document.data()))
                        
                    }
                }
                
                let commentGroup = DispatchGroup()
//                var FirebaseManager.seenUsers: [String: [String: Any]] = [:]
                var commentUserData: [[String: Any?]?] = Array(repeating: nil, count: commentData.count)
                for i in 0..<commentData.count {
//                for comment in commentData {
                    let comment = commentData[i]
                    commentGroup.enter()
                    let email = comment.data["email"] as! String
                    let data = FirebaseManager.seenUsers[email] ?? [:]
                    if data.isEmpty {
                        FirebaseManager.getUserData(email: email) { data in
                            commentUserData[i] = data
//                            viewId += 1
                            commentGroup.leave()
                        }
                    } else {
                        commentUserData[i] = data
//                        viewId += 1
                        commentGroup.leave()
                    }
                }
                commentGroup.notify(queue: .main) {
                    self.commentData = commentData
                    self.commentUserData = commentUserData as! [[String: Any?]]
                }
            }
    }
    
    func deleteComment(comment: Comment) {
//        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        let emailB = broadcast.data["email"] as? String ?? ""
        let id = broadcast.data["id"] as? Int ?? -1
        FirebaseManager.shared.firestore
            .collection("broadcasts")
            .document(emailB)
            .collection("sent")
            .document("\(id)")
            .collection("comments")
            .document("\(cid)").delete() { err in
                if let err = err {
                    print(err)
                    return
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

struct ExpandedBroadcastView_Previews: PreviewProvider {
    static var displayEvent: Bool = false
    static var previews: some View {
//        if displayEvent {
//            ExpandedBroadcastView(displayEvent, id: -1, broadcast: Broadcast(data: ["name": "testEvent", "id": -1, "uid": "DNE", "timestamp": Timestamp(), "description": "testEvent description goes something like this. blah blah blah blah blah", "startDate": Date(), "endDate": Date(), "location": "testLocation"]))
//        } else {
            ExpandedBroadcastView(id: -1, broadcast: Broadcast(data: ["name": "testAnnouncement goes something like this. blah blah blah blah blah", "id": -1, "timestamp": Timestamp()]))
//        }
    }
}
