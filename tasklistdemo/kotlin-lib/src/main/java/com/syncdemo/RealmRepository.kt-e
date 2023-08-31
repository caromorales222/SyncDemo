package com.syncdemo

import io.reactivex.rxjava3.core.Observable
import io.realm.kotlin.MutableRealm
import io.realm.kotlin.Realm
import io.realm.kotlin.RealmConfiguration
import io.realm.kotlin.ext.query
import io.realm.kotlin.mongodb.*
import io.realm.kotlin.mongodb.sync.SyncConfiguration
import io.realm.kotlin.notifications.ResultsChange
import io.realm.kotlin.query.RealmResults
import io.realm.kotlin.types.BaseRealmObject
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.rx3.asObservable
import org.mongodb.kbson.ObjectId
import kotlin.time.Duration.Companion.seconds

class CancellationToken(val job: Job) {
    fun cancel() {
        job.cancel()
    }
}

class RealmRepository {

    interface UpdateCallback {
        fun update(realm: MutableRealm)
    }

    interface EventCallback<E: BaseRealmObject> {
        fun update(item: ResultsChange<E>)
    }

    var appId = "APP_ID"
    lateinit var realm: Realm
    private var app: App = App.create(appId)
    lateinit var user: User

    constructor()

    fun openRealm() {
        val config = RealmConfiguration.Builder(schema = setOf(Task::class, Status::class))
            .name("demo-realm.realm")
            .build()
        realm = Realm.open(config)
    }

    fun openSyncRealm(userid:Int) {

        runBlocking {
            user = app.login(Credentials.emailPassword("test@mongodb.com", "123456"))

            val syncConfig = SyncConfiguration.Builder(user, setOf(Task::class, Status::class))
                .waitForInitialRemoteData(timeout = 30.seconds)
                .initialSubscriptions { realm ->
                    add( realm.query<Task>( "userid == $0", userid ), "Task subscription", updateExisting = true )
                }
                .name("demo-realm-sync$userid.realm")
                .build()

            realm = Realm.open(syncConfig)
            realm.syncSession.downloadAllServerChanges(30.seconds)
        }
    }

    fun openSyncRealmForAdmin() {

        runBlocking {
            user = app.login(Credentials.emailPassword("test@mongodb.com", "123456"))

            val syncConfig = SyncConfiguration.Builder(user, setOf(Task::class, Status::class))
                .waitForInitialRemoteData(timeout = 30.seconds)
                .initialSubscriptions { realm ->
                    add( realm.query<Task>(), "Task subscription", updateExisting = true )
                }
                .name("demo-realm-syncAdmin.realm")
                .build()

            realm = Realm.open(syncConfig)
            realm.syncSession.downloadAllServerChanges(30.seconds)
        }
    }

    fun updateSubscription(userid: String) {
        runBlocking {
            realm.subscriptions.update { realm ->
                add(realm.query<Task>("userid == $0", userid), "Task subscription", updateExisting = true);
                //add(realm.query<Status>("_id != $0", ObjectId(0)), "Status subscription", updateExisting = true);
            }
        }
    }

    fun closeRealm() {
        checkRealm()
        realm.close()
    }

    fun writeData(list: List<Task>) {
        realm.writeBlocking {
            list.forEach { task: Task ->
                copyToRealm(task)
            }
        }
    }

    fun updateData(newStatus: Status) {

        System.out.println("status: " + newStatus.status)
        realm.writeBlocking {
            val task: Task? = query<Task>().first().find()
            task?.currentStatus = newStatus.status
            task?.history?.add(newStatus)
        }
    }

    fun readData(): RealmResults<Task> {
        return realm.query<Task>().find();
    }

    fun updatesAsRxJavaObserverable(): Observable<ResultsChange<Task>> {
        return realm.query<Task>("_id != $0", ObjectId(0) ).asFlow().asObservable()
    }

    fun updatesAsCoroutineFlow(): Flow<ResultsChange<Task>> {
        return realm.query<Task>("_id != $0", ObjectId(0)).asFlow()
    }

    // Expose as callbacks with a cancellation token
    fun updatesAsCallbacks(callback: EventCallback<Task>): CancellationToken {
        val job = CoroutineScope(Dispatchers.Default).launch {
            async {
                realm.query<Task>("_id != $0", ObjectId(0)).asFlow().collect { event: ResultsChange<Task> ->
                    callback.update(event)
                }
            }
        }
        return CancellationToken(job)
    }

    private fun checkRealm() {
        if (!this::realm.isInitialized) {
            throw IllegalStateException("Realm must be opened before calling any other functions.")
        }
    }

}
