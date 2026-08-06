plugins {
    java
    id("org.springframework.boot") version "4.1.0"
    id("io.spring.dependency-management") version "1.1.7"
}

group = "io.github"
version = "0.0.1-SNAPSHOT"
description = "you_master_backend"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(21)
    }
}

repositories {
    mavenCentral()
}

val productionMigrations = fileTree("src/main/resources/db/migration") {
    include("V*.sql")
}
val generatedJooqDirectory = layout.projectDirectory.dir("src/generated/jooq")

val jooqGenerator by sourceSets.creating

sourceSets.main {
    java.srcDir(generatedJooqDirectory)
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-flyway")
    implementation("org.springframework.boot:spring-boot-starter-jooq")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-oauth2-resource-server")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:3.0.3")

    runtimeOnly("org.flywaydb:flyway-database-postgresql")
    runtimeOnly("org.postgresql:postgresql")

    add(jooqGenerator.implementationConfigurationName, "org.jooq:jooq-codegen:3.21.5")
    add(jooqGenerator.implementationConfigurationName, "org.flywaydb:flyway-core")
    add(jooqGenerator.implementationConfigurationName, "org.flywaydb:flyway-database-postgresql")
    add(jooqGenerator.implementationConfigurationName, "org.postgresql:postgresql")
    add(jooqGenerator.implementationConfigurationName, "org.testcontainers:testcontainers-postgresql")

    compileOnly("org.projectlombok:lombok")
    annotationProcessor("org.projectlombok:lombok")

    testImplementation("org.springframework.boot:spring-boot-testcontainers")
    testImplementation("org.springframework.boot:spring-boot-starter-data-jpa-test")
    testImplementation("org.springframework.boot:spring-boot-starter-flyway-test")
    testImplementation("org.springframework.boot:spring-boot-starter-security-test")
    testImplementation("org.springframework.boot:spring-boot-starter-validation-test")
    testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
    testImplementation("org.testcontainers:testcontainers-junit-jupiter")
    testImplementation("org.testcontainers:testcontainers-postgresql")
    testCompileOnly("org.projectlombok:lombok")
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
    testAnnotationProcessor("org.projectlombok:lombok")
}

tasks.register<JavaExec>("jooqCodegen") {
    group = "jooq"
    description = "Generates jOOQ sources from Flyway migrations applied to a temporary PostgreSQL container."
    dependsOn(jooqGenerator.classesTaskName)

    classpath = jooqGenerator.runtimeClasspath
    mainClass = "io.github.vlad1slavs.okoshko.build.JooqCodegenRunner"
    args(
        layout.projectDirectory.dir("src/main/resources/db/migration").asFile.absolutePath,
        generatedJooqDirectory.asFile.absolutePath,
    )

    inputs.files(productionMigrations)
    inputs.files(jooqGenerator.allSource)
    outputs.dir(generatedJooqDirectory)
}

tasks.named("compileJava") {
    mustRunAfter(tasks.named("jooqCodegen"))
}

tasks.withType<Test> {
    useJUnitPlatform()
}
