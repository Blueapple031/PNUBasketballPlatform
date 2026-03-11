package com.pnu.basketball.repository;

import com.pnu.basketball.domain.ScheduleLocationEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ScheduleLocationRepository extends JpaRepository<ScheduleLocationEntity, UUID> {

    List<ScheduleLocationEntity> findAllByOrderBySortOrderAscNameAsc();

    Optional<ScheduleLocationEntity> findByName(String name);

    boolean existsByName(String name);

    boolean existsByNameAndIdNot(String name, UUID excludeId);
}
