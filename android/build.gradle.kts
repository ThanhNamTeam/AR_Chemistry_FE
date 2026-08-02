allprojects {
    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs("${rootProject.projectDir}/../unityLibrary/libs")
        }
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

// ---------------------------------------------------------------------------
// :unityLibrary:buildIl2Cpp
//
// This Unity export already ships a fully built arm64 libil2cpp.so
// (unityLibrary/src/main/jniLibs/arm64-v8a/libil2cpp.so - ELF64/AArch64) together with
// unityLibrary/symbols/arm64-v8a/libil2cpp.so. Unity ran IL2CPP during the export and then
// MOVED the IL2CPP data folder into the APK assets - it now lives at
// unityLibrary/src/main/assets/bin/Data/Managed/Metadata/global-metadata.dat - so
// Il2CppOutputProject/Source/il2cppOutput/data no longer exists.
//
// The Unity-generated buildIl2Cpp task nevertheless re-invokes il2cpp.exe with
// --data-folder=.../Source/il2cppOutput/data (and --usymtool-path=.../usymtool.exe, which
// the export also omits). Neither path exists, so il2cpp.exe aborts with exit code 4.
//
// Skip the task when it cannot possibly run AND the prebuilt library is present, so the
// already-built library from the export is used. If the prebuilt library is ALSO missing we
// deliberately let the task run, so a genuinely incomplete export fails loudly instead of
// silently producing an APK without libil2cpp.so (which would crash with
// UnsatisfiedLinkError at runtime).
//
// NOTE: because the prebuilt binary is reused, any C# change must be re-exported from Unity.
// This guard lives here rather than in unityLibrary/build.gradle so that re-exporting from
// Unity (which regenerates that file) cannot erase it.
// ---------------------------------------------------------------------------
subprojects {
    if (name == "unityLibrary") {
        val unityDir = projectDir
        tasks.matching { it.name == "buildIl2Cpp" }.configureEach {
            onlyIf {
                val dataFolder =
                    java.io.File(unityDir, "src/main/Il2CppOutputProject/Source/il2cppOutput/data")
                val prebuiltLib =
                    java.io.File(unityDir, "src/main/jniLibs/arm64-v8a/libil2cpp.so")
                val canRebuild = dataFolder.isDirectory
                if (!canRebuild && prebuiltLib.isFile) {
                    logger.lifecycle(
                        "Skipping :unityLibrary:buildIl2Cpp - reusing the prebuilt libil2cpp.so from the Unity export."
                    )
                }
                canRebuild || !prebuiltLib.isFile
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
