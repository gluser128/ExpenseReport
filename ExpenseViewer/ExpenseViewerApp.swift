//
//  ExpenseViewerApp.swift
//  ExpenseViewer
//
//  Created by Gary Chen on 9/7/21.
//

import SwiftUI

@main
struct ExpenseViewerApp: App {
    var body: some Scene {
        WindowGroup {
            let settings = ExpenseSettings()
            ExpenseSummaryView().environmentObject(settings)
        }
    }
}
