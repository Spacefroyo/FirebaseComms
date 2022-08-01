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
                            changeComment(comment: Comment(data: ["id": cid]))
                        } label: {
                            Image(systemName: "arrow.right")
                        }
                    }
                    
                    Spacer()
                }
                
                Divider()
                
                VStack {
                    TextField("Add Private Comment", text: $privateComment)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func storeCommentInformation(name: String, public: Bool) {
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        if name != "" {
            let announcement = Broadcast(data: ["email": email, "id": cid, "name": name, "timestamp": Timestamp()] as [String: Any])
//            changeBroadcast(broadcast: announcement)
            FirebaseManager.shared.firestore.collection("broadcasts")
                .document(email).collection("sent").document("\(cid)").setData(announcement.data) { err in
                    if let err = err {
                        print(err)
                        return
                    }
                }
        } else {
            fetchId()
            group.notify(queue: .main) {
                let announcement = Broadcast(data: ["email": email, "id": cid, "name": name, "timestamp": Timestamp()] as [String: Any])
                storeBroadcast(broadcast: announcement)
                FirebaseManager.shared.firestore.collection("broadcasts")
                    .document(email).collection("sent").document("\(cid)").setData(announcement.data) { err in
                        if let err = err {
                            print(err)
                            return
                        }
                    }
            }
        }
    }
    
    private let group = DispatchGroup()
    private func fetchId(){
        group.enter()
        DispatchQueue.main.async {
//            if id != -1 {
//                group.leave()
//                return
//            }
            let document = FirebaseManager.shared.firestore.collection("data").document("commentId")
            document.getDocument { snapshot, error in
                if let error = error {
                    print("Failed to fetch commentId document: ", error)
                    return
                }
                
                guard let data = snapshot?.data() else {return}
                cid = data["id"] as? Int ?? 0
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
    
    @AppStorage("sentBroadcasts") var sentBroadcasts: String?
    private func storeBroadcast(broadcast: Broadcast) {
        sentBroadcasts = "\(broadcast.toString())~\(sentBroadcasts ?? "")"
    }
    
    private func changeComment(comment: Comment) {
        let arr: [String] = sentBroadcasts?.components(separatedBy: Constants.seperator) ?? []
        var loadedSentBroadcasts: [Broadcast] = []
        for str in arr {
            if !str.isEmpty {
                let thisBroadcast: Broadcast = Broadcast(str: str)
                if thisBroadcast.data["id"] as? Int ?? -1 == broadcast.data["id"] as? Int ?? -1 {
                    if broadcast.data.count != 1 {
                        loadedSentBroadcasts.append(broadcast)
                    }
                } else {
                    loadedSentBroadcasts.append(thisBroadcast)
                }
            }
        }
        if broadcast.data.count == 1 {
            deleteBroadcast(broadcast: broadcast)
        }
//        loadedSentBroadcasts[broadcast.data["id"] as? Int ?? 0] = broadcast
        sentBroadcasts = ""
        for broadcast in loadedSentBroadcasts {
            storeBroadcast(broadcast: broadcast)
        }
    }
    
    func deleteBroadcast(broadcast: Broadcast) {
        let email = FirebaseManager.shared.auth.currentUser?.email ?? ""
        FirebaseManager.shared.firestore.collection("broadcasts")
            .document(email).collection("sent").document("\(id)").delete() { err in
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
