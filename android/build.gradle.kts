plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}

// --- 2. BARU RAKYATNYA (CONFIG LAIN) DI BAWAH ---
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Perbaikan di sini: Menambahkan fungsi file() agar tidak error String mismatch
rootProject.layout.buildDirectory.set(file("../build"))

subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.get()}/${project.name}"))
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}