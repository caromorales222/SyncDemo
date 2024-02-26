import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "1.9.0"
    id("io.realm.kotlin") version "1.10.2"
    `maven-publish`
}

group = "com.mongodb"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

java {
    withSourcesJar()
    withJavadocJar()

    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17

}

publishing {
    publications {
        create<MavenPublication>("RealmKotlinInterface") {
            from(components["kotlin"])
            groupId = project.group as String
            artifactId = "kotlin-lib"
            version = project.version as String
            artifact(tasks["javadocJar"])
            artifact(tasks["sourcesJar"])
        }
    }
    repositories {
        mavenLocal()
    }
}

dependencies {
    api("io.realm.kotlin:library-sync-jvm:1.10.2")
    api("io.reactivex.rxjava3:rxjava:3.1.6")
    api("org.jetbrains.kotlinx:kotlinx-coroutines-rx3:1.6.4")
    implementation ("org.slf4j:slf4j-api:2.0.5")
    testImplementation(platform("org.junit:junit-bom:5.9.2"))
    testImplementation("org.junit.jupiter:junit-jupiter")
}

/*kotlin{
    jvmToolchain(17)
}
 */

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    kotlinOptions {
        jvmTarget = "17"
    }
}

tasks.test {
    useJUnitPlatform()
}