//
//  Task.swift
//  taskapp
//
//  Created by 内山和也 on 2018/08/02.
//  Copyright © 2018年 kazuya.uchiyama. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用ID。プライマリキー
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //内容
    @objc dynamic var contents = ""
    
    /// 日時
    @objc dynamic var date = Date()
    
    /**
     idをプライマリキーとして設定
    */
    override static func primaryKey() -> String? {
        return "id"
    }
}
