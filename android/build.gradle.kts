allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// isar_flutter_libs 3.1.0+1 predates AGP 8 and declares no namespace in its
// build file; supply the one from its manifest.
subprojects {
    if (project.name == "isar_flutter_libs") {
        pluginManager.withPlugin("com.android.library") {
            val android = extensions.findByName("android")
            if (android != null) {
                val current = android.javaClass.getMethod("getNamespace").invoke(android)
                if (current == null) {
                    android.javaClass
                        .getMethod("setNamespace", String::class.java)
                        .invoke(android, "dev.isar.isar_flutter_libs")
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
