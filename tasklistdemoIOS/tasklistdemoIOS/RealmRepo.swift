//
//  RealmRepo.swift
//  tasklistdemoIOS
//
//  Created by Carolina Morales Aguayo on 31/8/23.
//

import Foundation
import RealmSwift

class RealmRepo: ObservableObject {
    private(set) var localRealm: Realm?
    //@Published private(set) var tasks: Results<Task>? = nil
    @Published private(set) var jobs: [Job] = []
    
    init() {
        //openRealm()
        Task{
            await self.openSyncRealm()
        }
        getJobs()
    }
    
    /*func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion:1)
            
            Realm.Configuration.defaultConfiguration = config
            localRealm = try Realm()
            
        }catch {
            print("Error openning realm: \(error)")
        }
    }*/
    
    @MainActor
    func openSyncRealm() async {
        do {
            let app = App(id: "tasklistapp-souqw")
            let user = try await app.login(credentials: Credentials.anonymous)
            var config = user.flexibleSyncConfiguration()
            //PENDING to set up realm file name
            config.objectTypes = [Job.self, Status.self]
            localRealm = try await Realm(configuration: config, downloadBeforeOpen: .always)
            
            print ("Successfully opened realm: \(String(describing: localRealm))")
        }catch{
            print("Error initilizing realm: \(error)")
        }
       
    }
    
    func addJob(jobTitle: String){
        if let localRealm = localRealm {
            do {
                try localRealm.write{
                    let newStatus = Status()
                    newStatus.status = status_enum.todo
                    newStatus.date = Date()
                    
                    let newJob = Job()
                    newJob.name = jobTitle
                    newJob._id = ObjectId()
                    newJob.userid = 5
                    newJob.currentStatus = newStatus.status
                    
                    var myList = RealmSwift.List<Status>()
                    myList.append(newStatus)
                    newJob.history = myList
                    print("create jobs")
                    localRealm.add(newJob)
                    getJobs()
                    print("Added new job to Realm: \(newJob)")
                }
            }catch{
                print("Error adding job to Realm: \(error)")
            }
        }
    }
    
    func getJobs(){
        if let localRealm = localRealm {
            //tasks = localRealm.objects(Task.self)
            let allJobs = localRealm.objects(Job.self).sorted(byKeyPath: "currentStatus")
            jobs = []
            allJobs.forEach { job in
                jobs.append(job)
            }
        }
    }
    
    func updateJob(_id: ObjectId){
        if let localRealm = localRealm  {
            do {
                let jobToUpdate = localRealm.objects(Job.self).filter(NSPredicate(format: "_id == %@", _id))
                guard !jobToUpdate.isEmpty else {return}
                
                try localRealm.write{
                    
                    let newStatus = Status (value: ["status": jobToUpdate[0].currentStatus.next(), "date": Date()] as [String: Any])
                    jobToUpdate[0].currentStatus = newStatus.status
                    jobToUpdate[0].history.append(newStatus)
                    getJobs()
                    print("Updated job with id \(_id)! New status: \(newStatus.status)")
                }
            }catch {
                print("Error updating job \(_id) to Realm: \(error)")
            }
        }
    }
        
    func deleteJob(_id: ObjectId){
        if let localRealm = localRealm {
            do {
                let jobToDelete = localRealm.objects(Job.self).filter(NSPredicate(format: "_id == %@", _id))
                guard !jobToDelete.isEmpty else {return}
                
                try localRealm.write{
                    localRealm.delete(jobToDelete)
                    getJobs()
                    print("Deleted job with id \(_id)")
                }
            }catch {
                print("Error deleting job \(_id) from Realm: \(error)")
            }
        }
    }
}
