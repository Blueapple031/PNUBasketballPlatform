/**
 * 일정 관리 탭
 */
var SchedulesState = { startDate: null, endDate: null, locationIds: [] };

function loadSchedules() {
    var startEl = document.getElementById('schedule-start-date');
    var endEl = document.getElementById('schedule-end-date');
    if (!startEl.value || !endEl.value) {
        var today = new Date();
        var nextWeek = new Date(today);
        nextWeek.setDate(nextWeek.getDate() + 13);
        startEl.value = today.toISOString().slice(0, 10);
        endEl.value = nextWeek.toISOString().slice(0, 10);
    }
    SchedulesState.startDate = startEl.value;
    SchedulesState.endDate = endEl.value;
    var ids = [];
    document.querySelectorAll('input[name="filter-location-id"]:checked').forEach(function (cb) {
        if (cb.value) ids.push(cb.value);
    });
    SchedulesState.locationIds = ids;

    if (typeof refreshLocationSelects === 'function' && typeof LocationsCache !== 'undefined' && LocationsCache.length > 0) {
        refreshLocationSelects();
    }
    if (typeof loadScheduleLocations === 'function' && (!LocationsCache || LocationsCache.length === 0)) {
        loadScheduleLocations().then(fetchSchedules).catch(function () { fetchSchedules(); });
        return;
    }
    fetchSchedules();
}

function fetchSchedules() {
    var params = new URLSearchParams();
    if (SchedulesState.startDate) params.set('startDate', SchedulesState.startDate);
    if (SchedulesState.endDate) params.set('endDate', SchedulesState.endDate);
    SchedulesState.locationIds.forEach(function (id) {
        params.append('locationIds', id);
    });

    document.getElementById('schedules-tbody').innerHTML =
        '<tr><td colspan="8" class="empty-state"><p>로딩 중...</p></td></tr>';

    Admin.apiRequest('/admin/schedules?' + params.toString())
        .then(function (res) {
            if (!res.success || !res.data) return;
            var content = res.data;
            if (!Array.isArray(content)) content = [];

            document.getElementById('schedules-total').textContent = content.length;

            if (content.length === 0) {
                document.getElementById('schedules-tbody').innerHTML =
                    '<tr><td colspan="8" class="empty-state"><p>해당 기간에 등록된 일정이 없습니다.</p></td></tr>';
                return;
            }

            var statusMap = { AVAILABLE: '비어있음', SCHEDULED: '사용중', CANCELLED: '취소' };
            var typeMap = { REGULAR: '일반', TRAINING: '훈련' };
            var html = content
                .map(function (s) {
                    var dateStr = s.scheduleDate || '-';
                    var startStr = s.startTime ? String(s.startTime).substring(0, 5) : '-';
                    var endStr = s.endTime ? String(s.endTime).substring(0, 5) : '-';
                    var statusClass = s.status === 'SCHEDULED' ? 'status-approved' : s.status === 'CANCELLED' ? 'status-rejected' : 'status-pending';
                    var statusText = statusMap[s.status] || s.status;
                    var typeText = typeMap[s.scheduleType] || (s.scheduleType || '일반');
                    var titleShort = (s.title || '').length > 20 ? (s.title || '').substring(0, 20) + '...' : (s.title || '-');
                    return (
                        '<tr>' +
                        '<td>' + (s.locationName || '-') + '</td>' +
                        '<td>' + typeText + '</td>' +
                        '<td>' + dateStr + '</td>' +
                        '<td>' + startStr + '</td>' +
                        '<td>' + endStr + '</td>' +
                        '<td><span class="status-badge ' + statusClass + '">' + statusText + '</span></td>' +
                        '<td>' + titleShort + '</td>' +
                        '<td>' +
                        '<button type="button" class="action-btn btn-edit-schedule" data-id="' + s.id + '">수정</button> ' +
                        '<button type="button" class="action-btn btn-delete-schedule" data-id="' + s.id + '" style="background:#e53e3e">삭제</button>' +
                        '</td>' +
                        '</tr>'
                    );
                })
                .join('');
            document.getElementById('schedules-tbody').innerHTML = html;
            bindScheduleEvents();
        })
        .catch(function (err) {
            document.getElementById('schedules-tbody').innerHTML =
                '<tr><td colspan="8" class="empty-state"><p>오류: ' + (err.message || '') + '</p></td></tr>';
        });
}

function bindScheduleEvents() {
    document.querySelectorAll('.btn-edit-schedule').forEach(function (btn) {
        btn.addEventListener('click', function () {
            openScheduleModal(this.getAttribute('data-id'));
        });
    });
    document.querySelectorAll('.btn-delete-schedule').forEach(function (btn) {
        btn.addEventListener('click', function () {
            deleteSchedule(this.getAttribute('data-id'));
        });
    });
}

