//
//  PointsGrid.swift
//  di-example
//
//  Created by Marvin Zwolsman on 02/01/2022.
//

import SwiftUI

struct PointsGrid: View {
    let columns: [GridItem]
    let items: [Item]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(items) { item in
                VStack {
                    Text(item.amount)
                        .bold()
                    Text(item.name)
                }
            }
        }
    }
    
    init(items: [Item]) {
        self.columns = Array(repeating: GridItem(.flexible()), count: items.count)
        self.items = items
    }
    
    struct Item : Identifiable {
        var id: String {
            name
        }
        
        var name: String
        var amount: String
        
        init(name: String, amount: String) {
            self.name = name
            self.amount = amount
        }
        init(_ name: String, amount: Double, formatter: (Double) -> String = { $0.formatted() }) {
            self.init(name: name, amount: formatter(amount))
        }
        
        init(_ name: String, amount: Int, formatter: (Int) -> String = { $0.formatted() }) {
            self.init(name: name, amount: formatter(amount))
        }
    }
}

struct PointsGrid_Previews: PreviewProvider {
    static var previews: some View {
        PointsGrid(items: [
            .init("test 1", amount: 10000),
            .init("test 2", amount: 10000),
            .init("test 3", amount: 10000),
        ]).previewLayout(.sizeThatFits)
        
        PointsGrid(items: [
            .init("test 1", amount: 100000) { Int($0).abbr() },
            .init("test 2", amount: 1090),
            .init("test 3", amount: 10000),
        ]).previewLayout(.sizeThatFits)
    }
}
