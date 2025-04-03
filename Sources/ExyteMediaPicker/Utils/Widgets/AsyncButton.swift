//
//  SwiftUIView.swift
//  
//
//  Created by Alisa Mylnikova on 01.04.2025.
//

import SwiftUI

struct AsyncButton<Content: View>: View {
    var action: () async -> ()
    var label: (()->Content)

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            label()
        }
    }
}
