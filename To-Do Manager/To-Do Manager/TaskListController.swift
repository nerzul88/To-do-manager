//
//  TaskListController.swift
//  To-Do Manager
//
//  Created by Александр Касьянов on 05.08.2021.
//

import UIKit

class TaskListController: UITableViewController {
        
    //хранилище задач
    var tasksStorage: TasksStorageProtocol = TasksStorage()
    //коллекция задач
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {
        didSet {
            //сортировка списка задач
            for (tasksGroupPriority, tasksGroup) in tasks {
                tasks[tasksGroupPriority] = tasksGroup.sorted {task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
            
            //сохранение задач
            var savingArray: [TaskProtocol] = []
            tasks.forEach { key, value in
                savingArray += value
            }
            tasksStorage.saveTasks(savingArray)
        }
    }
    
    //порядок отображения секций по типам
    //индекс в массиве соответствует инексу секции в таблице
    var sectionTypePosition: [TaskPriority] = [.important, .normal]
    
    //порядок отображения задач по их статусу
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    
    //получение списка задач, их разбор и установка в свойство tasks
    func setTasks(_ tasksCollection: [TaskProtocol]) {
        //подготовка коллекции с задачами
        //будем использовать только те задачи, для которых определена секция
        sectionTypePosition.forEach { taskType in
            tasks[taskType] = []
        }
        //загрузка и разбор задач из хранилища
        tasksCollection.forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    private func loadTasks() {
        //подготовка коллекции с задачами
        //будем использовать только те задачи, для которых определена секция в таблице
        sectionTypePosition.forEach { taskType in
            tasks[taskType] = []
        }
        //загрузка и разбор задач из хранилища
        tasksStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    
    //ячейка на основе ограничений
    private func getConfiguredTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        //загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        //получаем данные о задаче, которую необходимо вывести в ячейке
        let taskType = sectionTypePosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        //текстовая метка символа
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        //текстовая метка названия задачи
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        //изменяем символ в ячейке
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        //изменяем текст в ячейке
        textLabel?.text = currentTask.title
        
        //изменяем цвет текста и символа
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        return cell
    }
    
    //ячейка на основе стека
    private func getConfiguredTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        //загружаем прототип ячейки по идентификатору
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        
        //получаем данные о задаче, которые необходимо вывести в ячейке
        let taskType = sectionTypePosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        //изменяем текст в ячейке
        cell.title.text = currentTask.title
        
        //изменяем символ в ячейке
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        
        //изменяем цвет текста
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        return cell
    }
    
    //возвращаем символ для соответствующего типа задачи
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //загрузка задач
        //loadTasks()
        //кнопка активации режима редактирования
        navigationItem.leftBarButtonItem = editButtonItem

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    //количество секций в таблице
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tasks.count
    }
    
    //количество строк в определённой секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //определяем приоритет задач, соответствующий текущей секции
        // #warning Incomplete implementation, return the number of rows
        let taskType = sectionTypePosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }

    //ячейка для строки таблицы
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        //ячейка на основе констрейнтов
        //return getConfiguredTaskCell_constraints(for: indexPath)
        //ячейка на основе стека
        return getConfiguredTaskCell_stack(for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let tasksType = sectionTypePosition[section]
        if tasksType == .important {
            title = "Важные"
        } else if tasksType == .normal {
            title = "Текущие"
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1. Проверяем существование задачи
        let taskType = sectionTypePosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        //2.Убеждаемся, что задача не является выполненной
        guard tasks[taskType]![indexPath.row].status == .planned else {
            //снимаем выделение со строки
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        //3. Отмечаем задачу как выполненную
        tasks[taskType]![indexPath.row].status = .completed
        //4.Перезагружаем секцию таблицы
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //получаем данные о задаче, которую необходимо перевести в статус "запланирована"
        let taskType = sectionTypePosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        
        //действие для изменения статуса на "запланировано"
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена") {_,_,_ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        //действие для перехода к экрану редактирования
        let actionEditInstance = UIContextualAction(style: .normal, title: "Изменить") {_,_,_ in
            //загрузка сцены со storyboard
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TaskEditController") as! TaskEditController
            //передача значений редактируемой задачи
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            //передача обработчика для сохранения задачи
            editScreen.doAfterEdit = { [unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editedTask
                tableView.reloadData()
            }
            //переход к экрану редактирования
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        //изменем цвет фона кнопки с действием
        actionEditInstance.backgroundColor = .darkGray
        
        //создаём объект, описывающий доступные действия
        //в зависимости об статуса задачи будет отображено 1 или 2 действия
        let actionsConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditInstance])
        } else {
            actionsConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
        }
        
        return actionsConfiguration
        
//        //проверяем, что задача имеет статус "выполнено"
//        guard tasks[taskType]![indexPath.row].status == .completed else {
//            return nil
//        }
//        //создаём действие для изменения статуса
//        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена") {_,_,_ in
//            self.tasks[taskType]![indexPath.row].status = .planned
//            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
//        }
//        //возвращаем настроенный объект
//        return UISwipeActionsConfiguration(actions: [actionSwipeInstance])
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionTypePosition[indexPath.section]
        //удаляем задачу
        tasks[taskType]?.remove(at: indexPath.row)
        //удаляем строку, соответствующую задаче
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //секция, из которой происходит перемещение
        let taskTypeFrom = sectionTypePosition[sourceIndexPath.section]
        //секция, в которую происходит перемещение
        let taskTypeTo = sectionTypePosition[destinationIndexPath.section]
        
        //безопасно извлекаем задачу, тем самым копируя её
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        
        //удаляем задачу с места, откуда она перенесена
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        //вставляем задачу на новую позицию
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        //если секция изменилась, изменяем тип задачи в соответствии с новой позицией
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        
        //обновляем данные
        tableView.reloadData()
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
   

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = {
                [unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
    

}
