/**
 * 매칭 관리 탭
 */
var MatchesState = { page: 1, size: 20, state: null };

var STATE_LABELS = {
    SCHEDULED: '예정',
    READY: '준비',
    ONGOING: '진행중',
    DONE: '종료',
    CANCELLED: '취소',
};

function loadMatches() {
    var params = new URLSearchParams();
    params.set('page', MatchesState.page);
    params.set('size', MatchesState.size);
    if (MatchesState.state) params.set('state', MatchesState.state);

    document.getElementById('matches-tbody').innerHTML =
        '<tr><td colspan="6" class="empty-state"><p>로딩 중...</p></td></tr>';

    Admin.apiRequest('/admin/matches?' + params.toString())
        .then(function (res) {
            if (!res.success || !res.data) return;
            var content = res.data.content || [];
            var total = res.data.totalElements || 0;
            document.getElementById('matches-total').textContent = total;

            if (content.length === 0) {
                document.getElementById('matches-tbody').innerHTML =
                    '<tr><td colspan="6" class="empty-state"><p>등록된 매치가 없습니다.</p></td></tr>';
                document.getElementById('matches-pagination').innerHTML = '';
                return;
            }

            var html = content
                .map(function (m) {
                    var dateStr = m.scheduledAt
                        ? new Date(m.scheduledAt).toLocaleString('ko-KR')
                        : '-';
                    var scoreStr =
                        m.homeScore != null && m.awayScore != null
                            ? m.homeScore + ' : ' + m.awayScore
                            : '-';
                    var stateLabel = STATE_LABELS[m.state] || m.state || '-';
                    return (
                        '<tr>' +
                        '<td>' +
                        (m.homeClubName || '-') +
                        '</td>' +
                        '<td>' +
                        (m.awayClubName || '-') +
                        '</td>' +
                        '<td>' +
                        dateStr +
                        '</td>' +
                        '<td><span class="status-badge status-approved">' +
                        stateLabel +
                        '</span></td>' +
                        '<td>' +
                        scoreStr +
                        '</td>' +
                        '<td><button type="button" class="action-btn btn-edit-match" data-id="' +
                        m.matchId +
                        '" data-state="' +
                        (m.state || '') +
                        '" data-home="' +
                        (m.homeScore ?? '') +
                        '" data-away="' +
                        (m.awayScore ?? '') +
                        '">수정</button></td>' +
                        '</tr>'
                    );
                })
                .join('');
            document.getElementById('matches-tbody').innerHTML = html;

            renderMatchesPagination(res.data.totalPages, res.data.currentPage);
            bindMatchEvents();
        })
        .catch(function (err) {
            document.getElementById('matches-tbody').innerHTML =
                '<tr><td colspan="6" class="empty-state"><p>오류: ' + (err.message || '') + '</p></td></tr>';
            document.getElementById('matches-pagination').innerHTML = '';
        });
}

function renderMatchesPagination(totalPages, currentPage) {
    var container = document.getElementById('matches-pagination');
    if (!totalPages || totalPages <= 1) {
        container.innerHTML = '';
        return;
    }
    var html =
        '<button type="button" class="page-btn" data-page="prev" ' +
        (currentPage <= 1 ? 'disabled' : '') +
        '>이전</button>' +
        '<div class="page-numbers"></div>' +
        '<button type="button" class="page-btn" data-page="next" ' +
        (currentPage >= totalPages ? 'disabled' : '') +
        '>다음</button>';
    container.innerHTML = html;

    var nums = container.querySelector('.page-numbers');
    for (var i = 1; i <= Math.min(totalPages, 5); i++) {
        var btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'page-number' + (i === currentPage ? ' active' : '');
        btn.textContent = i;
        btn.setAttribute('data-page', i);
        nums.appendChild(btn);
    }

    container.querySelectorAll('.page-btn, .page-number').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var p = this.getAttribute('data-page');
            if (p === 'prev') MatchesState.page = Math.max(1, MatchesState.page - 1);
            else if (p === 'next') MatchesState.page = Math.min(totalPages, MatchesState.page + 1);
            else MatchesState.page = parseInt(p, 10);
            loadMatches();
        });
    });
}

function bindMatchEvents() {
    document.querySelectorAll('.btn-edit-match').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = this.getAttribute('data-id');
            var state = this.getAttribute('data-state');
            var home = this.getAttribute('data-home');
            var away = this.getAttribute('data-away');
            document.getElementById('edit-match-id').value = id;
            document.getElementById('edit-match-state').value = state || 'SCHEDULED';
            document.getElementById('edit-home-score').value = home || '';
            document.getElementById('edit-away-score').value = away || '';
            document.getElementById('modal-edit-match').classList.add('show');
        });
    });
}

document.addEventListener('DOMContentLoaded', function () {
    var btnSearch = document.getElementById('btn-search-matches');
    var btnReset = document.getElementById('btn-reset-matches');
    var btnSubmit = document.getElementById('btn-submit-edit-match');

    if (btnSearch) {
        btnSearch.addEventListener('click', function () {
            var val = document.getElementById('filter-match-state').value;
            MatchesState.state = val || null;
            MatchesState.page = 1;
            loadMatches();
        });
    }
    if (btnReset) {
        btnReset.addEventListener('click', function () {
            document.getElementById('filter-match-state').value = '';
            MatchesState = { page: 1, size: 20, state: null };
            loadMatches();
        });
    }
    if (btnSubmit) {
        btnSubmit.addEventListener('click', function () {
            var matchId = document.getElementById('edit-match-id').value;
            var state = document.getElementById('edit-match-state').value;
            var homeStr = document.getElementById('edit-home-score').value.trim();
            var awayStr = document.getElementById('edit-away-score').value.trim();
            var body = { state: state };
            if (homeStr !== '') body.homeScore = parseInt(homeStr, 10);
            if (awayStr !== '') body.awayScore = parseInt(awayStr, 10);

            Admin.apiRequest('/admin/matches/' + matchId, {
                method: 'PUT',
                body: JSON.stringify(body),
            })
                .then(function (res) {
                    if (res.success) {
                        document.getElementById('modal-edit-match').classList.remove('show');
                        loadMatches();
                        alert('매치가 수정되었습니다.');
                    }
                })
                .catch(function (err) {
                    alert(err.message || '매치 수정에 실패했습니다.');
                });
        });
    }
});
