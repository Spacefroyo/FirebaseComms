//
//  AnnouncementsView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/6/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn

class BroadcastsViewModel: ObservableObject {
    init() {
        fetchCurrentUser()
    }
    
    @Published var dat = ""
    @AppStorage("email") var email : String!
    @AppStorage("givenName") var givenName : String!
    @AppStorage("familyName") var familyName : String!
    @AppStorage("profilePicUrl") var profilePicUrl : URL!
    
//    @AppStorage("log_Status") var log_Status = false

    private func fetchCurrentUser() {
        guard let email = FirebaseManager.shared.auth.currentUser?.email else {return}
        
        FirebaseManager.shared.firestore.collection("users").document(email).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user: ", error)
                return
            }
            guard let data = snapshot?.data() else {
//                self.dat = "No data"
                return
            }
//            let uid = data["uid"] as? String ?? ""
            self.email = data["email"] as? String ?? ""
            self.givenName = data["givenName"] as? String ?? ""
            self.familyName = data["familyName"] as? String ?? ""
            self.profilePicUrl = URL(string: data["profilePicUrl"] as? String ?? "")
//            let user = User(uid: uid)
            self.dat = "Data: \(data.description)"
        }
        
    }
}

struct BroadcastsView: View {
    @State var loading: Bool = true

    @ObservedObject private var vm = BroadcastsViewModel()
    @AppStorage("log_Status") var log_Status = true
    
    @AppStorage("email") var email : String?
    @AppStorage("givenName") var givenName : String?
    @AppStorage("familyName") var familyName : String?
    @AppStorage("profilePicUrl") var profilePicUrl : URL?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                VStack {
    //                Button("Logout"){
    //                    GIDSignIn.sharedInstance.signOut()
    //                    try? FirebaseManager.shared.auth.signOut()
    //                    withAnimation {
    //                        log_Status = false
    //                    }
    //                }
    //                Text("User data: \(vm.dat)")
                    HStack(spacing:16) {
                        Image(uiImage: UIImage(data: try! Data(contentsOf: profilePicUrl ?? constants.defaultUrl))!)
                            .resizable()
                            .clipped()
                            .cornerRadius(16)
                            .frame(width: 32, height: 32)
                            
                        Text("\(givenName ?? "First") \(familyName ?? "Last")")
                            .font(.system(size:24, weight:.bold))
                            .foregroundColor(Color.theme.foreground)
                        
                        Spacer()
                        
//                        Button {
//                            view_Sent = !view_Sent
//                        } label: {
//                            Text(view_Sent ? "Sent" : "Received")
//                                .foregroundColor(Color.theme.foreground)
//                        }
                        
                        Menu {
                            Picker (inbox, selection: $inbox) {
                                ForEach(BroadcastsView.inboxes.allCases) { inbox in
                                    Text(inbox.rawValue.capitalized)
                                        .tag(inbox.rawValue)
                                }
                            }
                        } label: {
                            Text(inbox.capitalized)
                        }
                        .foregroundColor(Color.theme.foreground)
//                        .frame(width: 100, alignment: .center)
                    }
                    .padding()
                    
                    received
                    
//                    if view_Sent {
//                        sent
//                    } else {
//                        received
//                    }
                }
            }
            
        }
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
//        .onAppear(perform: setBroadcastViews)
//        .onAppear(perform: {sentBroadcasts = ""})
    }
    
//    @State var view_Sent = false
    @State var inbox: String = inboxes.all.rawValue
    enum inboxes: String, CaseIterable, Identifiable {
        case all, received, sent
        var id: Self { self }
    }
//    @AppStorage("sentBroadcasts") var sentBroadcasts: String?
//    @State var loadedSentBroadcasts: [Broadcast] = []
//
//    private func getSentBroadcasts() -> [Broadcast] {
////        sentBroadcasts = ""
//        let arr: [String] = sentBroadcasts?.components(separatedBy: constants.seperator) ?? []
//        var loadedSentBroadcasts: [Broadcast] = []
//        for str in arr {
//            if !str.isEmpty {
//                loadedSentBroadcasts.append(Broadcast(str: str))
//            }
//        }
//        loadedSentBroadcasts.sort (by: {
//            $0.data["id"] as? Int ?? -1 > $1.data["id"] as? Int ?? -1
//        })
//        return loadedSentBroadcasts
//    }
    
    @State var broadcastViews: [BroadcastView] = []
