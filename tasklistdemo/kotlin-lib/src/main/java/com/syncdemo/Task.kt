package com.syncdemo

import io.realm.kotlin.ext.realmListOf
import io.realm.kotlin.types.EmbeddedRealmObject
import io.realm.kotlin.types.RealmInstant
import io.realm.kotlin.types.RealmList
import io.realm.kotlin.types.RealmObject
import io.realm.kotlin.types.annotations.Ignore
import io.realm.kotlin.types.annotations.PersistedName
import io.realm.kotlin.types.annotations.PrimaryKey
import org.mongodb.kbson.ObjectId
import java.time.LocalDateTime
import java.time.ZoneOffset
import java.util.Date

class Task: RealmObject {
    @PrimaryKey
    var _id = ObjectId()
    var userid: Int = 0
    var taskName: String = ""
    var category: String = ""
    var history: RealmList<Status> = realmListOf<Status>()
    var currentStatus : String = ""

    // Expose method making it easier to use from Java
    fun setHistory(status: ArrayList<Status>) {
        history.addAll(status)
    }

    override fun toString(): String {

        return "Task(userid='$userid', taskName=$taskName, history=$history, currentStatus=$currentStatus)"
    }


}

class Status(status: String, statusDate: LocalDateTime ) : EmbeddedRealmObject {
    // No-arg constructor required by Realm
    constructor(): this("", LocalDateTime.MIN)

    var status : String = status
    var date : RealmInstant = RealmInstant.from(statusDate.toEpochSecond(ZoneOffset.UTC), statusDate.nano)

    override fun toString(): String {
        return "History(status='$status', date:'$date')"
    }
}