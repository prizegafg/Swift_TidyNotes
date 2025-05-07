//
//  TaskDetailView.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/05/25.
//

import SwiftUI
import Combine


// MARK: - View Implementation

/// View yang menampilkan detail task dan catatan yang terkait
struct TaskDetailView: View {
    @ObservedObject var presenter: TaskDetailPresenter

    var body: some View {
        VStack(spacing: 16) {
            headerView
            noteEditorView
            Spacer()
        }
        .padding()
        .navigationTitle("Detail Tugas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Simpan") {
                    presenter.saveNote()
                }
                .disabled(!presenter.isNoteChanged)
            }
        }
        .onAppear {
            presenter.viewDidLoad()
        }
        .alert(isPresented: $presenter.showError) {
            Alert(
                title: Text("Error"),
                message: Text(presenter.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Catatan")
                .font(.headline)
            Text("Terakhir diperbarui: \(presenter.lastUpdatedFormatted)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var noteEditorView: some View {
        TextEditor(text: $presenter.noteContent)
            .onChange(of: presenter.noteContent) { newValue in
                presenter.noteContentChanged(newValue)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .frame(maxWidth: .infinity, minHeight: 200)
    }
}
