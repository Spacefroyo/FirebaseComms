//
//  BackButtonView.swift
//  FirebaseComms
//
//  Created by Peter Gao on 8/29/22.
//

import SwiftUI

struct BackButtonView: View {
    let dismiss: DismissAction
    var body: some View {
        Button {
            dismiss()
        } label: {
            HStack {
                Image(systemName: "arrow.left")
//                Text("Back")
            }
        }
    }
}

//struct BackButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        BackButtonView()
//    }
//}