//    func setBroadcastViews() {
//        loadedSentBroadcasts = getSentBroadcasts()
//        broadcastViews = []
//        var viewId = 0
//        for broadcast in loadedSentBroadcasts {
//            FirebaseManager.getUserData(email: broadcast.data["email"] as! String) { data in
//                broadcastViews.append(BroadcastView(id: viewId, broadcast: broadcast, data: data, from: self))
//                viewId += 1
//            }
////            FirebaseManager.shared.firestore.collection("uids").document(broadcast.data["email"] as! String).getDocument { snapshot, error in
////                if let error = error {
////                    print("Failed to fetch current user: ", error)
////                    return
////                }
////                guard let data = snapshot?.data() else { return }
////
////            }
//        }
////        print("done")
//    }
    
//    private var sent: some View {
//        ScrollView {
//            if broadcastViews.count > 0 {
//                ForEach(broadcastViews) { broadcastView in
//                    broadcastView
//                }
//            } else {
//                Text("No sent announcements or events")
//                    .foregroundColor(Color.theme.accent)
//                    .padding()
//            }
//        }
//        .navigationBarHidden(true)
//        .onAppear(perform: setBroadcastViews)
//    }
    
//    @AppStorage("follows") var follows: String?
    @State var loadedFollows: [String] = []
//    func storeFollow(email: String) {
//        follows = "\(email)~\(follows ?? "")"
//    }
    
//    private func getFollows() {
//        print("PRE")
//
//    }
    
//completion: @escaping ([String:Any]) -> ()
    @AppStorage("receivedBroadcasts") var receivedBroadcasts: String?
    @State var loadedReceivedBroadcasts: [Broadcast] = []
    @State var inGroup = false
    private let group = DispatchGroup()
