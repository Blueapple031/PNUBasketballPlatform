FROM --platform=$BUILDPLATFORM eclipse-temurin:17-jdk-jammy@sha256:29467857e8bde40ab1f7befecbda0ea764b95afec1cc7f89aa90f7a766577e19 AS build

WORKDIR /workspace

COPY backend/gradlew gradlew
COPY backend/gradle gradle
COPY backend/build.gradle backend/settings.gradle ./
RUN sed -i 's/\r$//' gradlew && \
    chmod +x gradlew && \
    ./gradlew --no-daemon dependencies

COPY backend/src src
RUN ./gradlew --no-daemon bootJar -x test && \
    jar_path="$(find build/libs -maxdepth 1 -type f -name '*.jar' ! -name '*-plain.jar' | head -1)" && \
    test -n "$jar_path" && \
    cp "$jar_path" /workspace/app.jar

FROM eclipse-temurin:17-jre-jammy@sha256:89e68b9bb83713510b63e2059a415792a7fc77e14b739a7d7ede97f6d9ca2c38 AS runtime

RUN apt-get update && \
    apt-get install --yes --no-install-recommends ca-certificates tini wget && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --system app && \
    useradd --system --gid app --home-dir /app app && \
    mkdir -p /app/db/migration

WORKDIR /app
COPY --from=build --chown=app:app /workspace/app.jar /app/app.jar
COPY --chown=app:app docs/database/schema.sql /app/db/migration/V1__baseline_schema.sql
COPY --chown=app:app docs/database/migrations/add_recruitment_posts.sql /app/db/migration/V2__add_recruitment_posts.sql
COPY --chown=app:app docs/database/migrations/add_matches_and_participations.sql /app/db/migration/V3__add_matches_and_participations.sql
COPY --chown=app:app docs/database/migrations/add_club_match_requests.sql /app/db/migration/V4__add_club_match_requests.sql

USER app
EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini", "--", "java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/app.jar"]
