//
//  TasksTabViewController.swift
//  StudentsApp
//
//  Created by Admin on 06.10.17.
//  Copyright © 2017 Владислав Саверский. All rights reserved.
//

import UIKit
import CoreData

class TasksTabViewController: UIViewController, NSFetchedResultsControllerDelegate{
    // MARK: - Variables
   
    var prosrButton: UIButton!
    var doneButton: UIButton!
    var workingWithDone: Bool = false
    var workingWithProsr: Bool = false
    var counterd = 0
    var counterp = 0
    
    var parametr: String! // переменная для выбота типа сортировки
    var taskOrActivity: String! // переменная для выбора заданий или мереоприятий
    var counter: Int!
    var chosenObject: TaskModel?
    
    var ActivitiesAtSubjectArray: [[ActivitiesModel]] = []
    
    var ActivitiesAtDayArray: [[ActivitiesModel]] = []
    var TasksAtDayArray: [[TaskModel]] = []
    var TasksAtSubjectArray: [[TaskModel]] = []
    var TasksAtPriorityArray: [[TaskModel]] = []
    
    var tasksFetchController: NSFetchedResultsController<Tasks>!
    var activitiesFetchController: NSFetchedResultsController<Activities>!
    var viewHasChanges: Bool = false
    var changesController: NSFetchedResultsController<NSFetchRequestResult>!
    
    let appDesign = CustomApplicationLook()
    
    @IBOutlet weak var taskTable: UITableView!
    
    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var activityButton: UIButton!
     @IBOutlet weak var addTaskButton: UIButton!
    
    @IBOutlet weak var Segment: UISegmentedControl!
    
