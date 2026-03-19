/**
 * 모집글 관리
 */
const RecruitmentsState = {
    page: 0,
    size: 20,
    status: '',
    gameFormat: '',
};

function loadRecruitments() {
    const tbody = document.getElementById('recruitments-tbody');
    tbody.innerHTML = '<tr><td colspan="8" class="empty-state"><p>데이터를 불러오는 중...</p></td></tr>';

    const params = new URLSearchParams({
        page: RecruitmentsState.page,
        size: RecruitmentsState.size,
    });
    if (RecruitmentsState.status) params.append('status', RecruitmentsState.status);
    if (RecruitmentsState.gameFormat) params.append('gameFormat', RecruitmentsState.gameFormat);

    Admin.apiRequest(`/recruitments?${params.toString()}`)
        .then(function (res) {
            const data = res.data || res;
            const content = data.content || [];
            const totalElements = data.totalElements || 0;

            document.getElementById('recruitments-total').textContent = totalElements;

            if (content.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8" class="empty-state"><p>등록된 모집글이 없습니다.</p></td></tr>';
                document.getElementById('recruitments-pagination').innerHTML = '';
                return;
            }

            tbody.innerHTML = content.map(function (r) {
                const startAt = formatDateTime(r.startAt);
                const createdAt = formatDate(r.createdAt);
                const format = formatGameFormat(r.gameFormat);
                const statusBadge = recruitmentStatusBadge(r.status);
                const progress = (r.baseMembersCount || 0) + '+'
                    + (r.acceptedCount || 0) + '/'
                    + ((r.baseMembersCount || 0) + (r.neededMembers || 0));

                return '<tr>'
                    + '<td>' + escapeHtml(r.authorNickname || '-') + '</td>'
                    + '<td>' + escapeHtml(r.locationName || '-') + '</td>'
                    + '<td>' + startAt + '</td>'
                    + '<td>' + format + '</td>'
                    + '<td>' + progress + '</td>'
                    + '<td>' + statusBadge + '</td>'
                    + '<td>' + createdAt + '</td>'
                    + '<td><button class="btn-sm btn-view-recruitment" data-id="' + r.id + '">상세</button></td>'
                    + '</tr>';
            }).join('');

            renderRecruitmentsPagination(data);
            bindRecruitmentEvents();
        })
        .catch(function (err) {
            tbody.innerHTML = '<tr><td colspan="8" class="empty-state"><p>오류: ' + escapeHtml(err.message) + '</p></td></tr>';
        });
}

function renderRecruitmentsPagination(data) {
    const container = document.getElementById('recruitments-pagination');
    const totalPages = data.totalPages || 1;
    const current = data.number || 0;

    if (totalPages <= 1) {
        container.innerHTML = '';
        return;
    }

    let html = '';
    if (current > 0) {
        html += '<button class="page-btn" data-page="' + (current - 1) + '">이전</button>';
    }

    const start = Math.max(0, current - 2);
    const end = Math.min(totalPages, start + 5);
    for (let i = start; i < end; i++) {
        html += '<button class="page-btn' + (i === current ? ' active' : '') + '" data-page="' + i + '">' + (i + 1) + '</button>';
    }

    if (current < totalPages - 1) {
        html += '<button class="page-btn" data-page="' + (current + 1) + '">다음</button>';
    }

    container.innerHTML = html;
    container.querySelectorAll('.page-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
            RecruitmentsState.page = parseInt(this.getAttribute('data-page'));
            loadRecruitments();
        });
    });
}

function bindRecruitmentEvents() {
    document.querySelectorAll('.btn-view-recruitment').forEach(function (btn) {
        btn.addEventListener('click', function () {
            openRecruitmentDetail(this.getAttribute('data-id'));
        });
    });
}

