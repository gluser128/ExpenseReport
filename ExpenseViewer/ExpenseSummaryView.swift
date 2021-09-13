//
//  ContentView.swift
//  ExpenseViewer
//
//  Created by Gary Chen on 9/8/21.
//

import SwiftUI

enum GroupingType {
    case date
    case amount
    case category
}

enum ExpenseCategory: String, Equatable, CaseIterable {
    case food = "Food"
    case entertainment = "Entertainment"
    case transportation = "Transportation"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    
    static func allCasesStrings() -> [String] {
        var allCases = ExpenseCategory.allCases.map({$0.rawValue})
        allCases.append("All")
        return allCases
    }
    
    static func findCase(string : String) -> ExpenseCategory? {
        let results = allCases.filter({$0.rawValue == string})
        
        return results.first ?? nil
    }
}

enum DateRangeType: CaseIterable {
    case day
    case week
    case month
    case year
    case custom
    
    func toString() -> String {
        switch self {
        case .day:
            return "Today"
        case .week:
            return "Past week"
        case .month:
            return "Past month"
        case .year:
            return "Past year"
        case .custom:
            return "Custom"
        }
    }
}

struct ExpenseItem : Hashable {
    let amount : Double
    let date : Date
    let category : ExpenseCategory
}

class ExpenseSettings: ObservableObject {
    @Published var expenseItems: [ExpenseItem] = []
}

struct ExpenseSummaryView: View {
        
    @EnvironmentObject var settings: ExpenseSettings
    
    @State private var displayItems : [ExpenseItem] = []
    @State private var grouping = GroupingType.category
    @State private var showingSheet = false
    @State private var selectedRangeType = DateRangeType.day
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    @State private var selectedCategory : String = "All"
    @State private var totalAmount : Double = 0

    func dateFromToday(_ range: DateRangeType, _ count: Int) -> Date {
        var dayComponent = DateComponents()
        
        switch range {
        case .day, .custom:
            dayComponent.day = 1 * count
        case .week:
            dayComponent.day = 7 * count
        case .month:
            dayComponent.month = 1 * count
        case .year:
            dayComponent.year = 1 * count
        }

        let date = Calendar.current.date(byAdding: dayComponent, to: Date())
        return date ?? Date()
    }
    
    func updateDisplayedItems() {
        
        displayItems = settings.expenseItems

        // Filter by category (if chosen)
        if let category = ExpenseCategory.findCase(string: selectedCategory) {
            displayItems = displayItems.filter({
                $0.category == category
                })
        }
        
        // Filter by date range
        if selectedRangeType != .custom {
            customEndDate = Date()
            customStartDate = dateFromToday(selectedRangeType, -1)
        }
        displayItems = displayItems.filter({
            $0.date >= customStartDate && $0.date <= customEndDate
        })
        
        // Sort by grouping type
        switch grouping {
        case .amount:
            displayItems.sort(by: {$0.amount < $1.amount})
        case .date:
            displayItems.sort(by: {$0.date < $1.date})
        case .category:
            displayItems.sort(by: {$0.category.rawValue < $1.category.rawValue})
        }
        
        // Compute total of displayed items
        totalAmount = displayItems.reduce(0.0) {(result, a) -> Double in
            return result + a.amount
        }
    }
    
    func loadExpenseData() {
        
        //
        // Use mock data for now.
        //
        let items : [ExpenseItem] = [
            ExpenseItem(amount: 40.31, date: Date(), category: .transportation),
            ExpenseItem(amount: 34.08, date: Date(), category: .food),
            ExpenseItem(amount: 123.45, date: dateFromToday(.day, -10), category: .entertainment),
            ExpenseItem(amount: 23.95, date: dateFromToday(.day, -5), category: .food),
            ExpenseItem(amount: 55.43, date: dateFromToday(.day, -50), category: .entertainment),
            ExpenseItem(amount: 105.49, date: dateFromToday(.day, -3), category: .transportation),
            ExpenseItem(amount: 99.05, date: dateFromToday(.day, -405), category: .food),
            ExpenseItem(amount: 1200.00, date: dateFromToday(.day, -20), category: .transportation),
            ExpenseItem(amount: 38.42, date: dateFromToday(.day, -100), category: .food),
            ExpenseItem(amount: 43.36, date: dateFromToday(.day, -14), category: .food),
        ]
        
        settings.expenseItems = items
        
        updateDisplayedItems()
    }
        
    var body: some View {
        
        VStack {

            Text("Expense Report").fontWeight(.bold).font(.title)
            
            Divider()
            
            // Header
            HStack(alignment: .top, spacing: 8) {
                Button("Category") {
                    grouping = .category
                    updateDisplayedItems()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                
                Button("Date") {
                    grouping = .date
                    updateDisplayedItems()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)

                Button("Amount") {
                    grouping = .amount
                    updateDisplayedItems()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 34)
            .background(Color.gray)
            
            
            List(displayItems, id: \.self) {
                item in
                ExpenseItemView(item: item)
                    .frame(minWidth: 0,
                           maxWidth: .infinity)
            }
                        
            Spacer()
                        
            // Category
            VStack {
                Divider()
                Picker("Category: \(selectedCategory)", selection: $selectedCategory) {
                    ForEach(ExpenseCategory.allCasesStrings(), id:\.self) {
                        value in
                        Text(value)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedCategory) { _ in
                    updateDisplayedItems()
                }
            }
            
            // Date range
            VStack {
                Divider()
                Picker("Dates: \(selectedRangeType.toString())", selection: $selectedRangeType) {
                    ForEach(DateRangeType.allCases, id: \.self) { value in
                        Text(value.toString())
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedRangeType) { _ in
                    
                    if selectedRangeType == .custom {
                        // Reset dates to today
                        customEndDate = dateFromToday(.day, 0)
                        customStartDate = dateFromToday(.day, -1)
                    }

                    updateDisplayedItems()
                }

                if selectedRangeType == .custom {
                    HStack(alignment: .center, spacing: 20) {
                        
                        DatePicker("From",
                                   selection: $customStartDate,
                                   in: ...dateFromToday(.day, -1),
                                   displayedComponents: .date)
                            .onChange(of: customStartDate) { _ in
                                updateDisplayedItems()
                            }
                            .frame(maxWidth: .infinity)

                        DatePicker("To",
                                   selection: $customEndDate,
                                   in: ...dateFromToday(.day, 0),
                                   displayedComponents: .date)
                            .onChange(of: customEndDate) { _ in
                                updateDisplayedItems()
                            }
                            .frame(maxWidth: .infinity)

                    }
                    .padding()
                }
            }
            
            VStack {
                Divider()
                Text("Total = $"+String(format: "%.2f", totalAmount))
            }
            
            VStack {

                Divider()
                
                Button("New Item") {
                    showingSheet = true
                }
                .frame(width: 200)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(30)
                .sheet(isPresented: $showingSheet) {
                    InputFormView()
                        .onDisappear{
                            updateDisplayedItems()
                        }
                }
                
            }
        }
        .onAppear{
            loadExpenseData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseSummaryView()
    }
}