    override func viewWillAppear(_ animated: Bool) {
        if(!(self.navigationController?.navigationBar.isHidden)!){
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        super.viewWillAppear(animated)
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        if(viewHasChanges){
            viewHasChanges = false
            updateData()
            taskTable.reloadData()
        }
    }
    
    func updateData(){
        if(changesController == tasksFetchController){
            TasksAtDayArray = TaskModel.getTasksGroupedByDate()
            TasksAtSubjectArray = TaskModel.getTasksGroupedBySubject()
            TasksAtPriorityArray = TaskModel.getTasksGroupedByPriority()
        }
        
        if(changesController == activitiesFetchController){
            ActivitiesAtSubjectArray = ActivitiesModel.getActivitiesGroupedBySubject()
            ActivitiesAtDayArray = ActivitiesModel.getActivitiesGroupedByDate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tasksFetchController = TaskModel.setupFetchController()
        tasksFetchController.delegate = self
        activitiesFetchController = ActivitiesModel.setupFetchController()
        activitiesFetchController.delegate = self
        
        taskTable.backgroundColor = UIColor.clear
       
        counter = 1
        
        appDesign.initBackground(ofView: self.view)
        appDesign.managedMainButonsContext.removeAll()
        appDesign.managedSubButonsContext.removeAll()
        appDesign.managedMainButonsContext.append(taskButton)
        appDesign.managedSubButonsContext.append(activityButton)
        taskButton.setTitleColor(appDesign.mainTextColor, for: .normal)
        activityButton.setTitleColor(appDesign.subTextColor, for: .normal)
        
        taskOrActivity = "task"//выбираем просмотр заданий
        parametr = "time" //выбираем сортировку по времени
        
        let taskCellNib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        taskTable.register(taskCellNib, forCellReuseIdentifier: "TasksCell")
        
        // Задаем страртове цета кнопок
        
       
        
        ActivitiesAtSubjectArray = ActivitiesModel.getActivitiesGroupedBySubject()
        ActivitiesAtDayArray = ActivitiesModel.getActivitiesGroupedByDate()
        TasksAtDayArray = TaskModel.getTasksGroupedByDate()
        TasksAtSubjectArray = TaskModel.getTasksGroupedBySubject()
        TasksAtPriorityArray = TaskModel.getTasksGroupedByPriority()
    
        
        // Do any additional setup after loading the view.
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        viewHasChanges = true
        changesController = controller
    }
        
   
    @IBAction func addTaskButtonTouch(_ sender: Any) {
        self.hidesBottomBarWhenPushed = true
        self.performSegue(withIdentifier: "fromTasksToTaskEdit", sender: self)
        self.hidesBottomBarWhenPushed = false
    }
    
    @IBAction func taskChooseButton(_ sender: Any) { //выбор просмотра заданий
        
        appDesign.managedMainButonsContext.removeAll()
        appDesign.managedSubButonsContext.removeAll()
        appDesign.managedMainButonsContext.append(taskButton)
        appDesign.managedSubButonsContext.append(activityButton)
        taskButton.setTitleColor(appDesign.mainTextColor, for: .normal)
        activityButton.setTitleColor(appDesign.subTextColor, for: .normal)
        taskOrActivity = "task"
        if counter == 0 {
        Segment.insertSegment(withTitle: "Приоритет", at: 2, animated: true)
            counter = 1
        }
        taskTable.reloadData()
        let index = IndexPath.init(row: 0, section: 0) //Прокрутка таблицы вверх при переключении
        taskTable.scrollToRow(at: index, at: .top, animated: true)
    }
    
    
    @IBAction func acrivityChooseButton(_ sender: Any) {//выбор просмотра мероприятий
        appDesign.managedMainButonsContext.removeAll()
        appDesign.managedSubButonsContext.removeAll()
        appDesign.managedMainButonsContext.append(activityButton)
        appDesign.managedSubButonsContext.append(taskButton)
        activityButton.setTitleColor(appDesign.mainTextColor, for: .normal)
        taskButton.setTitleColor(appDesign.subTextColor, for: .normal)
        taskOrActivity = "activity"
        if parametr == "priority"  { //так как в мероприятиях нет сортировки по приоритетам - перейдем в сортировку по датам
            Segment.selectedSegmentIndex = 1
            parametr = "time"
        }
        if counter == 1 {
        Segment.removeSegment(at: 2, animated: true)
            counter = 0
        }
        taskTable.reloadData()
        let index = IndexPath.init(row: 0, section: 0) //Прокрутка таблицы вверх при переключении
        taskTable.scrollToRow(at: index, at: .top, animated: true)
        
    }
    
    
    @IBAction func SegmentChenged(_ sender: Any) {
        switch Segment.selectedSegmentIndex {
        case 0:
            parametr = "subject"
            break
        case 1:
            parametr = "time"
            break
        case 2:
            parametr = "priority"
            break
        default:
            parametr = "time"
            break
        }
        if(viewHasChanges){
            viewHasChanges = false
            updateData()
        }
        taskTable.reloadData()
        let index = IndexPath.init(row: 0, section: 0) //Прокрутка таблицы вверх при переключении
        taskTable.scrollToRow(at: index, at: .top, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "fromTasksToTasksView"){
            let taskVC = segue.destination as! TaskViewEditViewController
            taskVC.taskModelObject = chosenObject
        }
      /*  if(segue.identifier == "fromTasksToTaskEdit"){
            let taskVC = segue.destination as! TaskEditViewController
          //  taskVC.taskModelObject = chosenObject
        } */
    }
    
}




extension TasksTabViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if(taskOrActivity == "task"){
            self.hidesBottomBarWhenPushed = true
            switch parametr {
            case "time":
                chosenObject = TasksAtDayArray[indexPath.section][indexPath.row]
                break
            case "subject":
                chosenObject = TasksAtSubjectArray[indexPath.section][indexPath.row]
                break
            case "priority":
                chosenObject = TasksAtPriorityArray[indexPath.section][indexPath.row]
                break
            default:
                chosenObject = TasksAtDayArray[indexPath.section][indexPath.row]
                break
            }
            self.performSegue(withIdentifier: "fromTasksToTasksView", sender: self)
            self.hidesBottomBarWhenPushed = false
        }
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if(taskOrActivity == "task"){
            let selectedTaskCell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
            selectedTaskCell.setHighlighted(false, animated: false)
            selectedTaskCell.MiddleDescriptionLabel.textColor = UIColor.red
           // selectedTaskCell.backgroundColor = UIColor(red: 153/255, green: 157/255, blue: 163/255, alpha: 0.25)
            
        }
        
        
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if(taskOrActivity == "task"){
            let selectedTaskCell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
            selectedTaskCell.setHighlighted(false, animated: false)
            selectedTaskCell.MiddleDescriptionLabel.textColor = appDesign.mainTextColor
            //selectedTaskCell.backgroundColor = UIColor(red: 153/255, green: 157/255, blue: 163/255, alpha: 0.25)
        }
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return taskTable.estimatedRowHeight
    }
}

