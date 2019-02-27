//
//  SQLiteRowDataProtocol.swift
//  SQLiteSample
//
//  Created by Seonghun Kim on 27/02/2019.
//  Copyright © 2019 Seonghun Kim. All rights reserved.
//

import Foundation
import SQLite3

protocol SQLiteRowDataProtocol {
    var rowQuery: String { get }
    func bindData(statement: OpaquePointer?, index: Int32) -> Bool
}

extension String: SQLiteRowDataProtocol {
    var rowQuery: String {
        return "'\(self)'"
    }
    
    func bindData(statement: OpaquePointer?, index: Int32) -> Bool {
        let index = index
        let row
            = self.trimmingCharacters(in: .whitespacesAndNewlines)
                as NSString? ?? ""
        
        return sqlite3_bind_text(statement,index, row.utf8String, -1, nil)
            == SQLITE_OK
    }
}

extension Int: SQLiteRowDataProtocol {
    var rowQuery: String {
        return "\(self)"
    }
    
    func bindData(statement: OpaquePointer?, index: Int32) -> Bool{
        let index = index
        let row: Int32 = Int32(self)
        
        return sqlite3_bind_int(statement, index, row)
            == SQLITE_OK
    }
}

extension Double: SQLiteRowDataProtocol {
    var rowQuery: String {
        return "\(self)"
    }
    
    func bindData(statement: OpaquePointer?, index: Int32) -> Bool {
        let index = index
 
        return sqlite3_bind_double(statement, index, self) == SQLITE_OK
    }
}

extension Bool: SQLiteRowDataProtocol {
    var rowQuery: String {
        return "\(self)"
    }
    
    func bindData(statement: OpaquePointer?, index: Int32) -> Bool {
        let index = index
        let row: Int32 = Int32(self ? 1 : 0)
        
        return sqlite3_bind_int(statement, index, row)
            == SQLITE_OK
    }
}
