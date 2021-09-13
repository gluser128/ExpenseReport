//
//  FormView.swift
//  ExpenseViewer
//
//  Created by Gary Chen on 9/9/21.
//

import SwiftUI

struct InputFormView : View {
    @EnvironmentObject var settings: ExpenseSettings

    @Environment(\.presentationMode) var presentationMode

    @State private var category = ExpenseCategory.food
    @State private var amount = "0.0"
    @State private var date = Date()
    
    @State private var showingAlert = false
    
    private var currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        return f
    }()
        
    var body: some View {
        VStack {

            HStack {
                // Disallow dates in the future
                DatePicker(
                    "Date",
                    selection: $date,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .padding()
            }
            
            HStack {
                Text("Category")
            
                Picker("Category", selection: $category) {
                    ForEach(ExpenseCategory.allCases, id: \.self) { value in
                        Text(value.localizedName)
                    }
                }
            }
            .padding()
            
            HStack {
                Text("Amount")
                TextField("$0.0", text: $amount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
            .padding()
            
            Spacer()
            
            Button("Add") {

                // TODO:
                // Validate date and amount
                // Amount should be greater than 0 and date should not be in the future
                let dollarAmount = Double(amount) ?? 0
                if dollarAmount <= 0 {
                    showingAlert = true
                }
                else {
                    let item = ExpenseItem(amount: Double(amount) ?? 0,
                                           date: date,
                                           category: category)
                    settings.expenseItems.append(item)
                    
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .alert(isPresented:$showingAlert) {
                Alert(
                    title: Text("Invalid"),
                    message: Text("Amount less or equal to zero"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .frame(minWidth: 0, maxWidth: 200)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(40)
        }
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        InputFormView()
    }
}
