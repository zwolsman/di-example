//
//  Transaction.swift
//  Bombastic
//
//  Created by Marvin Zwolsman on 17/04/2022.
//

import Foundation

struct Transaction : Identifiable {
    let id = UUID()
    let type: TransactionType
    let amount: Int
    let timestamp: Date
    let confirmed: Bool
    
    enum TransactionType
    {
        case deposit
        case withdraw
    }
}
