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
            withAnimation {
                dismiss()
            }
        } label: {
            HStack {
                Image(systemName: "arrow.left")
                    .foregroundColor(Color.theme.accent)
            }
        }
    }
}

//struct BackButtonView_Previews: PreviewProvider {
//    static var previews: some View {
//        BackButtonView()
//    }
//}
