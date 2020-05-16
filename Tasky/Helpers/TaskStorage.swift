//
//  TaskStorage.swift
//  Tasky
//
//  Created by Cristian villanueva on 5/11/20.
//  Copyright © 2020 Cristian villanueva. All rights reserved.
//

import Foundation

class TaskStorage {
    
    var tasks = [[Task](),[Task]()] // array of tasks lists
    
    

    func add(_ task: Task, at index: Int, isDone: Bool = false){
        let section = isDone ? 1 : 0
        tasks[section].insert(task, at: index)
    }
    
    @discardableResult func remove(at index: Int, isDone: Bool = false) -> Task {
        let section = isDone ? 1 : 0
        return tasks[section].remove(at: index)
    }
    

    
}
