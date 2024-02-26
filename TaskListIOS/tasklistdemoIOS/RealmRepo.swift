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
    @Published private(set) dynamic var jobResults: Results<Job>?
    @Published private(set) var jobs : List<Job> = List.init()
    
    
    init() {
        //openRealm()
        Task{
            await self.openSyncRealm()
        }
    }

    
    @MainActor
    func openSyncRealm() async {
        do {
            let app = App(id: "APP_ID")
            let email = "test@mongodb.com"
            let password = "123456"
            let user = try await app.login(credentials: Credentials.emailPassword(email: email, password: password))
            
            var config = user.flexibleSyncConfiguration(initialSubscriptions: { subs in
                let jobSubscriptionExists = subs.first(named: "job")
                if (jobSubscriptionExists != nil)  {
                    // Existing subscriptions found - do nothing
                    return
                    } else {
                        subs.append(QuerySubscription<Job>(name: "job"))
                    }
            })
            //PENDING to set up realm file name
            config.objectTypes = [Job.self, Status.self]
            localRealm = try await Realm(configuration: config, downloadBeforeOpen: .always)
            
            print ("Successfully opened realm: \(String(describing: localRealm))")
            
            print("Reading previous jobs...")
            getJobs()
        }catch{
            print("Error initializing realm: \(error)")
        }
       
    }
    
    func addJob(jobTitle: String){
        if let localRealm = localRealm {
            do {
                print("subscription count:  \(localRealm.subscriptions.count)")
                try localRealm.write{
                    let newStatus = Status()
                    newStatus.status = status_enum.todo
                    newStatus.date = Date()
                    
                    let newJob = Job()
                    newJob.name = jobTitle
                    newJob._id = .generate()
                    newJob.userid = 5
                    newJob.currentStatus = newStatus.status
                    
                    let myList = RealmSwift.List<Status>()
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
            
            jobResults = localRealm.objects(Job.self).sorted(byKeyPath: "currentStatus")
            jobs = List.init()
            jobResults!.forEach { job in
                jobs.append(job)
            }
            print("There are \(jobs.count) jobs")
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
                    print("Deleted job with id \(_id)")
                    getJobs()
                }
            }catch {
                print("Error deleting job \(_id) from Realm: \(error)")
            }
            
        }
    }
}
