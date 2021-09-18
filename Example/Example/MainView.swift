//
//  MainView.swift
//  symbolicate
//
//  Created by Naruki Chigira on 2021/01/14.
//

import SwiftUI
import Symbolicator

struct MainView: View {
    /// Path of appDsyms directory.
    @State private var dsymPath: String = ""
    /// Path of csv file.
    @State private var csvPath: String = ""

    /// Symbolicated records.
    @State private var records: [Record<SymbolicatedDLADDR>] = []
    /// Error message about symbolication.
    @State private var errorMessage: String = ""

    /// Number of already symbolicated records.
    @State private var completed: Int = 0
    /// Number of records to symbolicate.
    @State private var total: Int = 0
    /// Processing symbolication or not.
    @State private var isProgressing: Bool = false

    /// Processing symbolication is completed or not.
    @State private var isSymbolicationCompleted: Bool = false
    /// Control to share outputAll.
    @State private var shouldExportOutputAll: Bool = false
    /// Control to share outputAggregated.
    @State private var shouldExportOutputAggregated: Bool = false
    /// Document enumerating all symbolicated records.
    @State private var outputAll: CSVDocument = CSVDocument(content: "")
    /// Document aggregated symbolicated records.
    @State private var outputAggregated: CSVDocument = CSVDocument(content: "")

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .center, spacing: 8) {
                    InputField(name: "dSYM Files Directory Path", input: $dsymPath)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        handleDSYMProviders(providers: providers)
                        return true
                    }
                    InputField(name: "CSV File Path", input: $csvPath)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        handleCSVProviders(providers: providers)
                        return true
                    }
                    Button("Symbolicate") {
                        symbolicate()
                    }
                    .padding(8)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Preview Result")
                            .foregroundColor(Color("Field"))
                            .font(.system(.headline))
                        Spacer()
                        if isSymbolicationCompleted {
                            Button("Export All Records") {
                                shouldExportOutputAll = true
                            }
                            .fileExporter(isPresented: $shouldExportOutputAll, document: outputAll, contentType: .commaSeparatedText, defaultFilename: "result.csv") { result in
                            }
                            Button("Export Aggregated Result") {
                                shouldExportOutputAggregated = true
                            }
                            .fileExporter(isPresented: $shouldExportOutputAggregated, document: outputAggregated, contentType: .commaSeparatedText, defaultFilename: "result_aggregated.csv") { result in
                            }
                        }
                    }
                    ZStack {
                        Color.white
                        List(records) { record in
                            RecordCard(record: record)
                        }
                        Text(errorMessage)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(Color("Error"))
                    }
                    .cornerRadius(8)
                }
            }
            .padding(16)
            if isProgressing {
                ProgressCover(value: $completed, total: $total)
            }
        }
    }
}

// MARK: Symbolication
extension MainView {
    private func symbolicate() {
        errorMessage = ""
        isProgressing = true
        DispatchQueue.global().async {
            do {
                let csv = CSV(path: csvPath)
                let symbolicator = try Symbolicator(dSYMsDirectoryPath: dsymPath)
                self.records = symbolicator.symbolicate(records: csv.records, delegate: self)
                createSharedContents(with: self.records)
            } catch {
                self.errorMessage = error.localizedDescription
            }
            DispatchQueue.main.async {
                isProgressing = false
            }
        }
    }

    private func createSharedContents(with symbolicatedRecords: [Record<SymbolicatedDLADDR>]) {
        // Create output enumerating all records.
        outputAll = .init(
            content: "architecture,call_stack\n" + symbolicatedRecords
                .map {
                    "\($0.architecture),\"\($0.callStack.joined(separator: "\r"))\""
                }
                .joined(separator: "\n")
        )
        // Create aggregated output.
        outputAggregated = .init(
            content: "count,call_stack\n" + symbolicatedRecords.aggregate()
                .map {
                    "\($0.count),\"\($0.callStack)\""
                }
                .joined(separator: "\n")
        )
    }
}

// MARK: File Drag & Drop
extension MainView {
    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    private func handleDSYMProviders(providers: [NSItemProvider]) {
        guard let provider = providers.first else {
            return
        }
        provider.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
            guard let data = data, let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            self.dsymPath = url.path
        }
    }

    private func handleCSVProviders(providers: [NSItemProvider]) {
        guard let provider = providers.first else {
            return
        }
        provider.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
            guard let data = data, let url = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            self.csvPath = url.path
        }
    }
}

// MARK: SymbolicatorDelegate
extension MainView: SymbolicatorDelegate {
    func didStartSymbolicate(_ symbolicator: Symbolicator, total: Int) {
        self.completed = 0
        self.total = total
    }

    func didUpdateProgressToSymbolicate(_ symbolicator: Symbolicator, completed: Int, total: Int) {
        self.completed = completed
    }

    func didCompleteSymbolicate(_ symbolicator: Symbolicator, total: Int) {
        self.completed = total
        isSymbolicationCompleted = true
    }
}
