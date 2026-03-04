/**
 * 유저 관리 탭
 */
var UsersState = { page: 1, size: 20, isPnuStudent: null, search: '' };

function loadUsers() {
    var params = new URLSearchParams();
    params.set('page', UsersState.page);
    params.set('size', UsersState.size);
    if (UsersState.isPnuStudent !== null && UsersState.isPnuStudent !== '') {
        params.set('isPnuStudent', UsersState.isPnuStudent);
    }
    if (UsersState.search) params.set('search', UsersState.search);

    document.getElementById('users-tbody').innerHTML =
        '<tr><td colspan="9" class="empty-state"><p>로딩 중...</p></td></tr>';

    Admin.apiRequest('/admin/users?' + params.toString())
        .then(function (res) {
            if (!res.success || !res.data) return;
            var content = res.data.content || [];
            var total = res.data.totalElements || 0;
            document.getElementById('users-total').textContent = total;

            if (content.length === 0) {
                document.getElementById('users-tbody').innerHTML =
                    '<tr><td colspan="9" class="empty-state"><p>등록된 유저가 없습니다.</p></td></tr>';
                document.getElementById('users-pagination').innerHTML = '';
                return;
            }

            var html = content
                .map(function (u, i) {
                    var num = (UsersState.page - 1) * UsersState.size + i + 1;
                    var studentBadge = u.isPnuStudent
                        ? '<span class="status-badge status-approved">학생</span>'
                        : '<span class="status-badge status-pending">외부인</span>';
                    var dateStr = u.createdAt
                        ? new Date(u.createdAt).toLocaleDateString('ko-KR')
                        : '-';
                    return (
                        '<tr>' +
                        '<td>' +
                        num +
                        '</td>' +
                        '<td>' +
                        (u.email || '-') +
                        '</td>' +
                        '<td>' +
                        (u.realName || '-') +
                        '</td>' +
                        '<td>' +
                        studentBadge +
                        '</td>' +
                        '<td>' +
                        (u.department || '-') +
                        '</td>' +
                        '<td>' +
                        (u.studentId || '-') +
                        '</td>' +
                        '<td>' +
                        (u.clubName || '-') +
                        '</td>' +
                        '<td>' +
                        dateStr +
                        '</td>' +
                        '<td><button type="button" class="action-btn btn-view-user" data-id="' +
                        u.userId +
                        '">상세</button></td>' +
                        '</tr>'
                    );
                })
                .join('');
            document.getElementById('users-tbody').innerHTML = html;

            renderUsersPagination(res.data.totalPages, res.data.currentPage);
            bindUserEvents();
        })
        .catch(function (err) {
            document.getElementById('users-tbody').innerHTML =
                '<tr><td colspan="9" class="empty-state"><p>오류: ' + (err.message || '') + '</p></td></tr>';
            document.getElementById('users-pagination').innerHTML = '';
        });
}

function renderUsersPagination(totalPages, currentPage) {
    var container = document.getElementById('users-pagination');
    if (totalPages <= 1) {
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

    var nums = document.querySelector('#users-pagination .page-numbers');
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
            if (p === 'prev') UsersState.page = Math.max(1, UsersState.page - 1);
            else if (p === 'next') UsersState.page = Math.min(totalPages, UsersState.page + 1);
            else UsersState.page = parseInt(p, 10);
            loadUsers();
        });
    });
}

function bindUserEvents() {
    document.querySelectorAll('.btn-view-user').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = this.getAttribute('data-id');
            showUserDetail(id);
        });
    });
}

function showUserDetail(userId) {
    Admin.apiRequest('/admin/users/' + userId)
        .then(function (res) {
            if (!res.success || !res.data) return;
            var u = res.data;
            var html =
                '<p><strong>이메일:</strong> ' +
                (u.email || '-') +
                '</p>' +
                '<p><strong>본명:</strong> ' +
                (u.realName || '-') +
                '</p>' +
                '<p><strong>전화번호:</strong> ' +
                (u.phoneNumber || '-') +
                '</p>' +
                '<p><strong>생년월일:</strong> ' +
                (u.dateOfBirth || '-') +
                '</p>' +
                '<p><strong>학생:</strong> ' +
                (u.isPnuStudent ? '예' : '아니오') +
                '</p>' +
                '<p><strong>학과:</strong> ' +
                (u.department || '-') +
                '</p>' +
                '<p><strong>학번:</strong> ' +
                (u.studentId || '-') +
                '</p>' +
                '<p><strong>동아리:</strong> ' +
                (u.clubName || '-') +
                '</p>' +
                '<p><strong>승/경기/득점:</strong> ' +
                (u.wins || 0) +
                ' / ' +
                (u.games || 0) +
                ' / ' +
                (u.totalScore || 0) +
                '</p>' +
                '<p><strong>가입일:</strong> ' +
                (u.createdAt ? new Date(u.createdAt).toLocaleString('ko-KR') : '-') +
                '</p>';
            document.getElementById('modal-user-detail-body').innerHTML = html;
            document.getElementById('modal-user-detail').classList.add('show');
        })
        .catch(function (err) {
            alert(err.message || '유저 정보를 불러올 수 없습니다.');
        });
}

document.addEventListener('DOMContentLoaded', function () {
    var searchUsers = document.getElementById('btn-search-users');
    var resetUsers = document.getElementById('btn-reset-users');
    if (searchUsers) {
        searchUsers.addEventListener('click', function () {
            UsersState.isPnuStudent = document.getElementById('filter-student').value || null;
            if (UsersState.isPnuStudent === '') UsersState.isPnuStudent = null;
            else if (UsersState.isPnuStudent === 'true') UsersState.isPnuStudent = true;
            else if (UsersState.isPnuStudent === 'false') UsersState.isPnuStudent = false;
            UsersState.search = document.getElementById('search-users').value.trim();
            UsersState.page = 1;
            loadUsers();
        });
    }
    if (resetUsers) {
        resetUsers.addEventListener('click', function () {
            document.getElementById('filter-student').value = '';
            document.getElementById('search-users').value = '';
            UsersState = { page: 1, size: 20, isPnuStudent: null, search: '' };
            loadUsers();
        });
    }
});
