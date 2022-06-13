//
//  SettingsView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 6/7/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct SettingsView: View {
    
    @AppStorage("email") var email: String!
    @AppStorage("givenName") var givenName: String!
    @AppStorage("familyName") var familyName: String!
    @AppStorage("profilePicUrl") var profilePicUrl: URL!
    @AppStorage("log_Status") var log_Status = true
    @AppStorage("view_Id") var view_Id = 1
    @State var firstName = ""
    @State var lastName = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Settings")
                    .font(.system(size: 32, weight: .bold))
                
                Spacer()
                
                Button{
                    GIDSignIn.sharedInstance.signOut()
                    try? FirebaseManager.shared.auth.signOut()
                    withAnimation {
                        log_Status = false
                        view_Id = 0
                    }
                } label: {
                    Text("Logout")
                        .padding()
                }
                .background(Color.white)
            }
            
            ScrollView{
                Group{
                    TextField("First Name", text: $firstName)
                        .font(.system(size:24))
                    TextField("Last Name", text: $lastName)
                        .font(.system(size:24))
                }
                .padding(12)
                .background(Color.white)
                
                Button {
                    givenName = firstName
                    familyName = lastName
                    storeUserInformation(email: email, givenName: givenName, familyName: familyName, profilePicUrl: profilePicUrl)
                } label: {
                    Text("Save Changes")
                        .padding()
                }
                .background(Color.white)
            }
            
            
        }
        .frame(alignment: .top)
        .onAppear(perform: {
            firstName = givenName
            lastName = familyName
        })
        .padding()
    }
    
    private func storeUserInformation(email: String, givenName: String, familyName: String, profilePicUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["uid": uid, "email": email, "givenName": givenName, "familyName": familyName, "profilePicUrl": profilePicUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    return
                }
            }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
