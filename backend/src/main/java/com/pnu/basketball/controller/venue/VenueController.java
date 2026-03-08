package com.pnu.basketball.controller.venue;

import com.pnu.basketball.dto.response.ApiResponse;
import com.pnu.basketball.dto.response.VenueResponse;
import com.pnu.basketball.service.venue.VenueService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/venues")
@RequiredArgsConstructor
public class VenueController {

    private final VenueService venueService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<VenueResponse>>> getVenues() {
        List<VenueResponse> venues = venueService.getVenues();
        return ResponseEntity.ok(ApiResponse.success(venues, "경기장 목록 조회 성공"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<VenueResponse>> getVenue(@PathVariable UUID id) {
        VenueResponse venue = venueService.getVenue(id);
        return ResponseEntity.ok(ApiResponse.success(venue, "경기장 조회 성공"));
    }
}
