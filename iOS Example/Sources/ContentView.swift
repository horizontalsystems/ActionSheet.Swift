//
//  ContentView.swift
//  iOS Example
//
//  Created by Anton on Nov 26, 2021.
//

import SwiftUI
import ActionSheet

struct SwiftUIActionSheet: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            SwiftUIActionSheet()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
