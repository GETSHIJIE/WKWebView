//
//  SQLiteController.swift
//  WKWebView
//
//  Created by 黃仕杰 on 2020/6/5.
//  Copyright © 2020 shijie. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteController {
    var db: Sqlite?;
    private var TableName: String = "";
    
    struct UserInfo: Codable {
      let id: Int32
      let data: String
    }
    
    func DBCreateTable(dbTableName: String) -> Void {
        let destinationUrl = getDirectoryPath().appendingPathComponent("sqlite3.db");
        db = Sqlite(path: destinationUrl.absoluteString);
        if db != nil{
            let dbStatus = db!.createTable(dbTableName,
            columnsInfo: ["id integer primary key autoincrement",
                          "data text"]);
            if dbStatus == SQLITE_OK{
                self.TableName = dbTableName;
                print("database status ok!");
            }
        }
    }
    
    func isInsert(data: String) -> Bool {
        var result: Bool = false;
        if db != nil {
          let dbStatus = db!.insert("'\(TableName)'",
            rowInfo: ["data":"'\(data)'"]);
          if dbStatus == SQLITE_OK {
            result = true;
            print("insert ok!");
          }
        }
        
        return result;
    }
    
    func fetchData(offset: Int) -> String {
        var jsonString: String = "";
        let statement = db!.fetch(TableName, cond: nil, sortBy: nil, offset: offset)
        var fetchResult: [UserInfo] = [UserInfo]();
        
        while sqlite3_step(statement) == SQLITE_ROW {
          let id = sqlite3_column_int(statement, 0)
          let data = String(cString: sqlite3_column_text(statement, 1))
          
          fetchResult.append(UserInfo.init(id: id, data: data))
        }
        
        do {
            let jsonData = try JSONEncoder().encode(fetchResult);
            jsonString = String(data: jsonData, encoding: .utf8)!;

            // and decode it back
            //let decodedSentences = try JSONDecoder().decode([UserInfo].self, from: jsonData);
            //print(decodedSentences)
        } catch { print(error) }
        
        return jsonString;
    }
    
    func deleteData(id: Int) -> Void {
        _ = db!.delete(self.TableName, cond: "id='\(id)'");
    }
    
    private func getDirectoryPath() -> URL {
      let fileDirectoryURL = FileManager.default.urls(for: .documentDirectory,
                                                      in: .userDomainMask).first!
      return fileDirectoryURL
    }
}