extension TasksTabViewController: UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int { // Получим количество секций
        if taskOrActivity == "task" { // для вывода заданий
            if parametr == "time" {
            return TasksAtDayArray.count + 1
        }
        
            else { if parametr == "subject" {
                return TasksAtSubjectArray.count + 1
            }
                  else { if parametr == "priority" {
                return (TasksAtPriorityArray.count - 1) + 1
                }
                    else { return 0 }
                }
                
            }
        }
        
        else { //для вывода мероприятий
             if parametr == "time" {
                return ActivitiesAtDayArray.count + 1
            }
                
            else { if parametr == "subject" {
                return ActivitiesAtSubjectArray.count + 1
            }
            else {  return 0  }
            
        }
    }
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // Получим количество строк для конкретной секции
        if (section != (tableView.numberOfSections - 1)) {
      if taskOrActivity == "task" {  // для вывода заданий
        if parametr == "time" {
        return TasksAtDayArray[section].count
        }
       else {
        if parametr == "subject" {
           
            return TasksAtSubjectArray[section].count
        }
        else {
            if parametr == "priority" {
                return TasksAtPriorityArray[section].count
            }
            else {return 0}
        }
        }
        }
     else { //для вывода мероприятий
        if parametr == "time" {
            return ActivitiesAtDayArray[section].count
        }
        else {
            if parametr == "subject" {
                return ActivitiesAtSubjectArray[section].count
            }
            else {return 0}
        }
        }
        } else {
            return 0
        }
    }
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // Получим данные для использования в ячейке
         let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath) as! TaskTableViewCell
        
     
        if taskOrActivity == "task" { // для вывода заданий
        if parametr == "time" { // Вывод данных для сортировки заданий по дате
             cell.initWithTask(model: TasksAtDayArray[indexPath.section][indexPath.row], forSortingType: "Сроки")
            
        }
        
        if parametr == "subject" { // Вывод данных для сортировки заданий по предметам
            cell.initWithTask(model: TasksAtSubjectArray[indexPath.section][indexPath.row], forSortingType: "Предметы")
        }
        
        if parametr == "priority" { // Вывод данных для сортировки заданий по приоритету
            cell.initWithTask(model: TasksAtPriorityArray[indexPath.section][indexPath.row], forSortingType: "Приоритет")
        }
        }
 
        else {
            if parametr == "time" { // Вывод данных для сортировки мероприятий по дате
                cell.initWithActivity(model: ActivitiesAtDayArray[indexPath.section][indexPath.row], forSortingType: "Сроки")
            }
            
            if parametr == "subject" { // Вывод данных для сортировки мероприятий по предметам
                cell.initWithActivity(model: ActivitiesAtSubjectArray[indexPath.section][indexPath.row], forSortingType: "Предметы")
            }
        }
        
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        let header = HeaderFooterViewClass.initHeader(withWidth: tableView.frame.width, andMainText: "")
        header.mainHeaderLabel?.textAlignment = .left
        //var headerLabel = ""
        
        if (section != (tableView.numberOfSections - 1)) {
        header.viewCornerRadius = 8.0
            if taskOrActivity == "task" {
        
        switch parametr {
        case "time":
            let todayD = CustomDateClass()
            if (TasksAtDayArray[section][0].taskDate! >= todayD) {
            header.mainHeaderLabel?.text = (TasksAtDayArray[section][0].taskDate?.stringFromDate())!
            } else {header.mainHeaderLabel?.text = "Просрочено"}
            break
        case "subject":
            header.mainHeaderLabel?.text = TasksAtSubjectArray[section][0].taskSubject! == "" ? "Дополнительно" : TasksAtSubjectArray[section][0].taskSubject!
            break
        case "priority":
            switch TasksAtPriorityArray[section][0].taskPriority! {
            case 2:
                header.mainHeaderLabel?.text = "Высокий приоритет"
                break
            case 1:
                header.mainHeaderLabel?.text = "Средний приоритет"
                break
            case 0:
                header.mainHeaderLabel?.text = "Низкий приоритет"
                break
            default:
                header.mainHeaderLabel?.text = " "
                break
            }
        default:
            header.mainHeaderLabel?.text = " "
            break
        }
            }
            else {
                switch parametr {
                case "time":
                    header.mainHeaderLabel?.text = (ActivitiesAtDayArray[section][0].activityDate?.stringFromDate())!
                    break
                case "subject":
                    header.mainHeaderLabel?.text = ActivitiesAtSubjectArray[section][0].activitySubject! == "" ? "Дополнительно" : ActivitiesAtSubjectArray[section][0].activitySubject!
                    break
                default:
                    header.mainHeaderLabel?.text = " "
                    break
                }
            }
        } else {
            header.mainHeaderLabel?.text = "Доп. возможности"
            header.mainHeaderLabel?.textAlignment = .center
            header.viewCornerRadius = 15.0
        }
       
        
        return header
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
       
        let footer = HeaderFooterViewClass.initFooter(withWidth: tableView.frame.width)
        if (section == (tableView.numberOfSections - 1)) {
            //footer.leftFooterButton?.isHidden = false
          //  footer.rightFooterButton?.isHidden = false
            footer.leftFooterButton?.setTitle("Сделанные", for: .normal)
            footer.rightFooterButton?.setTitle("Просроченные", for: .normal)
            footer.leftFooterButton?.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
            footer.leftFooterButton?.isHidden = false
            doneButton = footer.leftFooterButton!
            
            footer.rightFooterButton?.addTarget(self, action: #selector(prosrButtonPressed), for: .touchUpInside)
            footer.rightFooterButton?.isHidden = false
            prosrButton = footer.rightFooterButton!
            
        }
        footer.viewCornerRadius = 15.0
        
        return footer
    }
    
    @objc func doneButtonPressed(_ sender: UIButton!){
       // if(!workingWithToday){
        counterp = 0
        if (counterd == 0) {
            doneButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            prosrButton.backgroundColor = UIColor.clear
          //  let oldLengthOfSection = timeTableArray.count
            workingWithDone = true
            workingWithProsr = false
            counterd+=1
        }
        else {
            doneButton.backgroundColor = UIColor.clear
            prosrButton.backgroundColor = UIColor.clear
            //  let oldLengthOfSection = timeTableArray.count
            workingWithDone = false
            workingWithProsr = false
            counterd = 0
        }
        
    }
    
    @objc func prosrButtonPressed(_ sender: UIButton!){
       // if(workingWithToday){
        counterd = 0
        if (counterp == 0) {
            doneButton.backgroundColor = UIColor.clear
            prosrButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            //let oldLengthOfSection = timeTableArray.count
            workingWithDone = false
            workingWithProsr = true
            counterp+=1
        }
        else {
            doneButton.backgroundColor = UIColor.clear
            prosrButton.backgroundColor = UIColor.clear
            //let oldLengthOfSection = timeTableArray.count
            workingWithDone = false
            workingWithProsr = false
            counterp = 0
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == (tableView.numberOfSections - 1)) {
            return 50
        }
        else {return 25}
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    }
