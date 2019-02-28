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
    
    var columns: [Column] {
        return [
            Column(name: "string", type: .text, row: string),
            Column(name: "int", type: .integer, row: int),
            Column(name: "double", type: .double, row: double),
            Column(name: "bool", type: .integer, row: bool)
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

