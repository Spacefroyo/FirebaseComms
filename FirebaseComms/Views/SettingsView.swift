//
//  SettingsView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/7/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn
import FirebaseAnalytics
import FirebaseMessaging

struct SettingsView: View {
    
    
    
    //Add profilePicUrl changer here!!!!!
    
    @AppStorage("email") var email: String!
    @AppStorage("givenName") var givenName: String!
    @AppStorage("familyName") var familyName: String!
    @AppStorage("profilePicUrl") var profilePicUrl: URL!
    @AppStorage("log_Status") var log_Status = true
    @AppStorage("view_Id") var view_Id = 1
    @AppStorage("darkmode") var darkmode: Bool = false
    @State var profilePic: UIImage?
    @State var loading: Bool = false
    @State var firstName = "First Name"
    @State var lastName = "Last Name"
    @State var presentImagePicker: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background
                    .ignoresSafeArea()
                ScrollView{
                    Button {
                        presentImagePicker = true
                    } label: {
                        if let image = profilePic {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 128, height: 128)
                                .cornerRadius(64)
                        } else {
                            Image(uiImage: UIImage(data: try! Data(contentsOf: profilePicUrl ?? constants.defaultUrl))!)
                                .resizable()
                                .clipped()
                                .cornerRadius(64)
                                .frame(width: 128, height: 128)
                        }
                    }
                    
                    Group{
                        TextField("First Name", text: $firstName)
                            .font(.system(size:24))
                        
                        TextField("Last Name", text: $lastName)
                            .font(.system(size:24))
                    }
                    .padding()
                    .background(Color.theme.accent)
                    .foregroundColor(Color.theme.foreground)
                    .cornerRadius(15)
                    
                    HStack {
                        Text("Appearance: ")
                        Spacer()
                        Picker(selection: $darkmode, label: Text("Picker here")) {
                            Text("Light")
                                .tag(false)
                            Text("Dark")
                                .tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    Button {
                        givenName = firstName
                        familyName = lastName
                        if profilePic != nil {
                            persistImageToStorage()
                        } else {
                            storeUserInformation(givenName: givenName, familyName: familyName, profilePicUrl: profilePicUrl)
                        }
                    } label: {
                        Text(loading ? "Uploading settings... (Do not exit app)" : "Save Changes")
                            .padding()
                            .foregroundColor(Color.theme.foreground)
                    }
                    .disabled(loading)
                    
                    Button{
                        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
                        Messaging.messaging().token { token, error in
                            if let error = error {
                                print("Error fetching FCM registration token: \(error)")
                            } else if let token = token {
                                print("FCM registration token: \(token)")
//                                Messaging.messaging().unsubscribe(fromTopic: email) { error in
//                                  print("Unsubscribed from user \(email)")
//                                }
                                let document = FirebaseManager.shared.firestore.collection("logins").document(email)
                                document.getDocument { snapshot, error in
                                    if let error = error {
                                        print("Failed to fetch current user: ", error)
                                        return
                                    }

                                    let data = snapshot?.data()
                                    var tokens = data?["tokens"] as? [String] ?? []
                                    tokens.removeAll { str in
                                        str == token
                                    }
                                    document.setData(["tokens": tokens])
                                    GIDSignIn.sharedInstance.signOut()
                                    try? FirebaseManager.shared.auth.signOut()
                                    withAnimation {
                                        log_Status = false
                                        view_Id = 0
                                    }
                                }
                            }
                        }
                    } label: {
                        Text("Logout")
                            .foregroundColor(Color.red)
                    }
                }
                .padding()
                .frame(alignment: .top)
                .onAppear(perform: {
                    firstName = givenName
                    lastName = familyName
                })
                .navigationTitle("Settings")
                .fullScreenCover(isPresented: $presentImagePicker) {
                    ImagePicker(image: $profilePic)
                        .ignoresSafeArea()
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
        }
    }
    
    private func storeUserInformation(givenName: String, familyName: String, profilePicUrl: URL) {
        loading = true
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        let userData = ["email": email, "givenName": givenName, "familyName": familyName, "profilePicUrl": profilePicUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(email).setData(userData) { err in
                loading = false
                if let err = err {
                    print(err)
                    return
                }
            }
    }
    
    private func persistImageToStorage() {
        loading = true
        guard let email = FirebaseManager.shared.auth.currentUser?.email else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: email)
        guard let imageData = self.profilePic?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print("Failed to push image to Storage: \(err)")
                return
            }

            ref.downloadURL { url, err in
                if let err = err {
                    print("Failed to retrieve downloadURL: \(err)")
                    return
                }
                
                profilePicUrl = url ?? constants.defaultUrl
                if FirebaseManager.seenUsers[email] != nil {
                    FirebaseManager.seenUsers[email]?["profilePicUrl"] = profilePicUrl.absoluteString
                }
                loading = false
                storeUserInformation(givenName: givenName, familyName: familyName, profilePicUrl: profilePicUrl)
            }
        }
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
