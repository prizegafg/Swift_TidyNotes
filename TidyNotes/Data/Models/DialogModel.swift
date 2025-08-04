//
//  DialogModel.swift
//  TidyNotes
//
//  Created by Prizega Fromadia on 04/08/25.
//

struct DialogModel {
    let title: String
    let message: String
    let confirmText: String
    let cancelText: String
    let onConfirm: () -> Void
}
