package com.pnu.basketball.service.venue;

import com.pnu.basketball.dto.response.VenueResponse;

import java.util.List;
import java.util.UUID;

public interface VenueService {
    List<VenueResponse> getVenues();
    VenueResponse getVenue(UUID venueId);
}
