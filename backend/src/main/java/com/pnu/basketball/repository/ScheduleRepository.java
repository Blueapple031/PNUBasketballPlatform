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

    long countByLocationId(UUID locationId);

    /**
     * 같은 장소, 같은 날짜에 시간이 겹치는 일정이 있는지 확인 (생성 시)
     */
    @Query("""
            SELECT COUNT(s) > 0 FROM Schedule s
            WHERE s.location.id = :locationId
            AND s.scheduleDate = :scheduleDate
            AND s.startTime < :endTime
            AND s.endTime > :startTime
            AND s.status != com.pnu.basketball.domain.ScheduleStatus.CANCELLED
            """)
    boolean existsOverlappingForCreate(
            @Param("locationId") UUID locationId,
            @Param("scheduleDate") LocalDate scheduleDate,
            @Param("startTime") LocalTime startTime,
            @Param("endTime") LocalTime endTime);

    /**
     * 같은 장소, 같은 날짜에 시간이 겹치는 일정이 있는지 확인 (수정 시, excludeId 제외)
     */
    @Query("""
            SELECT COUNT(s) > 0 FROM Schedule s
            WHERE s.location.id = :locationId
            AND s.scheduleDate = :scheduleDate
            AND s.startTime < :endTime
            AND s.endTime > :startTime
            AND s.status != com.pnu.basketball.domain.ScheduleStatus.CANCELLED
            AND s.id != :excludeId
            """)
    boolean existsOverlappingForUpdate(
            @Param("locationId") UUID locationId,
            @Param("scheduleDate") LocalDate scheduleDate,
            @Param("startTime") LocalTime startTime,
            @Param("endTime") LocalTime endTime,
            @Param("excludeId") UUID excludeId);
}
