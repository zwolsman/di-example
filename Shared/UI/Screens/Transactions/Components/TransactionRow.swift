//
//  TransactionRow.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 20/04/2022.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    private static let formatter = RelativeDateTimeFormatter()
    
    var body: some View {
        HStack {
            
            Circle()
                .foregroundColor(transactionColor)
                .frame(width: 8, height: 8)
                .padding()
            VStack(alignment: .leading) {
                Text(String(describing: transaction.type).capitalized)
                    .fontWeight(.semibold)
                Text(TransactionRow.formatter.string(for: transaction.timestamp)!)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(transaction.amount.formatted()) bits")
        }
        .padding(4)
    }
    
    var transactionColor: Color {
        if !transaction.confirmed {
            return .secondary
        }
        
        switch transaction.type {
        case .deposit:
            return .green
        case .withdraw:
            return .red
        }
    }
}

struct TransactionRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TransactionRow(transaction: Transaction.mockDeposit)
            TransactionRow(transaction: Transaction.mockWithdraw)
            TransactionRow(transaction: Transaction.mockDepositNonFirmed)
        }.previewLayout(.sizeThatFits)
        
        Group {
            TransactionRow(transaction: Transaction.mockDeposit)
            TransactionRow(transaction: Transaction.mockWithdraw)
            TransactionRow(transaction: Transaction.mockDepositNonFirmed)
        }.previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            
    }
}
