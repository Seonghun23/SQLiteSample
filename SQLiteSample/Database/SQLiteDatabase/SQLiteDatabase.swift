//
//  SQLiteDatabase.swift
//  BeBrav
//
//  Created by Seonghun Kim on 28/01/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteDatabase {
    
    // MARK:- Properties
    private var database: OpaquePointer?
    private var errorMessage: String {
        if let error = sqlite3_errmsg(database) {
            return String(cString: error)
        }
        return "No error message at SQLite Database"
    }
    
    // MARK:- Initialize
    init(database: OpaquePointer?) {
        self.database = database
    }
    
    deinit {
        sqlite3_close(database)
    }
    
    // MARK:- Open SQLite Database
    static func open(name: String, fileManager: FileManager)
        throws -> SQLiteDatabase
    {
        var database: OpaquePointer?
        
        let fileURL = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
            ).appendingPathComponent("\(name).sqlite")
        
        if sqlite3_open(fileURL.path, &database) != SQLITE_OK {
            defer {
                if database != nil { sqlite3_close(database) }
            }
            
            let error = String(cString: sqlite3_errmsg(database))
            
            throw SQLiteError.openDatabase(message: error)
        }
        
        return SQLiteDatabase(database: database)
    }
    
    // MARK:- Prepare SQL Query statement
    private func prepare(query: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK
            else
        {
            throw SQLiteError.prepare(message: errorMessage)
        }
        
        return statement
    }
    
    // MARK:- Create table at SQLite Database
    final func createTable(name: String, dataModel: DataModelProtocol) -> Bool {
        #warning("New Code")
        // 새로 변경된 코드입니다. 다양한 자료형을 지원하기 위해 모델에서 쿼리문에 필요한 값을 반환하도록 만들었습니다.
        var column = ""
        dataModel.columns.enumerated().forEach{ (i, v) in
            if let typeQuery = dataModel.columnTypeQuery[i] {
                column.append(", \(v) \(typeQuery)")
            }
        }
        
        // 아래 코드는 예전 코드입니다.
//        let column = columns.reduce("") { $0 + ", \(idFieldName(name: $1)) TEXT"}
        
        let columnString = column.count > 0 ? column : ""
        let query = """
        CREATE TABLE IF NOT EXISTS \(name)(
            id INTEGER PRIMARY KEY AUTOINCREMENT\(columnString)
        );
        """
        
        let statement: OpaquePointer?
        
        do {
            statement = try prepare(query: query)
        } catch let error {
            return false
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            return false
        }
        
        return true
    }
    
    // MARK:- Insert rows at table in SQLite Database
    final func insert(table: String, columns: [String], rows: [Int: SQLiteRowDataProtocol])
        throws -> Bool
    {
        var field = ""
        var fieldCount = ""
        columns.enumerated().forEach{ (i, v) in
            field += "\(i != 0 ? ", " : "")\(v)"
            fieldCount += "\(i != 0 ? ", ?" : "?")"
        }
        let query = "INSERT INTO \(table) (\(field)) VALUES (\(fieldCount));"
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        for i in columns.indices {
            let index = Int32(i + 1)
            
            #warning("New Code")
            // 새로 변경된 코드입니다. 사용할 자료형은 모두 SQLiteRowDataProtocol 를 채택하고 따르고 있습니다. 
            if let row = rows[i] {
                if !row.bindData(statement: statement, index: index) {
                    throw SQLiteError.bind(message: errorMessage)
                }
            }
            
            // 아래 코드는 예전 코드입니다.
//            let text: NSString
//                = rows[i]?.trimmingCharacters(in: .whitespacesAndNewlines)
//                    as NSString? ?? ""
//            if sqlite3_bind_text(statement,index, text.utf8String, -1, nil)
//                != SQLITE_OK
//            {
//                throw SQLiteError.bind(message: errorMessage)
//            }
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
        
        return true
    }
    
    // MARK:- Fetch column at table in SQLite Database
    public func fetch(table: String,
                      column: String? = nil,
                      field: String = "",
                      row: SQLiteRowDataProtocol? = nil,
                      condition: Condition? = nil)
        throws -> [[String: SQLiteRowDataProtocol]]
    {
        let column = column != nil ? field : "*"
        
        var query = "SELECT \(column) FROM \(table)"
        var values: [[String: SQLiteRowDataProtocol]] = []
        
        if let rowQuery = row?.rowQuery, !field.isEmpty {
            let condition = condition?.rawValue ?? "="
            query.append(" WHERE \(field) \(condition) \(rowQuery)")
        }
        
        if !field.isEmpty && row != nil {
            
        }
        
        query.append(";")
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        while(sqlite3_step(statement) == SQLITE_ROW) {
            var value: [String: SQLiteRowDataProtocol] = [:]
            for i in 0..<sqlite3_column_count(statement) {
                let name = String(cString: sqlite3_column_name(statement, i))
                
                #warning("New Code")
                // 새로 변경된 코드입니다. 사용할 자료형은 모두 SQLiteRowDataProtocol 를 채택하고 따르고 있습니다.
                let columnType = sqlite3_column_type(statement, i)
                
                var data: SQLiteRowDataProtocol?
                
                switch columnType {
                case SQLITE_INTEGER:
                    data = Int(sqlite3_column_int(statement, i))
                case SQLITE_FLOAT:
                    data = sqlite3_column_double(statement, i)
                case SQLITE_TEXT:
                    data = String(cString: sqlite3_column_text(statement, i))
                default:
                    break
                }
                
                if let data = data {
                    value.updateValue(data, forKey: name)
                }
                
                // 아래 코드는 예전 코드입니다.
//                let text = String(cString: sqlite3_column_text(statement, i))
//                value.updateValue(text, forKey: idDataName(name: name))
            }
            values.append(value)
        }
        
        return values
    }
    
    // MARK:- Update row at table in SQLite Database
    final func update(table: String,
                      column: String,
                      data: SQLiteRowDataProtocol,
                      field: String,
                      row: SQLiteRowDataProtocol) throws
    {
        let query = "UPDATE \(table) SET \(column) = '\(data)' WHERE \(field) = \(row.rowQuery);"
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
    }
    
    // MARK:- Delete row at table in SQLite Database
    final func delete(table: String, field: String, row: SQLiteRowDataProtocol) throws {
        let query = "DELETE FROM \(table) WHERE \(field) = \(row.rowQuery);"
        
        let statement = try prepare(query: query)
        
        defer {
            sqlite3_finalize(statement)
        }
        
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw SQLiteError.step(message: errorMessage)
        }
    }
}

enum Condition: String {
    case greater = ">"
    case less = "<"
    case equal = "="
}

