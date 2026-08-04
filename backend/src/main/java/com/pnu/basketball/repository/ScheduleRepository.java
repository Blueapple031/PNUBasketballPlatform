package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Schedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

public interface ScheduleRepository extends JpaRepository<Schedule, UUID> {

    List<Schedule> findByLocationIdAndScheduleDateOrderByStartTimeAsc(UUID locationId, LocalDate scheduleDate);

    List<Schedule> findByScheduleDateOrderByLocation_NameAscStartTimeAsc(LocalDate scheduleDate);

    List<Schedule> findByScheduleDateBetweenOrderByScheduleDateAscLocation_NameAscStartTimeAsc(
            LocalDate startDate, LocalDate endDate);

    List<Schedule> findByLocationIdAndScheduleDateBetweenOrderByScheduleDateAscStartTimeAsc(
            UUID locationId, LocalDate startDate, LocalDate endDate);

    List<Schedule> findByLocationIdInAndScheduleDateBetweenOrderByScheduleDateAscStartTimeAsc(
            List<UUID> locationIds, LocalDate startDate, LocalDate endDate);

    List<Schedule> findByRecurringTrueAndScheduleDateLessThanEqual(LocalDate endDate);

    List<Schedule> findByRecurringTrueAndLocationIdInAndScheduleDateLessThanEqual(
            List<UUID> locationIds, LocalDate endDate);

    long countByLocationId(UUID locationId);

    /**
     * 같은 장소, 같은 날짜에 시간이 겹치는 일정이 있는지 확인 (생성 시)
     */
    @Query(value = """
            SELECT EXISTS (
                SELECT 1 FROM schedules s
                WHERE s.location_id = :locationId
                  AND s.start_time < :endTime
                  AND s.end_time > :startTime
                  AND s.status <> 'CANCELLED'
                  AND (
                    (s.is_recurring = FALSE AND s.schedule_date = :scheduleDate)
                    OR
                    (s.is_recurring = TRUE
                     AND s.schedule_date <= :scheduleDate
                     AND MOD((CAST(:scheduleDate AS date) - s.schedule_date), 7) = 0)
                  )
            )
            """, nativeQuery = true)
    boolean existsOverlappingForCreate(
            @Param("locationId") UUID locationId,
            @Param("scheduleDate") LocalDate scheduleDate,
            @Param("startTime") LocalTime startTime,
            @Param("endTime") LocalTime endTime);

    /**
     * 같은 장소, 같은 날짜에 시간이 겹치는 일정이 있는지 확인 (수정 시, excludeId 제외)
     */
    @Query(value = """
            SELECT EXISTS (
                SELECT 1 FROM schedules s
                WHERE s.location_id = :locationId
                  AND s.start_time < :endTime
                  AND s.end_time > :startTime
                  AND s.status <> 'CANCELLED'
                  AND s.id <> :excludeId
                  AND (
                    (s.is_recurring = FALSE AND s.schedule_date = :scheduleDate)
                    OR
                    (s.is_recurring = TRUE
                     AND s.schedule_date <= :scheduleDate
                     AND MOD((CAST(:scheduleDate AS date) - s.schedule_date), 7) = 0)
                  )
            )
            """, nativeQuery = true)
    boolean existsOverlappingForUpdate(
            @Param("locationId") UUID locationId,
            @Param("scheduleDate") LocalDate scheduleDate,
            @Param("startTime") LocalTime startTime,
            @Param("endTime") LocalTime endTime,
            @Param("excludeId") UUID excludeId);

    @Query(value = """
            SELECT EXISTS (
                SELECT 1 FROM schedules s
                WHERE s.location_id = :locationId
                  AND s.start_time < :endTime
                  AND s.end_time > :startTime
                  AND s.status <> 'CANCELLED'
                  AND (:excludeId IS NULL OR s.id <> :excludeId)
                  AND EXTRACT(ISODOW FROM s.schedule_date) = EXTRACT(ISODOW FROM CAST(:scheduleDate AS date))
                  AND (s.is_recurring = TRUE OR s.schedule_date >= :scheduleDate)
            )
            """, nativeQuery = true)
    boolean existsOverlappingForWeeklyRecurrence(
            @Param("locationId") UUID locationId,
            @Param("scheduleDate") LocalDate scheduleDate,
            @Param("startTime") LocalTime startTime,
            @Param("endTime") LocalTime endTime,
            @Param("excludeId") UUID excludeId);
}