function openScheduleModal(id) {
    document.getElementById('modal-schedule-title').textContent = id ? '일정 수정' : '일정 등록';
    document.getElementById('edit-schedule-id').value = id || '';
    var typeEl = document.getElementById('edit-schedule-type');
    var hintEl = document.getElementById('schedule-type-hint');
    typeEl.disabled = !!id;
    hintEl.style.display = typeEl.value === 'TRAINING' ? 'block' : 'none';

    if (typeof refreshLocationSelects === 'function') {
        refreshLocationSelects();
    }

    if (id) {
        Admin.apiRequest('/admin/schedules/' + id)
            .then(function (res) {
                if (res.success && res.data) {
                    var s = res.data;
                    document.getElementById('edit-schedule-location').value = s.locationId || '';
                    document.getElementById('edit-schedule-type').value = s.scheduleType || 'REGULAR';
                    document.getElementById('edit-schedule-date').value = s.scheduleDate || '';
                    document.getElementById('edit-schedule-start-time').value = s.startTime ? String(s.startTime).substring(0, 5) : '';
                    document.getElementById('edit-schedule-end-time').value = s.endTime ? String(s.endTime).substring(0, 5) : '';
                    document.getElementById('edit-schedule-status').value = s.status || 'SCHEDULED';
                    document.getElementById('edit-schedule-title').value = s.title || '';
                    document.getElementById('edit-schedule-description').value = s.description || '';
                }
                document.getElementById('modal-edit-schedule').classList.add('show');
            });
    } else {
        document.getElementById('edit-schedule-location').value = '';
        document.getElementById('edit-schedule-type').value = 'REGULAR';
        document.getElementById('edit-schedule-date').value = '';
        document.getElementById('edit-schedule-start-time').value = '09:00';
        document.getElementById('edit-schedule-end-time').value = '11:00';
        document.getElementById('edit-schedule-status').value = 'SCHEDULED';
        document.getElementById('edit-schedule-title').value = '';
        document.getElementById('edit-schedule-description').value = '';
        document.getElementById('modal-edit-schedule').classList.add('show');
    }
}

function submitSchedule() {
    var id = document.getElementById('edit-schedule-id').value;
    var locationId = document.getElementById('edit-schedule-location').value;
    var payload = {
        locationId: locationId,
        scheduleType: document.getElementById('edit-schedule-type').value || 'REGULAR',
        scheduleDate: document.getElementById('edit-schedule-date').value,
        startTime: document.getElementById('edit-schedule-start-time').value,
        endTime: document.getElementById('edit-schedule-end-time').value,
        status: document.getElementById('edit-schedule-status').value,
        title: document.getElementById('edit-schedule-title').value || null,
        description: document.getElementById('edit-schedule-description').value || null
    };

    if (!payload.locationId || !payload.scheduleDate || !payload.startTime || !payload.endTime) {
        alert('장소, 날짜, 시작/종료 시간은 필수입니다.');
        return;
    }

    var url = id ? '/admin/schedules/' + id : '/admin/schedules';
    var method = id ? 'PUT' : 'POST';

    Admin.apiRequest(url, {
        method: method,
        body: JSON.stringify(payload)
    })
        .then(function (res) {
            if (res.success) {
                document.getElementById('modal-edit-schedule').classList.remove('show');
                fetchSchedules();
                alert(res.message || '저장되었습니다.');
            } else {
                alert(res.message || '저장에 실패했습니다.');
            }
        })
        .catch(function (err) {
            var msg = err.message || '저장에 실패했습니다.';
            if (msg.indexOf('겹치') >= 0 || msg.indexOf('SCHEDULE_OVERLAP') >= 0) {
                alert('해당 장소의 같은 날짜·시간대에 이미 일정이 등록되어 있습니다. 다른 시간을 선택해 주세요.');
            } else {
                alert(msg);
            }
        });
}

function deleteSchedule(id) {
    if (!confirm('이 일정을 삭제하시겠습니까?')) return;

    Admin.apiRequest('/admin/schedules/' + id, { method: 'DELETE' })
        .then(function (res) {
            if (res.success) {
                fetchSchedules();
                alert('삭제되었습니다.');
            }
        })
        .catch(function (err) {
            alert(err.message || '삭제에 실패했습니다.');
        });
}

document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('edit-schedule-type').addEventListener('change', function () {
        var hintEl = document.getElementById('schedule-type-hint');
        hintEl.style.display = this.value === 'TRAINING' ? 'block' : 'none';
    });
    document.getElementById('btn-create-schedule').addEventListener('click', function () {
        openScheduleModal(null);
    });
    document.getElementById('btn-search-schedules').addEventListener('click', function () {
        loadSchedules();
    });
    document.getElementById('btn-submit-schedule').addEventListener('click', submitSchedule);
});