//    private var firestoreListener: ListenerRegistration?
    func updateReceivedBroadcasts() {
//        firestoreListener?.remove()
//        getFollows()
        group.enter()
        FirebaseManager.shared.firestore.collection("connections").document(email ?? "").getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch current user: ", error)
                return
            }
            let data = snapshot?.data()
            loadedFollows = data?["follows"] as? [String] ?? []
            var loadedFollows = loadedFollows
            loadedFollows.append(email ?? "")
            inGroup = true
    //        var loadedReceivedBroadcasts = self.loadedReceivedBroadcasts
            var m = loadedFollows.count
            for follow in loadedFollows {
                group.enter()
                m -= 1
                let collection = FirebaseManager.shared.firestore
                    .collection("broadcasts")
                    .document(follow)
                    .collection("sent")
    //                        .order(by: "timestamp")
                collection.addSnapshotListener { querySnapshot, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    var n = querySnapshot?.documentChanges.count ?? 0
                    if (n == 0) {
                        if inGroup { group.leave() }
                    }
                    querySnapshot?.documentChanges.forEach({ change in
    //                        group.enter()
                        let data = change.document.data()
                        if change.type == .added {
                            loadedReceivedBroadcasts.append(Broadcast(data: data))
                        } else if change.type == .modified {
                            changeBroadcast(broadcast: Broadcast(data: data))
                        } else if change.type == .removed {
                            changeBroadcast(broadcast: Broadcast(data: ["id": data["id"] as? Int ?? -1]))
                        }
    //                    print("change occured \(data)")
    //                    print(loadedReceivedBroadcasts.count)
                        n -= 1
                        if (n == 0) {
                            if inGroup { group.leave() }
                        }
    //                        group.leave()
                    })
    //                if inGroup { group.leave() }
                }
                if (m == 0) {
                    if inGroup { group.leave() }
                }
    //            group.leave()
            }
            
        }
        //happens before above!!!!!!!!!!!!!!!!!!!
        receivedBroadcasts = ""
        for broadcast in loadedReceivedBroadcasts {
            storeBroadcast(broadcast: broadcast)
        }
    }
    
    func getBroadcasts() {
//        let arr: [String] = receivedBroadcasts?.components(separatedBy: Constants.seperator) ?? []
        loadedReceivedBroadcasts = []
//        for str in arr {
//            if !str.isEmpty {
//                loadedReceivedBroadcasts.append(Broadcast(str: str))
//            }
//        }
        updateReceivedBroadcasts()
    }
    
    private func storeBroadcast(broadcast: Broadcast) {
        receivedBroadcasts = "\(broadcast.toString())~\(receivedBroadcasts ?? "")"
    }
    
    private func changeBroadcast(broadcast: Broadcast) {
        for i in 0..<loadedReceivedBroadcasts.count {
            if loadedReceivedBroadcasts[i].data["id"] as? Int ?? -1 == broadcast.data["id"] as? Int ?? -1 {
                if broadcast.data.count != 1 {
                    loadedReceivedBroadcasts[i] = broadcast
                } else {
                    loadedReceivedBroadcasts.remove(at: i)
                }
                return
            }
        }
    }
    
    func receivedBroadcastViews() {
        loading = true
        getBroadcasts()
//        print(loadedReceivedBroadcasts.count)
        group.notify(queue: .main) {
            inGroup = false
//            loadedReceivedBroadcasts.sort (by: {
//                $0.data["id"] as? Int ?? -1 > $1.data["id"] as? Int ?? -1
//            })
//            print(loadedReceivedBroadcasts.description)
            var viewId = 0
            var broadcastViews: [BroadcastView?] = Array(repeating: nil, count: loadedReceivedBroadcasts.count)
//            var FirebaseManager.seenUsers: [String: [String: Any]] = [:]
            let viewGroup = DispatchGroup()
            for i in 0..<loadedReceivedBroadcasts.count{
//            for broadcast in loadedReceivedBroadcasts {
                let broadcast = loadedReceivedBroadcasts[i]
                viewGroup.enter()
                let email = broadcast.data["email"] as! String
                let data = FirebaseManager.seenUsers[email] ?? [:]
                if data.isEmpty {
                    FirebaseManager.getUserData(email: email) { data in
                        broadcastViews[i] = BroadcastView(id: viewId, broadcast: broadcast, data: data, from: self)
                        viewId += 1
                        viewGroup.leave()
                    }
                } else {
                    broadcastViews[i] = BroadcastView(id: viewId, broadcast: broadcast, data: data, from: self)
                    viewId += 1
                    viewGroup.leave()
                }
            }
            viewGroup.notify(queue: .main) {
                broadcastViews.sort (by: {
                    $0!.broadcast.data["id"] as? Int ?? -1 > $1!.broadcast.data["id"] as? Int ?? -1
                })
                self.broadcastViews = broadcastViews as! [BroadcastView]
                loading = false
            }

        }
    }
    
//    @State var expand: Bool = false
    
    private var received: some View {
        ScrollView {
            PullToRefresh(coordinateSpaceName: "pullToRefresh") {
                receivedBroadcastViews()
            }
            if broadcastViews.count > 0 {
                ForEach(broadcastViews) { broadcastView in
                    let fromCurrentUser = broadcastView.broadcast.data["email"] as? String == email
                    if ((inbox == "all") || (fromCurrentUser && inbox == "sent") || (!fromCurrentUser && inbox == "received")) {
                        broadcastView
                    }
                }
            } else {
                Text("No \(inbox == "all" ? "" : inbox + " ")announcements or events")
                    .foregroundColor(Color.theme.accent)
                    .padding()
            }
        }
        .coordinateSpace(name: "pullToRefresh")
        .navigationBarHidden(true)
        .onAppear(perform: receivedBroadcastViews)
    }
}

struct AnnouncementsView_Previews: PreviewProvider {
    static var previews: some View {
        BroadcastsView()
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
