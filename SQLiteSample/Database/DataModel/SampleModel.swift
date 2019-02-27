//
//  SampleModel.swift
//  SQLiteSample
//
//  Created by Seonghun Kim on 27/02/2019.
//  Copyright © 2019 Seonghun Kim. All rights reserved.
//

import Foundation

struct SampleModel {
    let string: String
    let int: Int
    let double: Double
    let bool: Bool
    
    init(string: String, int: Int, double: Double, bool: Bool) {
        self.string = string
        self.int = int
        self.double = double
        self.bool = bool
    }
}

extension SampleModel: DataModelProtocol {
    var tableName: String {
        return "SampleTable"
    }
    
    var columns: [String] {
        return [
            "string",
            "int",
            "double",
            "bool"
        ]
    }
    
    var columnTypeQuery: [Int : String] {
        return [
            0: "TEXT",
            1: "INTEGER",
            2: "DOUBLE",
            3: "INTEGER"
        ]
    }
    
    var rows: [Int : SQLiteRowDataProtocol] {
        return [
            0: string,
            1: int,
            2: double,
            3: bool,
        ]
    }
    
    init() {
        self.string = ""
        self.int = -1
        self.double = -0.1
        self.bool = false
    }
    
    init(data: [String : SQLiteRowDataProtocol]) {
        self.string = data["string"] as? String ?? ""
        self.int = data["int"] as? Int ?? 0
        self.double = data["double"] as? Double ?? 0.0
        self.bool = data["bool"] as? Int == 1
    }
}
