//
//  TodayTabViewController.swift
//  StudentsApp
//
//  Created by Владислав Захаров on 10.10.17.
//  Copyright © 2017 Владислав Захаров. All rights reserved.
//

import UIKit

class TodayTabViewController: UIViewController {

    // MARK: - Variables
    //@IBOutlet weak var TodayDateLabel: UILabel!
    //@IBOutlet weak var ProgressViewOutlet: UIProgressView!
    @IBOutlet weak var TableViewOutlet: UITableView!
    
    let TimetableCellIdentifier = "TimetableCell"
    let TasksCellIdentifier = "TaskCell"
    let TopCellIdentifier = "TopCell"
    
    var shownFirstTime = 1
    
    var timeTableArray: [TimetableModel]! //Добавляем пустой массив расписания
    var tasksArray: [TaskModel]! //Добавляем пустой массив заданий
    
    var chosenObject = 0

    var blurEffectView: UIVisualEffectView?
    
    // MARK: - View Functions
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(shownFirstTime == 1){
            UIView.animate(withDuration: 2.0, delay: 1.0, options: .curveEaseInOut, animations: {
                let startCell = IndexPath(row: 0, section: 1)
                self.TableViewOutlet.scrollToRow(at: startCell, at: .bottom , animated: false)
                }, completion: nil)
            shownFirstTime = 0
        }
    }
    func getSetectedStudyPlace() -> Array<studyUnit>{
        //Get selected items into UserDefaults
        do{
            let selectedUniversity = try JSONDecoder().decode(studyUnit.self, from: UserDefaults.standard.data(forKey: "selectedUniversity")!)
            let selectedFaculty = try JSONDecoder().decode(studyUnit.self, from: UserDefaults.standard.data(forKey: "selectedFaculty")!)
            let selectedGroup = try JSONDecoder().decode(studyUnit.self, from: UserDefaults.standard.data(forKey: "selectedGroup")!)
            print([selectedUniversity, selectedFaculty, selectedGroup])
            return [selectedUniversity, selectedFaculty, selectedGroup]
        }catch{
            print("Unable to decode selectedJson")
        }
        return []
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //let databaseIsInited = UserDefaults.standard.bool(forKey: "databaseIsInited")
        //date1 = CustomDateClass()
        //self.prefersStatusBarHidden = true
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "BackGroundImage")!)
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.image = UIImage(named: "BackGroundImage")
        self.view.insertSubview(backgroundImage, at: 0)
        /*
        blurView = UIView()
        blurView!.frame = UIScreen.main.bounds
        blurView!.backgroundColor = UIColor.clear
        self.view.insertSubview(blurView!, at: 1)
         */
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView!.frame = view.bounds
        blurEffectView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView!.alpha = 0.0;
        self.view.insertSubview(blurEffectView!, at: 1)
        
        TableViewOutlet.backgroundColor = UIColor.clear
        
        //TableViewOutlet.rowHeight = UITableViewAutomaticDimension
        TableViewOutlet.estimatedRowHeight = 120
        TableViewOutlet.autoresizesSubviews = true
        
        //Полуение массива предметов
        let cust = CustomDateClass()
        timeTableArray = TimetableModel.getTimetable(Date: cust)
        tasksArray = TaskModel.getTasks()

        // Do any additional setup after loading the view.
        let taskCellNib = UINib(nibName: "TaskTableViewCell", bundle: nil)
        TableViewOutlet.register(taskCellNib, forCellReuseIdentifier: TasksCellIdentifier)
        let timetableCellNib = UINib(nibName: "TimetableTableViewCell", bundle: nil)
        TableViewOutlet.register(timetableCellNib, forCellReuseIdentifier: TimetableCellIdentifier)
        let topCellNib = UINib(nibName: "UpperTodayTableViewCell", bundle: nil)
        TableViewOutlet.register(topCellNib, forCellReuseIdentifier: TopCellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "fromTodayToTasksView"){
            let taskVC = segue.destination as! TaskViewEditViewController
            taskVC.taskModelObject = tasksArray[chosenObject]
        }
    }
    
    func makeRoundedMask(forTop: Bool, bounds: CGRect) -> CAShapeLayer {
        let corners:UIRectCorner = (forTop ? [.topLeft , .topRight] : [.bottomRight , .bottomLeft])
        let maskPath = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: corners,
                                     cornerRadii:CGSize(width:15.0, height:15.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        return maskLayer
    }

}

