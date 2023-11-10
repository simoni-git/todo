//
//  ViewController.swift
//  newTodo2
//
//  Created by MAC on 2023/08/21.
//

import UIKit

class ViewController: UIViewController {
    
    

    @IBOutlet var tableView: UITableView!
    var tasks = [Task]() {
        didSet {
            saveTasks()
        }
    }
    
    @IBOutlet var EditButton: UIBarButtonItem!
    
    var doneButton: UIBarButtonItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtontap))
        self.loadTasks()
       
    }
    
    @objc func doneButtontap() {
        self.navigationItem.leftBarButtonItem = self.EditButton
        self.tableView.setEditing(false, animated: true)
    }
    
    

    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        guard !self.tasks.isEmpty else {return}
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        //⬇️ 1. alert이라는 상수에 알럿을 띄우는 코드를 할당함,
        let alert = UIAlertController(title: "공주가해야할일이뭐니?", message: nil, preferredStyle: .alert)
        //⬇️ 1. alert에서 등록버튼을 만드는코드. handler에는 등록버튼이 눌렸을때 수행할클로저를 써주면됨. 처음엔 { _ in }을 작성해줬음. 2. 등록버튼을 눌렀을때 텍스트필드에 입력된값을 가져오게하려고함. [0] 인 이유는 우리는 텍스트필드를 한개만 만들어줬기때문에 0번째 텍스트필드임. 3. [weak self] 이건 따로 공부해야할듯, 강한순환참조 뭐시라뭐시라함. 그리고 옵셔널타입이라고 자꾸 뜨니까 가드문으로 옵셔널바인딩해줌. 4. task변수를 만들어줘서 Task구조체를 사용해줌. title은 title을 해주고 done 에는 안끝난일을 등록하는거니까 false로 해줌. 5. 4번에이어서 tasks 에 task를 추가해줌.
        let regsterButton = UIAlertAction(title: "등록하기", style: .default, handler: { [weak self]_ in
            guard let title = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData() //   cell이 뭔지 밑에 다 정의하고나서작성한코드, 등록하기 버튼이 눌리면 테이블뷰에 나타낼수있도록 데이터를리로드하는 코드.
        })
        //⬇️ 1. alert에서 취소버튼을 만드는코드. handler에는 취소버튼을 눌렀을때 아무것도안할꺼니까 일단 nil
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        //⬇️ 1. arlert에 엑션중 내가만든 액션들인 두가지버튼을 넣어줌.
        alert.addAction(regsterButton)
        alert.addAction(cancelButton)
        
        //⬇️ 2. 알럿에 텍스트필드를 넣어주는코드, configurationHandler에는 클로저를 사용
        alert.addTextField(configurationHandler: {textField in
            textField.placeholder = "공주가할일을 적어봐!"})
        //⬇️ 1. add버튼을 눌렀을때 내가설정한 알럿이 표시되게끔해주는 코드
        self.present(alert , animated: true , completion: nil)
        
    
    }
    
    func saveTasks() {
        let data = self.tasks.map {
            [
                "title": $0.title,
                "done": $0.done
                
            ]
        }
        let userDefauls = UserDefaults.standard
        userDefauls.set(data, forKey: "tasks")
    }
    
    func loadTasks() {
        let userDefauls = UserDefaults.standard
        guard let data = userDefauls.object(forKey: "tasks") as? [[String: Any]] else {return}
        self.tasks = data.compactMap {
            guard let title = $0["titlt"] as? String else {return nil}
                guard let done = $0["done"] as? Bool else {return nil}
            return Task(title: title, done: done)
            }
        }
        
    }
    



extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count // tasks의 갯수만큼 셀의갯수가 반환되게해줘
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if self.tasks.isEmpty {
            self.doneButtontap()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
