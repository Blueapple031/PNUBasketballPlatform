/**
 * 노쇼 신고 관리
 */
function loadNoShowReports() {
    var tbody = document.getElementById('noshow-tbody');
    tbody.innerHTML = '<tr><td colspan="6" class="empty-state"><p>데이터를 불러오는 중...</p></td></tr>';

    Admin.apiRequest('/matches/admin/no-show-reports')
        .then(function (res) {
            var reports = res.data || res;
            if (!Array.isArray(reports)) reports = [];

            document.getElementById('noshow-total').textContent = reports.length;

            if (reports.length === 0) {
                tbody.innerHTML = '<tr><td colspan="6" class="empty-state"><p>처리 대기 중인 노쇼 신고가 없습니다.</p></td></tr>';
                return;
            }

            tbody.innerHTML = reports.map(function (r) {
                var statusBadge = noShowStatusBadge(r.status);
                var createdAt = formatDateTime(r.createdAt);
                var matchIdShort = r.matchId ? String(r.matchId).substring(0, 8) + '...' : '-';

                var actions = '';
                if (r.status === 'PENDING') {
                    actions = '<button class="btn-sm btn-confirm-noshow" data-id="' + r.id + '">확정</button>'
                        + ' <button class="btn-sm btn-danger-sm btn-reject-noshow" data-id="' + r.id + '">반려</button>';
                } else {
                    actions = '<span style="color:#718096; font-size:12px;">처리 완료</span>';
                }

                return '<tr>'
                    + '<td title="' + (r.matchId || '') + '">' + matchIdShort + '</td>'
                    + '<td>' + escapeHtml(r.reporterNickname || '-') + '</td>'
                    + '<td>' + escapeHtml(r.reportedUserNickname || '-') + '</td>'
                    + '<td>' + statusBadge + '</td>'
                    + '<td>' + createdAt + '</td>'
                    + '<td>' + actions + '</td>'
                    + '</tr>';
            }).join('');

            bindNoShowEvents();
        })
        .catch(function (err) {
            tbody.innerHTML = '<tr><td colspan="6" class="empty-state"><p>오류: ' + escapeHtml(err.message) + '</p></td></tr>';
        });
}

function bindNoShowEvents() {
    document.querySelectorAll('.btn-confirm-noshow').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = this.getAttribute('data-id');
            if (!confirm('이 노쇼 신고를 확정하시겠습니까?\n해당 유저의 노쇼 횟수가 증가합니다.')) return;

            Admin.apiRequest('/matches/admin/no-show-reports/' + id + '/confirm', { method: 'POST' })
                .then(function () {
                    alert('노쇼가 확정되었습니다.');
                    loadNoShowReports();
                })
                .catch(function (err) {
                    alert('실패: ' + err.message);
                });
        });
    });

    document.querySelectorAll('.btn-reject-noshow').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = this.getAttribute('data-id');
            if (!confirm('이 노쇼 신고를 반려하시겠습니까?')) return;

            Admin.apiRequest('/matches/admin/no-show-reports/' + id + '/reject', { method: 'POST' })
                .then(function () {
                    alert('노쇼 신고가 반려되었습니다.');
                    loadNoShowReports();
                })
                .catch(function (err) {
                    alert('실패: ' + err.message);
                });
        });
    });
}

function noShowStatusBadge(status) {
    var cls = 'status-badge ';
    var label;
    switch (status) {
        case 'PENDING': cls += 'status-pending'; label = '대기'; break;
        case 'CONFIRMED': cls += 'status-rejected'; label = '확정'; break;
        case 'REJECTED': cls += 'status-approved'; label = '반려'; break;
        default: cls += 'status-pending'; label = status || '-';
    }
    return '<span class="' + cls + '">' + label + '</span>';
}
