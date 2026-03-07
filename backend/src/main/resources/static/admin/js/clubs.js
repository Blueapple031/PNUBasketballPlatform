/**
 * 동아리 관리 탭
 */
var CaptainModalState = { clubId: null, clubName: '' };

function loadClubs() {
    document.getElementById('clubs-tbody').innerHTML =
        '<tr><td colspan="4" class="empty-state"><p>로딩 중...</p></td></tr>';

    Admin.apiRequest('/admin/clubs?page=1&size=100')
        .then(function (res) {
            if (!res.success || !res.data) return;
            var content = res.data.content || [];

            if (content.length === 0) {
                document.getElementById('clubs-tbody').innerHTML =
                    '<tr><td colspan="4" class="empty-state"><p>등록된 동아리가 없습니다.</p></td></tr>';
                return;
            }

            var html = content
                .map(function (c) {
                    return (
                        '<tr>' +
                        '<td>' +
                        (c.name || '-') +
                        '</td>' +
                        '<td>' +
                        (c.captainName || '-') +
                        '</td>' +
                        '<td>' +
                        (c.memberCount || 0) +
                        '</td>' +
                        '<td>' +
                        '<button type="button" class="action-btn btn-set-captain" data-id="' +
                        c.clubId +
                        '" data-name="' +
                        (c.name || '') +
                        '">동아리장 설정</button>' +
                        '</td>' +
                        '</tr>'
                    );
                })
                .join('');
            document.getElementById('clubs-tbody').innerHTML = html;
            bindClubEvents();
        })
        .catch(function (err) {
            document.getElementById('clubs-tbody').innerHTML =
                '<tr><td colspan="4" class="empty-state"><p>오류: ' + (err.message || '') + '</p></td></tr>';
        });
}

function bindClubEvents() {
    document.querySelectorAll('.btn-set-captain').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = this.getAttribute('data-id');
            var name = this.getAttribute('data-name') || '';
            openSetCaptainModal(id, name);
        });
    });
}

function openSetCaptainModal(clubId, clubName) {
    CaptainModalState.clubId = clubId;
    CaptainModalState.clubName = clubName;
    document.getElementById('captain-club-name').textContent = '동아리: ' + clubName;

    Admin.apiRequest('/admin/clubs/' + clubId + '/members')
        .then(function (res) {
            if (!res.success || !res.data) return;
            var members = res.data || [];
            var select = document.getElementById('captain-user-select');
            select.innerHTML =
                '<option value="">선택하세요</option>' +
                members
                    .map(function (m) {
                        return (
                            '<option value="' +
                            m.userId +
                            '">' +
                            (m.realName || m.email) +
                            ' (' +
                            m.email +
                            ')</option>'
                        );
                    })
                    .join('');
            document.getElementById('modal-set-captain').classList.add('show');
        })
        .catch(function (err) {
            alert(err.message || '멤버 목록을 불러올 수 없습니다.');
        });
}

document.addEventListener('DOMContentLoaded', function () {
    var btnCreate = document.getElementById('btn-create-club');
    var btnSubmitCreate = document.getElementById('btn-submit-create-club');
    var btnSubmitCaptain = document.getElementById('btn-submit-captain');

    if (btnCreate) {
        btnCreate.addEventListener('click', function () {
            document.getElementById('club-name').value = '';
            document.getElementById('club-logo').value = '';
            document.getElementById('club-introduction').value = '';
            document.getElementById('modal-create-club').classList.add('show');
        });
    }

    if (btnSubmitCreate) {
        btnSubmitCreate.addEventListener('click', function () {
            var name = document.getElementById('club-name').value.trim();
            var logoUrl = document.getElementById('club-logo').value.trim();
            var introduction = document.getElementById('club-introduction').value.trim();
            if (!name) {
                alert('동아리명을 입력하세요.');
                return;
            }
            Admin.apiRequest('/admin/clubs', {
                method: 'POST',
                body: JSON.stringify({
                    name: name,
                    logoUrl: logoUrl || null,
                    introduction: introduction || null
                }),
            })
                .then(function (res) {
                    if (res.success) {
                        document.getElementById('modal-create-club').classList.remove('show');
                        loadClubs();
                        alert('동아리가 생성되었습니다.');
                    }
                })
                .catch(function (err) {
                    alert(err.message || '동아리 생성에 실패했습니다.');
                });
        });
    }

    if (btnSubmitCaptain) {
        btnSubmitCaptain.addEventListener('click', function () {
            var userId = document.getElementById('captain-user-select').value;
            if (!userId) {
                alert('동아리장을 선택하세요.');
                return;
            }
            if (!CaptainModalState.clubId) return;
            Admin.apiRequest('/admin/clubs/' + CaptainModalState.clubId + '/captain', {
                method: 'PUT',
                body: JSON.stringify({ userId: parseInt(userId, 10) }),
            })
                .then(function (res) {
                    if (res.success) {
                        document.getElementById('modal-set-captain').classList.remove('show');
                        loadClubs();
                        alert('동아리장이 설정되었습니다.');
                    }
                })
                .catch(function (err) {
                    alert(err.message || '동아리장 설정에 실패했습니다.');
                });
        });
    }
});
