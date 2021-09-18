//
//  ProgressCover.swift
//  symbolicate
//
//  Created by Naruki Chigira on 2021/01/19.
//

import SwiftUI

struct ProgressCover: View {
    @Binding var value: Int
    @Binding var total: Int

    var body: some View {
        ZStack {
            Color(white: 1, opacity: 0.95)
            VStack {
                Text("Symbolicating... \(value)/\(total)")
                ProgressView("", value: Float(value), total: Float(total))
            }
            .padding(64)
        }
    }
}
