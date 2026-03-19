package com.pnu.basketball.dto.request;

import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.List;

@Getter
@NoArgsConstructor
public class ReviewSubmitRequest {

    private List<Long> thumbsUpUserIds;

    private List<Long> noShowUserIds;
}
