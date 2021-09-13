//
//  ExpenseItemView.swift
//  ExpenseViewer
//
//  Created by Gary Chen on 9/9/21.
//

import SwiftUI

struct ExpenseItemView : View {
    
    let item: ExpenseItem
        
    func dateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: item.date)
    }
        
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(item.category.localizedName)
                .frame(maxWidth: .infinity)
            Text(dateToString())
                .frame(maxWidth: .infinity)
            Text("$"+String(item.amount))
                .frame(maxWidth: .infinity)
        }
    }
}
