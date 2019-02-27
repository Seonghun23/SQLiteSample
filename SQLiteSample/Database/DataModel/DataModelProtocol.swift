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
    var columns: [String] { get }
    var columnTypeQuery: [Int: String] { get }
    var rows: [Int: SQLiteRowDataProtocol] { get }
    
    // MARK:- Initialize
    init()
    init(data: [String: SQLiteRowDataProtocol])
}
