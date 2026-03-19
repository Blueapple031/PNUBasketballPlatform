/**
 * 친선전 결과 관리
 */
function loadClubMatchAdmin() {
    var tbody = document.getElementById('clubmatch-tbody');
    tbody.innerHTML = '<tr><td colspan="8" class="empty-state"><p>데이터를 불러오는 중...</p></td></tr>';

    Admin.apiRequest('/club-matches/requests/admin/pending')
        .then(function (res) {
            var requests = res.data || res;
            if (!Array.isArray(requests)) requests = [];

            document.getElementById('clubmatch-pending-total').textContent = requests.length;

            if (requests.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8" class="empty-state"><p>승인 대기 중인 친선전이 없습니다.</p></td></tr>';
                return;
            }

            tbody.innerHTML = requests.map(function (r) {
                var startAt = formatDateTime(r.startAt);
                var statusBadge = clubMatchStatusBadge(r.status);

                return '<tr>'
                    + '<td><strong>' + escapeHtml(r.homeClubName || '-') + '</strong></td>'
                    + '<td>' + escapeHtml(r.awayClubName || '-') + '</td>'
                    + '<td>' + escapeHtml(r.locationName || '-') + '</td>'
                    + '<td>' + startAt + '</td>'
                    + '<td>' + (r.homeScore != null ? r.homeScore : '-') + '</td>'
                    + '<td>' + (r.awayScore != null ? r.awayScore : '-') + '</td>'
                    + '<td>' + statusBadge + '</td>'
                    + '<td><button class="btn-sm btn-confirm-clubmatch" data-id="' + r.id + '">확정</button></td>'
                    + '</tr>';
            }).join('');

            bindClubMatchAdminEvents();
        })
        .catch(function (err) {
            tbody.innerHTML = '<tr><td colspan="8" class="empty-state"><p>오류: ' + escapeHtml(err.message) + '</p></td></tr>';
        });
}

function bindClubMatchAdminEvents() {
    document.querySelectorAll('.btn-confirm-clubmatch').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = this.getAttribute('data-id');
            if (!confirm('이 친선전 결과를 최종 확정하시겠습니까?\n동아리 전적에 반영됩니다.')) return;

            Admin.apiRequest('/club-matches/requests/admin/' + id + '/confirm', { method: 'POST' })
                .then(function () {
                    alert('친선전 결과가 확정되었습니다.');
                    loadClubMatchAdmin();
                })
                .catch(function (err) {
                    alert('실패: ' + err.message);
                });
        });
    });
}

function clubMatchStatusBadge(status) {
    var cls = 'status-badge ';
    var label;
    switch (status) {
        case 'GATHERING': cls += 'status-pending'; label = '모집중'; break;
        case 'READY': cls += 'status-pending'; label = '준비완료'; break;
        case 'MATCHED': cls += 'status-active'; label = '매칭완료'; break;
        case 'CONFIRMED': cls += 'status-approved'; label = '확정'; break;
        case 'DONE': cls += 'status-approved'; label = '완료'; break;
        case 'CANCELLED': cls += 'status-rejected'; label = '취소'; break;
        default: cls += 'status-pending'; label = status || '-';
    }
    return '<span class="' + cls + '">' + label + '</span>';
}
