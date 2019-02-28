//
//  DataModelProtocol.swift
//  SQLiteSample
//
//  Created by Seonghun Kim on 27/02/2019.
//  Copyright © 2019 Seonghun Kim. All rights reserved.
//

import Foundation

protocol DataModelProtocol {
    
    // MARK:- Properties
    var tableName: String { get }
    var columns: [Column] { get }
    
    // MARK:- Initialize
    init()
    init(data: [String: SQLiteRowDataProtocol])
}

enum ColumnType: String {
    case text = "TEXT"
    case integer = "INTEGER"
    case double = "DOUBLE"
    case char = "CHAR"
}

struct Column {
    var name: String
    var type: ColumnType
    var row: SQLiteRowDataProtocol
}
