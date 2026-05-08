//import androidx.compose.foundation.text2.input.delete
import org.gradle.api.tasks.compile.JavaCompile
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Plugin Google Services pour Firebase
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("com.google.gms:google-services:4.4.1")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuration du dossier de build (Standard Flutter)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


        subprojects {
            tasks.withType<JavaCompile>().configureEach {
                options.compilerArgs.add("-Xlint:-options")
                sourceCompatibility = JavaVersion.VERSION_17.toString()
                targetCompatibility = JavaVersion.VERSION_17.toString()
            }
        }