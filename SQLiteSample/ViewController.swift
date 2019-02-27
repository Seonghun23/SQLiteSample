//
//  ViewController.swift
//  SQLiteSample
//
//  Created by Seonghun Kim on 27/02/2019.
//  Copyright © 2019 Seonghun Kim. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var stringTextField: UITextField!
    @IBOutlet weak var intStepper: UIStepper!
    @IBOutlet weak var intLabel: UILabel!
    @IBOutlet weak var boolSwitch: UISwitch!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var databaseTableView: UITableView!
    
    private let cellIdentifier = "cell"
    private let databaseName = "SampleDatabase"
    private let fileManager = FileManager.default
    
    private var dataList = [SampleModel]()
    private var database: SQLiteDatabase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseTableView.dataSource = self
        databaseTableView.delegate = self
        
        prepareDatabase()
        
        intStepper.addTarget(self, action: #selector(intStepperValueChanged), for: .valueChanged)
        AddButton.addTarget(self, action: #selector(addButtonDidTap(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonDidTap(_:)), for: .touchUpInside)
    }
    
    private func prepareDatabase() {
        let sampleModel = SampleModel()
        
        database = try? SQLiteDatabase.open(name: databaseName, fileManager: fileManager)
        
        if let database = database,
            database.createTable(name: sampleModel.tableName, dataModel: sampleModel)
        {
            guard let dataArray = try? database.fetch(table: sampleModel .tableName) else {
                print("Fail to fetch data from database")
                return
            }
            
            dataList.removeAll()
            dataArray.forEach{
                let data = SampleModel(data: $0)
                dataList.append(data)
            }
            databaseTableView.reloadData()
        }
    }
    
    @objc func intStepperValueChanged(_ sender: UIStepper) {
        intLabel.text = "\(Int(sender.value))"
    }
    
    @objc func addButtonDidTap(_ sender: UIButton) {
        let data = SampleModel(string: stringTextField.text ?? "내용없음",
                               int: Int(intStepper?.value ?? 0),
                               double: Date().timeIntervalSinceNow,
                               bool: boolSwitch.isOn)
        
        guard let database = database else {
            self.database = try? SQLiteDatabase.open(name: databaseName,
                                                fileManager: fileManager)
            addButtonDidTap(sender)
            
            return
        }
        
        guard let _ =  try? database.insert(table: data.tableName,
                                            columns: data.columns,
                                            rows: data.rows)
            else
        {
            print("Fail to insert data to database")
            return
        }
        
        guard let dataArray = try? database.fetch(table: data.tableName) else {
            print("Fail to fetch data from database")
            return
        }
        
        dataList.removeAll()
        dataArray.forEach{
            let data = SampleModel(data: $0)
            
            dataList.append(data)
        }
        
        databaseTableView.reloadData()
    }
    
    @objc func deleteButtonDidTap(_ sender: UIButton) {
        showDeleteAlert()
    }
    
    private func showDeleteAlert() {
        let alert = UIAlertController(title: "데이터 삭제",
                                      message: "int값이 \(Int(intStepper?.value ?? 0))인 모든 데이터를 삭제하시겠습니까?",
                                      preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .default) { _ in
            self.deleteDataFromDatabase()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: false, completion: nil)
    }
    
    private func deleteDataFromDatabase() {
        guard let database = database else {
            self.database = try? SQLiteDatabase.open(name: databaseName,
                                                     fileManager: fileManager)
            deleteDataFromDatabase()
            
            return
        }
        
        let sampleModel = SampleModel()
        try? database.delete(table: sampleModel.tableName, field: "int", row: Int(intStepper?.value ?? 0))
        
        guard let dataArray = try? database.fetch(table: sampleModel.tableName) else {
            print("Fail to fetch data from database")
            return
        }
        
        dataList.removeAll()
        dataArray.forEach{
            let data = SampleModel(data: $0)
            dataList.append(data)
        }
        databaseTableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        guard let tableViewCell = cell as? TableViewCell else {
            return .init()
        }
        
        let data = dataList[indexPath.row]
        
        tableViewCell.stringLabel.text = data.string
        tableViewCell.intLabel.text = "\(data.int)"
        tableViewCell.boolLabel.text = "\(data.bool)"
        tableViewCell.doubleLabel.text = "\(data.double)"
        
        return tableViewCell
    }
}

extension ViewController: UITableViewDelegate {
    
}

