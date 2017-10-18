//
//  taskModel.swift
//  StudentsApp
//
//  Created by Владислав Захаров on 05.10.17.
//  Copyright © 2017 Владислав Захаров. All rights reserved.
//

import UIKit
import CoreData

class TaskModel: NSObject {
    var TasksDatabaseObject: Tasks?
    var taskDate: CustomDateClass?
    var taskNameShort: String?
    var taskSubject: String?
    var taskPriority: Int?
    var taskDescription: String?
    var taskStatus: Int?
    
    static func getTasks() -> Array<TaskModel>{
        //Получаем список заданий
        var returnArray: Array<TaskModel> = Array()
        
        let fetchRequest:NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        do{
            let searchResults = try DatabaseController.getContext().fetch(fetchRequest)
            
            for result in searchResults as [Tasks]{
                returnArray.append(TaskModel(withDatabaseObject: result))
            }
        }
        catch{
            print("Error: \(error)")
        }

        return returnArray
    }
    
    static func getTasksGroupedByPriority() -> [[TaskModel]] {
        var returnArray = [[TaskModel]]()
        let fetchRequest:NSFetchRequest<Tasks> = Tasks.fetchRequest()
        let sortDesrt = NSSortDescriptor(key: #keyPath(Tasks.date), ascending: true)
        fetchRequest.sortDescriptors = [sortDesrt]
        
        do{
            let tasks = try DatabaseController.getContext().fetch(fetchRequest)
            var highPriotity = [TaskModel]()
            var midPriotity = [TaskModel]()
            var lowPriotity = [TaskModel]()
            var other = [TaskModel]()
            for task in tasks {
                switch task.priority {
                case 2 :
                    highPriotity.append(TaskModel(withDatabaseObject: task))
                    break
                case 1 :
                    midPriotity.append(TaskModel(withDatabaseObject: task))
                    break
                case 0 :
                    lowPriotity.append(TaskModel(withDatabaseObject: task))
                    break
                default:
                    other.append(TaskModel(withDatabaseObject: task))
                    break
                }
            }
            returnArray.append(highPriotity)
            returnArray.append(midPriotity)
            returnArray.append(lowPriotity)
            returnArray.append(other)
        }catch{
            print("Error getting activities grouped by date. \(error.localizedDescription)")
        }
        return returnArray
    }
    
    static func getTasksGroupedByDate() -> [[TaskModel]] {
        var returnArray = [[TaskModel]]()
        let fetchRequest:NSFetchRequest<Tasks> = Tasks.fetchRequest()
        let sortDesrt = NSSortDescriptor(key: #keyPath(Tasks.date), ascending: true)
        fetchRequest.sortDescriptors = [sortDesrt]
        do{
            let tasks = try DatabaseController.getContext().fetch(fetchRequest)
            //---Creating random date to be able to start the loop
            var dateComponents = DateComponents()
            dateComponents.year = 1975
            var oldDate:Date = Calendar.current.date(from: dateComponents)!
            var tmpArray = [TaskModel]()
            for task in tasks {
                let oder = Calendar.current.compare(task.date!, to: oldDate, toGranularity: .day)
                
                //---Checking if this activity has the same date as the last one
                if oder != .orderedSame {
                    if tmpArray.count != 0 {
                        returnArray.append(tmpArray)
                    }
                    tmpArray = [TaskModel]()
                    tmpArray.append(TaskModel(withDatabaseObject: task))
                }
                else{
                    tmpArray.append(TaskModel(withDatabaseObject: task))
                }
                oldDate = task.date!
            }
        }catch{
            print("Error getting activities grouped by date. \(error.localizedDescription)")
        }
        return returnArray
    }
    
    static func getTasksGroupedBySubject() -> [[TaskModel]] {
        var returnArray = [[TaskModel]]()
        
        let fetchRequest:NSFetchRequest<Subjects> = Subjects.fetchRequest()
        
        do{
            //---Get all subjects... sorted, etc.
            let sortDescr = NSSortDescriptor(key: #keyPath(Subjects.name), ascending: true)
            fetchRequest.sortDescriptors = [sortDescr]
            let subjects = try DatabaseController.getContext().fetch(fetchRequest)
            
            //---fillout the res array
            for subject in subjects {
                var tmpArray: Array<TaskModel> = Array<TaskModel>()
                let tasks = (subject.tasks?.allObjects as! [Tasks]).sorted(by: {$0.date! < $1.date!})
                if tasks.count > 0 {
                    for task in tasks as [Tasks]{
                        tmpArray.append(TaskModel(withDatabaseObject: task))
                    }
                    returnArray.append(tmpArray)
                }
            }
        }
        catch{
            print("Error: \(error)")
        }
        
        return returnArray
    }
    
    func addTask() -> Bool {
        //Добавляем задание в БД
        return false
    }
    
    func deleteTask() -> Bool {
        //Удаляем задание из БД
        return false
    }
    
    func updateTask() -> Bool {
        //Обновляем задание в БД
        return false
    }
    
    override init() {
        super.init()
    }
    
    init(withDatabaseObject: Tasks) {
        super.init()
        
        self.TasksDatabaseObject = withDatabaseObject
        
        self.taskNameShort = TasksDatabaseObject?.shortName != nil ? TasksDatabaseObject?.shortName! : nil;
        self.taskPriority = TasksDatabaseObject?.priority != nil ? Int(TasksDatabaseObject!.priority) : nil;
        self.taskDescription = TasksDatabaseObject?.descrp != nil ? TasksDatabaseObject?.descrp! : nil;
        self.taskStatus = TasksDatabaseObject?.status != nil ? Int(TasksDatabaseObject!.status) : nil;
        self.taskSubject = TasksDatabaseObject?.subject != nil ? TasksDatabaseObject?.subject!.name! : nil;
        self.taskDate = TasksDatabaseObject?.date != nil ? CustomDateClass(withDate: (TasksDatabaseObject?.date)!) : nil;
    }

}
