//
//  InputField.swift
//  symbolicate
//
//  Created by Naruki Chigira on 2021/01/19.
//

import SwiftUI

struct InputField: View {
    let name: String
    @Binding var input: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .foregroundColor(Color("Field"))
                .font(.system(.headline))
            TextField("", text: $input)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(.body, design: .monospaced))
                .foregroundColor(Color("Contents"))
        }
    }
}
