This is a demo with Kotlin SDK Realm and Java

## Functionality
The use case presented here is a collection with tasks that can be assigned to different users. Each user can check and modify their own tasks. There is an admin user that can access and modify all tasks.
Any modification in the tasks (category, name, status, etc) is accessible to each user. 
Synchronization for task modification is bidirectional: from final users to main core DB and vice-versa.

## Environment set up

### What's needed

1. M0 cluster in MongoDB Atlas.
2. realm-cli installed. Find it: https://www.mongodb.com/docs/atlas/app-services/cli/
3. IntelliJ development environment
4. Realm Studio (optional)

### Environment build

1. Create a M0 cluster in Atlas.
2. Create an API Key in the project with "Project Owner" privileges.
3. Login to App Services using "realm-cli"
```
realm-cli login --api.key "<PUBLIC_API_KEY>" --private-api-key "<PRIVATE_API_KEY>"
```
4. In the application, replace the name of the M0 cluster you created.
  ```` 
cd TaskListApp
sed -i -e 's/CLUSTER_NAME/<YOUR_CLUSTER_NAME>/g' data_sources/mongodb-atlas/config.json
````
5. Import the application
```
realm-cli push -y
```
Select your Atlas Project
6. Create user for the application:
````
realm-cli users create --type email --email 'test@mongodb.com' --password '123456'
````
7. In Atlas M0 cluster, go to "Collections" tab and create a new namespace with database "Sync" and collection "Task". Do not insert any document in the collection.
8. In Atlas, App Services, go to the "TaskListApp" application and copy the application ID. 
9. Replace the application ID in Java-Kotlin code:
````
cd tasklistdemo
sed -i -e 's/APP_ID/<YOUR_APP_ID>/g' kotlin-lib/src/main/java/com/syncdemo/RealmRepository.kt
````

## Test the environment 

### A user insert a new task.
Go to IntelliJ and run the code with the arguments "<userId> insert". <userId> can be any number between 1 and 9. 
User 9 is the admin user. If this one is selected a task is created for any other random user.

##### In the Realm file
Use Realm Studio to open the realm file with the name "demo-realm-sync$userid". Check all tasks belongs to the selected user. If admin user is selected, all tasks are included.

##### In Atlas
Use Atlas to check a new document has been added to Task collection

### A user update a task.
The status of a task is updated.
Go to IntelliJ and run the code with arguments "<userId> update". <userId> can be any number between 1 and 9.
User 9 is the admin user. If this one is selected a task is updated for any other random user.

##### In the Realm file
Use Realm Studio to open the realm file with the name "demo-realm-sync$userid". Check all tasks belongs to the selected user. Check the If admin user is selected, all tasks are included.

##### In Atlas
use Atlas to check one of the document for the selected user has been modified and a new status is added.

### A user reads its tasks.
Go to IntelliJ and run the code with arguments "<userId> update". <userId> can be any number between 1 and 9.
User 9 is the admin user. If this one is selected all tasks are retrieved.
