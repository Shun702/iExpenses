//
//  ContentView.swift
//  Views
//
//  Created by Shun Le Yi Mon on 25/07/2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var expenses = Expenses()
    @State private var showingAddExpense = false

    var body: some View {
        NavigationView {
            List {
                Section (header: Text("Personal")) {
                    ForEach(expenses.items.filter {$0.type == "Personal"}) { item in
                        
                        HStack {
                                Text(item.name)
                                    .font(.headline)
                            Spacer()
                            AmountView(amount: item.amount)
                        }
                    }
                    .onDelete(perform: removeItems)
                }
                Section (header: Text("Business")) {
                    ForEach(expenses.items.filter {$0.type == "Business"}) { item in
                        HStack {
                                Text(item.name)
                                    .font(.headline)
                            Spacer()
                            AmountView(amount: item.amount)
                        }
                    }
                    .onDelete(perform: removeItems)
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
            
    }
    
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

struct AmountView: View {
    
    var amount: Double
    var color: Color {
        switch amount {
        case 0..<10: return Color.green
        case 10..<100: return Color.orange
        case 100...: return Color.red
        default: return Color.primary
        }
    }
    var body: some View {
        Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD") ).foregroundColor(color).fontWeight(.bold)
    }
}
class Expenses: ObservableObject {
    @Published var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")            }
        }
    }
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = []
    }
    
}

struct ExpenseItem: Identifiable, Codable  {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
