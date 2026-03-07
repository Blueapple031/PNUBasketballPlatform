/**
 * 대시보드 탭
 */
function loadDashboard() {
    Admin.apiRequest('/admin/stats')
        .then(function (res) {
            if (res.success && res.data) {
                document.getElementById('stat-users').textContent = res.data.userCount ?? '-';
                document.getElementById('stat-clubs').textContent = res.data.clubCount ?? '-';
                document.getElementById('stat-matches').textContent = res.data.matchCount ?? '-';
            }
        })
        .catch(function (err) {
            document.getElementById('stat-users').textContent = '-';
            document.getElementById('stat-clubs').textContent = '-';
            document.getElementById('stat-matches').textContent = '-';
            console.error(err);
        });
}
