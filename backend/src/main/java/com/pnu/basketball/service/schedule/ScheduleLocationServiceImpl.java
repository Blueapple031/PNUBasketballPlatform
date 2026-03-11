package com.pnu.basketball.service.schedule;

import com.pnu.basketball.domain.ScheduleLocationEntity;
import com.pnu.basketball.dto.request.ScheduleLocationCreateRequest;
import com.pnu.basketball.dto.request.ScheduleLocationUpdateRequest;
import com.pnu.basketball.dto.response.ScheduleLocationResponse;
import com.pnu.basketball.exception.CustomException;
import com.pnu.basketball.exception.ErrorCode;
import com.pnu.basketball.repository.ScheduleLocationRepository;
import com.pnu.basketball.repository.ScheduleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ScheduleLocationServiceImpl implements ScheduleLocationService {

    private final ScheduleLocationRepository locationRepository;
    private final ScheduleRepository scheduleRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ScheduleLocationResponse> getAllLocations() {
        return locationRepository.findAllByOrderBySortOrderAscNameAsc().stream()
                .map(ScheduleLocationResponse::from)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public ScheduleLocationResponse getLocation(UUID id) {
        ScheduleLocationEntity entity = locationRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_LOCATION_NOT_FOUND));
        return ScheduleLocationResponse.from(entity);
    }

    @Override
    @Transactional
    public ScheduleLocationResponse createLocation(ScheduleLocationCreateRequest request) {
        String name = request.getName().trim();
        if (locationRepository.existsByName(name)) {
            throw new CustomException(ErrorCode.SCHEDULE_LOCATION_NAME_EXISTS);
        }

        ScheduleLocationEntity entity = ScheduleLocationEntity.builder()
                .name(name)
                .sortOrder(request.getSortOrder() != null ? request.getSortOrder() : 0)
                .build();
        entity = locationRepository.save(entity);
        return ScheduleLocationResponse.from(entity);
    }

    @Override
    @Transactional
    public ScheduleLocationResponse updateLocation(UUID id, ScheduleLocationUpdateRequest request) {
        ScheduleLocationEntity entity = locationRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_LOCATION_NOT_FOUND));

        String name = request.getName().trim();
        if (locationRepository.existsByNameAndIdNot(name, id)) {
            throw new CustomException(ErrorCode.SCHEDULE_LOCATION_NAME_EXISTS);
        }

        entity.update(name, request.getSortOrder());
        return ScheduleLocationResponse.from(entity);
    }

    @Override
    @Transactional
    public void deleteLocation(UUID id) {
        ScheduleLocationEntity entity = locationRepository.findById(id)
                .orElseThrow(() -> new CustomException(ErrorCode.SCHEDULE_LOCATION_NOT_FOUND));

        if (scheduleRepository.countByLocationId(id) > 0) {
            throw new CustomException(ErrorCode.SCHEDULE_LOCATION_IN_USE);
        }

        locationRepository.delete(entity);
    }
}
