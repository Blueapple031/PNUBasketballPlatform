package com.pnu.basketball.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
@NoArgsConstructor
public class VoteRequest {

    @NotNull(message = "선택지를 선택해주세요.")
    private UUID optionId;
}
