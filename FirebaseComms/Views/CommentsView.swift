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
    let path: CollectionReference?
    let email: String
    @AppStorage("givenName") var givenName: String!
    @AppStorage("familyName") var familyName: String!
    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isPresented
    @State var loading: Bool = true
    
    init(broadcast: Broadcast, path: CollectionReference) {
        self.broadcast = broadcast
        self._public = true
        self.email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        self.path = path
    }
    
    init(broadcast: Broadcast, email: String, path: CollectionReference) {
        self.broadcast = broadcast
        self._public = false
        self.email = email
        var userSort: [String] = [email, FirebaseManager.shared.auth.currentUser?.email ?? ""]
        userSort.sort (by: {
            $0.compare($1) == .orderedAscending
        })
        self.path = path.parent?.parent.parent?.parent.collectionID ?? "" == "messages" ?
        path.parent?.parent.parent?.parent
            .document(userSort[0])
            .collection("privateChannels")
            .document(userSort[1])
            .collection("comments")
        : path
    }
    
    @State var commentString: String = ""
    var body: some View {
        VStack {
//            VStack {
            HStack {
                if #available(iOS 16.0, *) {
                    TextField("Add \(_public ? "Public" : "Private") Comment", text: $commentString, axis: .vertical)
                        .padding([.leading, .trailing], 11)
                        .padding([.top, .bottom], 8)
                        .frame(maxHeight: 100)
                } else {
                    ZStack (alignment: .topLeading){
                        Text("Add \(_public ? "Public" : "Private") Comment")
                            .foregroundColor(Color.theme.accent)
                            .padding()
                            .opacity(commentString == "" ? 1 : 0)
                        
                        TextEditor(text: $commentString)
                            .padding([.leading, .trailing], 11)
                            .padding([.top, .bottom], 8)
                            .frame(maxHeight: 100)
                    }
                }
                
                
                Spacer()
                    
                    
                Button {
                    makeComment(name: commentString)
                } label: {
                    Image(systemName: "arrow.right")
                }
                .disabled(commentString.isEmpty)
                .padding([.top, .bottom], 2)
                .padding([.trailing])
            }
            
            Spacer()
            
            Divider()
                .padding(.bottom)
            
            
            ScrollView {
                PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                    getComments()
                }
                VStack {
                    if commentData.count == 0 {
                        Text("No comments yet")
                    }
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
            .coordinateSpace(name: "pullToRefresh")
//            }
        }
        .onAppear(perform: {
            getComments()
        })
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                isPresented ? BackButtonView(dismiss: self.dismiss) : nil
            }
        }
        .navigationTitle(email)
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(Color.theme.foreground)
        .background(Color.theme.background)
        .overlay(
            ZStack{
                if loading {
                    Color.black
                        .opacity(0.25)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(Color.theme.background)
                        .cornerRadius(10)
                }
            }
        )
        .onTapGesture (count: 2){
            hideKeyboard()
        }
    }
    
    @State var cid: Int = -1
    private let group = DispatchGroup()
    private func fetchId(){
//        print("Fetch")
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
//                print("Fetched ", cid)
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
    
    private func makeComment(name: String) {
        commentString = ""
        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        fetchId()
        group.notify(queue: .main) {
            let comment = Comment(data: ["email": email, "id": cid, "name": name, "timestamp": Timestamp()] as [String: Any])
            FirebaseManager.getUserData(email: email) { data in
                commentUserData.append(data)
                commentData.append(comment)
            }
            updateRead(status: false)
            path?
                .document("\(cid)")
                .setData(comment.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                }
            if !_public {
                PushNotificationSender().push(emails: [self.email], title: "\(String(describing: givenName)) \(String(describing: familyName)) has sent you a private message", body: name)
            }
        }
    }
    
    private func updateRead(status: Bool) {
        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        if (!_public) {
            path?
                .parent?
                .setData(["commentsReadBy\(status != (broadcast.data["id"] as? Int ?? -1 == -1 ? email.compare(self.email) == .orderedAscending : email == broadcast.data["email"] as? String ?? "") ? "Receiver" : "Sender")": status], merge: true)
        }
    }
    
    @State var commentData: [Comment] = []
    @State var commentUserData: [[String: Any?]] = []
    func getComments() {
        loading = true
        path?
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
                    updateRead(status: true)
                    loading = false
                }
            }
    }
    
    func deleteComment(comment: Comment) {
        path?
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
