//
//  CommentsView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 8/30/22.
//

import SwiftUI
import FirebaseFirestore

struct CommentsView: View {
    let broadcast: Broadcast
    let _public: Bool
    let path: CollectionReference
    let email: String
    let isFullScreen: Bool
    @Environment(\.dismiss) private var dismiss
    
    init(broadcast: Broadcast) {
        self.broadcast = broadcast
        self._public = true
        self.isFullScreen = false
        self.email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        self.path = CommentsView.getCommentsPath(broadcast: broadcast, email: email, _public: _public)
    }
    
    init(broadcast: Broadcast, email: String, isFullScreen: Bool = false) {
        self.broadcast = broadcast
        self._public = false
        self.isFullScreen = isFullScreen
        self.email = email
        self.path = CommentsView.getCommentsPath(broadcast: broadcast, email: email, _public: _public)
    }
    
    static func getCommentsPath(broadcast: Broadcast, email: String, _public: Bool) -> CollectionReference {
        let broadcastDocument = FirebaseManager.shared.firestore
            .collection("broadcasts")
            .document(broadcast.data["email"] as? String ?? "")
            .collection("sent")
            .document("\(broadcast.data["id"] as? Int ?? -1)")
        
        return _public ?
        broadcastDocument
            .collection("comments")
        : broadcastDocument
            .collection("privateChannels")
            .document(email)
            .collection("comments")
    }
    
    @State var commentString: String = ""
    var body: some View {
        VStack {
            VStack {
                HStack {
                    ZStack (alignment: .topLeading){
                        Text("Add \(_public ? "Public" : "Private") Comment")
                            .foregroundColor(Color.theme.accent)
                            .padding()
                            .opacity(commentString == "" ? 1 : 0)
                        
                        TextEditor(text: $commentString)
                            .padding([.leading, .trailing], 11)
                            .padding([.top, .bottom], 8)
//                            .lineLimit(5)
                            .frame(maxHeight: 100)
                    }
                    
                    Spacer()
                        
                        
                    Button {
                        makeComment()
                    } label: {
                        Image(systemName: "arrow.right")
                    }
                    .disabled(commentString.isEmpty)
                    .padding([.top, .bottom], 2)
                    .padding([.trailing])
                }
                
                
                Divider()
                    .padding(.bottom)
                
                
                ScrollView {
                    VStack {
                        ForEach(0..<commentData.count, id: \.self) { i in
                            let comment = commentData[i]
                            let data = commentUserData[i]
                            VStack(alignment:.leading) {
                                HStack(alignment: .top, spacing:16) {
                                    Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: data["profilePicUrl"] as? String ?? constants.defaultUrlString)!))!)
                                        .resizable()
                                        .clipped()
                                        .frame(width: 32, height: 32)
                                        .cornerRadius(16)
                                        .overlay(RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.theme.foreground, lineWidth: 1))
                                        .padding(.leading)
                                    VStack(alignment:.leading){
                                        HStack(alignment:.center) {
                                            Text("\(data["givenName"] as? String ?? "Anon") \(data["familyName"] as? String ?? "Anon")")
                                                .font(.system(size:16, weight:.semibold))
                                                .foregroundColor(Color.theme.foreground)
                                            Text("\(utils.getDateFormat(format: "mdy").string(from: (comment.data["Timestamp"] as? Timestamp ?? Timestamp()).dateValue()))")
                                                .font(.system(size:12))
                                                .foregroundColor(Color.theme.accent)
                                        }
                                        Text(comment.data["name"] as? String ?? "Unknown Content")
                                            .font(.system(size:14))
                                            .foregroundColor(Color.theme.foreground)
                                    }
                                }
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: {
            getComments()
        })
        .navigationTitle(isFullScreen ? email : "")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(Color.theme.foreground)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                isFullScreen ? BackButtonView(dismiss: self.dismiss) : nil
            }
        }
        .background(Color.theme.background)
    }
    
    @State var cid: Int = -1
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
    
    private func makeComment() {
        let name = commentString
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        fetchId()
        group.notify(queue: .main) {
            let comment = Comment(data: ["email": email, "id": cid, "name": name, "timestamp": Timestamp()] as [String: Any])
            commentData.append(comment)
            FirebaseManager.getUserData(email: email) { data in
                commentUserData.append(data)
            }
            path
                .document("\(cid)")
                .setData(comment.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                    commentString = ""
                }
        }
    }
    
    @State var commentData: [Comment] = []
    @State var commentUserData: [[String: Any?]] = []
    func getComments() {
        path
            .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                let documents: [QueryDocumentSnapshot] = snapshot?.documents ?? []
                var commentData: [Comment] = []
                for document in documents {
//                    let data = document.data()
                    commentData.append(Comment(data: document.data()))
//                    if _public || (data["email"] as? String ?? "") == email || (data["email"] as? String ?? "") == emailB {
//                        commentData.append(Comment(data: document.data()))
//
//                    }
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
        path
            .document("\(cid)").delete() { err in
                if let err = err {
                    print(err)
                    return
                }
            }
    }
}
//
//struct CommentsView_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentsView()
//    }
//}
