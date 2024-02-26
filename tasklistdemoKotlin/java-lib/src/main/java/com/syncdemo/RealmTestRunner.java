package com.syncdemo;

import io.realm.kotlin.notifications.ResultsChange;
import io.realm.kotlin.query.RealmResults;
import kotlinx.coroutines.flow.Flow;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CountDownLatch;

/**
 * This class shows how you can bridge between Realm Kotlin and a Java code base
 * using a repository interface.
 *
 * The repository interface is created on the Kotlin side, but will only expose
 * methods that are nice to use from the Java side.
 */
public class RealmTestRunner {

    /**
     * Run all test methods
     */
    Thread t1;
    Thread t2;
    RealmRepository repo;
    String userid;
    Random rd;
    List<String> status = new ArrayList<String>(){{add("TODO");add("PENDING"); add("DONE");}};

    public RealmTestRunner(String userid){
        this.userid = userid;
        rd = new Random();
    }
    public void start() throws InterruptedException {

        repo = new RealmRepository();

        info("Open Realm");

        List<Integer> useridList = new ArrayList<>();
        if (userid.equals("admin")){
            repo.openSyncRealmForAdmin();
        }
        else{
            repo.openSyncRealm(Integer.valueOf(userid));
        }

        //repo.updateSubscription(userid);
        info ("Realm opened");

        // Register Flow
        CountDownLatch bg1Started = new CountDownLatch(1);
        t1 = new Thread(() -> {
            repo.updatesAsRxJavaObserverable().subscribe((ResultsChange<Task> event) -> {
                info("Got update from RxJava observable: " + event.getClass() + ", size: " + event.getList().size());
            });
            bg1Started.countDown();
        });
        t1.start();
        bg1Started.await();

        // Register callbacks
        CountDownLatch bg2Started = new CountDownLatch(1);
        t2 = new Thread(() -> {
            CancellationToken token = null;
            try {
                token = repo.updatesAsCallbacks(event -> {
                    info("Got update from Callback observable: " + event.getClass() + ", size: " + event.getList().size());
                });
                bg2Started.countDown();
            } catch (Exception e) {
                if (token != null) {
                    token.cancel();
                }
            }
        });
        t2.start();
        bg2Started.await();

    }

    public void insertTask() {
        info("Write a new task");
        Task myTask = new Task();

        int taskUser= 0;
        if (userid.equals("admin")){
            taskUser = rd.nextInt(10);
        }else{
            taskUser = Integer.valueOf(userid);
        }

        myTask.setUserid(taskUser);
        myTask.setTaskName("Tasks" + String.valueOf(rd.nextLong()));
        myTask.setCategory("category" + String.valueOf(rd.nextInt(20)));
        Status defaultStatus = new Status("TODO", LocalDateTime.now());
        myTask.setCurrentStatus(defaultStatus.getStatus());
        myTask.setHistory(new ArrayList<Status>() {{
            add(defaultStatus);
        }});
        repo.writeData(new ArrayList<Task>() {{
            add(myTask);
        }});
    }

    public void updateTask()
    {
        Status newObject = new Status(status.get(rd.nextInt(status.size())), LocalDateTime.now());
        repo.updateData(newObject);
    }

    public void readData(){
        info("Read data");
        RealmResults<Task> tasks = repo.readData();
        for (Task task : tasks){
            System.out.println(task.toString());
        }
        info("Found " + tasks.size() + " tasks for userid " + userid);

    }

    public void stop()
    {
        t1.interrupt();
        t2.interrupt();
        repo.closeRealm();
        info("Closed Realm");
    }

    private void info(String message) {
        System.out.println(message);
    }

}
