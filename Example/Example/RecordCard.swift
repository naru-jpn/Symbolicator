//
//  RecordCard.swift
//  symbolicate
//
//  Created by Naruki Chigira on 2021/01/19.
//

import SwiftUI
import Symbolicator

struct RecordCard: View {
    let record: Record<SymbolicatedDLADDR>

    var body: some View {
        ZStack {
            Color.white
                .cornerRadius(8)
                .shadow(color: .gray, radius: 2, x: 0, y: 1)
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(record.architecture)")
                        .font(.system(.headline, design: .monospaced))
                        .foregroundColor(Color("Field"))
                    ForEach(record.callStack, id: \.self) { row in
                        Text(row)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(Color("Contents"))
                    }
                }
                Spacer()
            }
            .padding(12)
        }
        .padding(6)
    }
}
