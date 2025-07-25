// ✅ Firebase plugin setup
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ Firebase Gradle plugin
        classpath("com.google.gms:google-services:4.4.0")
    }
}

// ✅ Repositories for all modules
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Custom build directory setup (your original code — unchanged)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