// MARK: - UIScrollViewDelegate protocol
extension TodayTabViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //blurView!.backgroundColor = UIColor(white: 1.0, alpha: scrollView.contentOffset.y/180)
        blurEffectView!.alpha = scrollView.contentOffset.y/180;
    }
}

// MARK: - UITableViewDelegate protocol
extension TodayTabViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if(indexPath.section == 2){
            self.hidesBottomBarWhenPushed = true
            chosenObject = indexPath.item
            self.performSegue(withIdentifier: "fromTodayToTasksView", sender: self)
            self.hidesBottomBarWhenPushed = false
        }
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if(indexPath.section == 2){
           let selectedTaskCell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
            selectedTaskCell.setHighlighted(false, animated: false)
            selectedTaskCell.rounedView?.backgroundColor = selectedTaskCell.cellColor
        }
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if(indexPath.section == 2){
            let selectedTaskCell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
            selectedTaskCell.rounedView?.backgroundColor = UIColor.clear
        }
    }
    
}

// MARK: - UITableViewDataSource protocol
extension TodayTabViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return  1
            
        case 1:
            return timeTableArray.count != 0 ? timeTableArray.count : 1
            
        case 2:
            return tasksArray.count
            
        default:
            return 1
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if(indexPath.section == 0){
            let identifier = TopCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! UpperTodayTableViewCell
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            
            return cell
        }
        
        if (indexPath.section == 1) { //Берем расписание
            let identifier = TimetableCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! TimetableTableViewCell
            if(timeTableArray.count == 0){
                cell.SubjectNameLabel.text = "Нет Пар"
                return cell
            }
            cell.initWithTimetable(model: timeTableArray[indexPath.item])

            return cell
            
        }else{
            let identifier = TasksCellIdentifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as!  TaskTableViewCell
            
            cell.initWithTask(model: tasksArray[indexPath.item], forSortingType: "Today")
            
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        switch indexPath.section {
        case 0:
            
            return  self.view.frame.height - (self.tabBarController?.tabBar.frame.height)! - 50
            
        case 1:
            return 120
            
        case 2:
            return 80
            
        default:
            return 1
            
        }
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0){
            return nil
        }
        let sectionHeaderView = UIView()
        sectionHeaderView.frame = CGRect(x:0,y:0,width:tableView.frame.width,height:50)
        sectionHeaderView.layer.mask = makeRoundedMask(forTop: true, bounds: sectionHeaderView.bounds)
        sectionHeaderView.backgroundColor = UIColor(red: 153/255, green: 157/255, blue: 163/255, alpha: 0.25)
        
        let sectionHeaderLabel = UILabel()
        sectionHeaderLabel.frame = CGRect(x:0,y:0,width:tableView.frame.width,height:50)
        sectionHeaderLabel.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.black)
        if(section == 1){
            sectionHeaderLabel.text = "Расписание"
        }else{
            sectionHeaderLabel.text = "Задания"
        }
        
        sectionHeaderView.addSubview(sectionHeaderLabel)
        
       return sectionHeaderView
        
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if(section == 0){
            return nil
        }
        
        let sectionFooterView = UIView()
        sectionFooterView.frame = CGRect(x:0,y:0,width:tableView.frame.width,height:50)
        sectionFooterView.backgroundColor = UIColor.clear
        
        let sectionHeaderLabel = UILabel()
        sectionHeaderLabel.frame = CGRect(x:0,y:0,width:tableView.frame.width,height:40)
        sectionHeaderLabel.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.black)
        sectionHeaderLabel.backgroundColor = UIColor(red: 153/255, green: 157/255, blue: 163/255, alpha: 0.25)
        sectionHeaderLabel.layer.mask = makeRoundedMask(forTop: false, bounds: sectionHeaderLabel.bounds)
        
        sectionFooterView.addSubview(sectionHeaderLabel)
        
        return sectionFooterView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 50
    }
}