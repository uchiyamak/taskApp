//
//  ViewController.swift
//  taskapp
//
//  Created by 内山和也 on 2018/07/30.
//  Copyright © 2018年 kazuya.uchiyama. All rights reserved.
//

import UIKit
import RealmSwift       //Realmはアプリの内部に表形式のテーブルを保持させられる？
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()    //tryってなんだ？　→エラー無視らしい
    
    // DB内のタスクが格納されるリスト
    // 日付近い順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UITableViewDataSourceプロトコルのメソッド      tableViewという同じ名前のメソッドがたくさん。混乱しないの？
    //データの数を返すメソッド
    func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }       //メソッドの引数のスペース前後の意味はそれぞれ？
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なcellをえる
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let task = taskArray[indexPath.row]      //rowの現在地は？
        cell.textLabel?.text = task.title       //textlabelどこだっけ？
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"   //日付のフォーマット変換に、わざわざ変数作るの？
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    //UITableViewDelegateプロトコルメソッド
    //各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) ->UITableViewCellEditingStyle {
        return .delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])    //[]って何？
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)  //スワイプして削除、はどの部分で記載？
            }
            
            // 未通知のローカル通知一覧をログ出力    getPendingNotificationRequestsはデフォルトでは別の引数が表示されるが？
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/--------------")
                    print(request)
                    print("--------------/")
                }
            }
        }
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)     //これはなんだろう？
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時にTableViewを更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()      //reloadDateはもともとある関数？
    }

}





