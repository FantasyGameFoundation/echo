allprojects {
    repositories {
        maven("https://maven.aliyun.com/repository/google")
        maven("https://maven.aliyun.com/repository/central")
        maven("https://maven.aliyun.com/repository/public")
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
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    pluginManager.withPlugin("com.android.library") {
        val androidExtension = extensions.findByName("android") ?: return@withPlugin
        val getNamespace =
            androidExtension.javaClass.methods.firstOrNull { method ->
                method.name == "getNamespace" && method.parameterCount == 0
            } ?: return@withPlugin
        val currentNamespace = getNamespace.invoke(androidExtension) as? String
        if (!currentNamespace.isNullOrBlank()) {
            return@withPlugin
        }

        val setNamespace =
            androidExtension.javaClass.methods.firstOrNull { method ->
                method.name == "setNamespace" &&
                    method.parameterCount == 1 &&
                    method.parameterTypes.firstOrNull() == String::class.java
            } ?: return@withPlugin
        setNamespace.invoke(androidExtension, project.group.toString())
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