function openRecruitmentDetail(id) {
    const body = document.getElementById('modal-recruitment-detail-body');
    body.innerHTML = '<p>로딩 중...</p>';
    document.getElementById('modal-recruitment-detail').classList.add('show');

    Admin.apiRequest('/recruitments/' + id)
        .then(function (res) {
            const r = res.data || res;
            const startAt = formatDateTime(r.startAt);
            const endAt = formatDateTime(r.endAt);
            const format = formatGameFormat(r.gameFormat);
            const statusBadge = recruitmentStatusBadge(r.status);
            const deadlineAt = r.deadlineAt ? formatDateTime(r.deadlineAt) : '-';
            const progress = (r.baseMembersCount || 0) + '+' + (r.acceptedCount || 0)
                + ' / ' + ((r.baseMembersCount || 0) + (r.neededMembers || 0)) + '명';

            let html = '<div class="detail-grid">'
                + '<div class="detail-row"><strong>상태</strong>' + statusBadge + '</div>'
                + '<div class="detail-row"><strong>작성자</strong>' + escapeHtml(r.authorNickname || '-') + '</div>'
                + '<div class="detail-row"><strong>장소</strong>' + escapeHtml(r.locationName || '-') + '</div>'
                + '<div class="detail-row"><strong>시간</strong>' + startAt + ' ~ ' + endAt + '</div>'
                + '<div class="detail-row"><strong>경기형태</strong>' + format + '</div>'
                + '<div class="detail-row"><strong>인원</strong>' + progress + '</div>'
                + '<div class="detail-row"><strong>마감시각</strong>' + deadlineAt + '</div>'
                + '</div>';

            var apps = r.applications || [];
            if (apps.length > 0) {
                html += '<h4 style="margin-top:20px; margin-bottom:10px;">신청 목록 (' + apps.length + ')</h4>';
                html += '<table class="member-table"><thead><tr>'
                    + '<th>닉네임</th><th>포지션</th><th>EXP</th><th>노쇼</th><th>상태</th><th>메시지</th>'
                    + '</tr></thead><tbody>';
                apps.forEach(function (a) {
                    var appStatus = applicationStatusBadge(a.status);
                    html += '<tr>'
                        + '<td>' + escapeHtml(a.applicantNickname || '-') + '</td>'
                        + '<td>' + formatPosition(a.applicantPosition) + '</td>'
                        + '<td>' + (a.applicantExp || 0) + '</td>'
                        + '<td>' + (a.applicantNoShowCount || 0) + '</td>'
                        + '<td>' + appStatus + '</td>'
                        + '<td>' + escapeHtml(a.message || '-') + '</td>'
                        + '</tr>';
                });
                html += '</tbody></table>';
            }

            body.innerHTML = html;
        })
        .catch(function (err) {
            body.innerHTML = '<p style="color: #991b1b;">오류: ' + escapeHtml(err.message) + '</p>';
        });
}

// 필터 & 이벤트 바인딩
document.addEventListener('DOMContentLoaded', function () {
    var btnSearch = document.getElementById('btn-search-recruitments');
    if (btnSearch) {
        btnSearch.addEventListener('click', function () {
            RecruitmentsState.status = document.getElementById('filter-recruitment-status').value;
            RecruitmentsState.gameFormat = document.getElementById('filter-recruitment-format').value;
            RecruitmentsState.page = 0;
            loadRecruitments();
        });
    }

    var btnReset = document.getElementById('btn-reset-recruitments');
    if (btnReset) {
        btnReset.addEventListener('click', function () {
            document.getElementById('filter-recruitment-status').value = '';
            document.getElementById('filter-recruitment-format').value = '';
            RecruitmentsState.status = '';
            RecruitmentsState.gameFormat = '';
            RecruitmentsState.page = 0;
            loadRecruitments();
        });
    }
});

// ── 유틸리티 함수 ──

function formatDateTime(isoStr) {
    if (!isoStr) return '-';
    var d = new Date(isoStr);
    return d.getFullYear() + '-'
        + String(d.getMonth() + 1).padStart(2, '0') + '-'
        + String(d.getDate()).padStart(2, '0') + ' '
        + String(d.getHours()).padStart(2, '0') + ':'
        + String(d.getMinutes()).padStart(2, '0');
}

function formatDate(isoStr) {
    if (!isoStr) return '-';
    var d = new Date(isoStr);
    return d.getFullYear() + '-'
        + String(d.getMonth() + 1).padStart(2, '0') + '-'
        + String(d.getDate()).padStart(2, '0');
}

function formatGameFormat(val) {
    switch (val) {
        case 'THREE_VS_THREE': return '3:3';
        case 'FOUR_VS_FOUR': return '4:4';
        case 'FIVE_VS_FIVE': return '5:5';
        case 'FLEXIBLE': return '자유';
        default: return val || '-';
    }
}

function formatPosition(val) {
    switch (val) {
        case 'GUARD': return '가드';
        case 'FORWARD': return '포워드';
        case 'CENTER': return '센터';
        default: return val || '-';
    }
}

function recruitmentStatusBadge(status) {
    var cls = 'status-badge ';
    var label;
    switch (status) {
        case 'OPEN': cls += 'status-approved'; label = '모집중'; break;
        case 'CONFIRMED': cls += 'status-active'; label = '확정'; break;
        case 'CLOSED': cls += 'status-pending'; label = '마감'; break;
        case 'CANCELLED': cls += 'status-rejected'; label = '취소'; break;
        default: cls += 'status-pending'; label = status || '-';
    }
    return '<span class="' + cls + '">' + label + '</span>';
}

function applicationStatusBadge(status) {
    var cls = 'status-badge ';
    var label;
    switch (status) {
        case 'PENDING': cls += 'status-pending'; label = '대기'; break;
        case 'ACCEPTED': cls += 'status-approved'; label = '수락'; break;
        case 'REJECTED': cls += 'status-rejected'; label = '거절'; break;
        default: cls += 'status-pending'; label = status || '-';
    }
    return '<span class="' + cls + '">' + label + '</span>';
}

function escapeHtml(str) {
    if (!str) return '';
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
}
