/**
 * 매칭 장소 관리 탭
 */
var LocationsCache = [];

function loadScheduleLocations() {
    document.getElementById('locations-tbody').innerHTML =
        '<tr><td colspan="3" class="empty-state"><p>로딩 중...</p></td></tr>';

    return Admin.apiRequest('/admin/schedule-locations')
        .then(function (res) {
            if (!res.success || !res.data) return;
            var content = res.data;
            if (!Array.isArray(content)) content = [];

            LocationsCache = content;
            document.getElementById('locations-total').textContent = content.length;

            if (content.length === 0) {
                document.getElementById('locations-tbody').innerHTML =
                    '<tr><td colspan="3" class="empty-state"><p>등록된 장소가 없습니다. 장소를 추가해 주세요.</p></td></tr>';
                return;
            }

            var html = content
                .map(function (loc) {
                    return (
                        '<tr>' +
                        '<td>' + (loc.sortOrder != null ? loc.sortOrder : 0) + '</td>' +
                        '<td>' + (loc.name || '-') + '</td>' +
                        '<td>' +
                        '<button type="button" class="action-btn btn-edit-location" data-id="' + loc.id + '">수정</button> ' +
                        '<button type="button" class="action-btn btn-delete-location" data-id="' + loc.id + '" style="background:#e53e3e">삭제</button>' +
                        '</td>' +
                        '</tr>'
                    );
                })
                .join('');
            document.getElementById('locations-tbody').innerHTML = html;
            bindLocationEvents();
            refreshLocationSelects();
        })
        .catch(function (err) {
            document.getElementById('locations-total').textContent = '0';
            document.getElementById('locations-tbody').innerHTML =
                '<tr><td colspan="3" class="empty-state"><p>오류: ' + (err.message || '') + '</p></td></tr>';
        });
}

function bindLocationEvents() {
    document.querySelectorAll('.btn-edit-location').forEach(function (btn) {
        btn.addEventListener('click', function () {
            openLocationModal(this.getAttribute('data-id'));
        });
    });
    document.querySelectorAll('.btn-delete-location').forEach(function (btn) {
        btn.addEventListener('click', function () {
            deleteLocation(this.getAttribute('data-id'));
        });
    });
}

function refreshLocationSelects() {
    var opts = '<option value="">전체</option>';
    LocationsCache.forEach(function (loc) {
        opts += '<option value="' + loc.id + '">' + (loc.name || '') + '</option>';
    });
    var filterEl = document.getElementById('filter-schedule-location');
    if (filterEl) {
        var saved = filterEl.value;
        filterEl.innerHTML = opts;
        if (saved) filterEl.value = saved;
    }

    var editOpts = '<option value="">선택</option>';
    LocationsCache.forEach(function (loc) {
        editOpts += '<option value="' + loc.id + '">' + (loc.name || '') + '</option>';
    });
    var editEl = document.getElementById('edit-schedule-location');
    if (editEl) {
        var savedEdit = editEl.value;
        editEl.innerHTML = editOpts;
        if (savedEdit) editEl.value = savedEdit;
    }
}

function openLocationModal(id) {
    document.getElementById('modal-location-title').textContent = id ? '장소 수정' : '장소 추가';
    document.getElementById('edit-location-id').value = id || '';

    if (id) {
        var loc = LocationsCache.find(function (l) { return l.id === id; });
        if (loc) {
            document.getElementById('edit-location-name').value = loc.name || '';
            document.getElementById('edit-location-sort-order').value = loc.sortOrder != null ? loc.sortOrder : 0;
        }
        document.getElementById('modal-edit-location').classList.add('show');
    } else {
        document.getElementById('edit-location-name').value = '';
        document.getElementById('edit-location-sort-order').value = 0;
        document.getElementById('modal-edit-location').classList.add('show');
    }
}

function submitLocation() {
    var id = document.getElementById('edit-location-id').value;
    var payload = {
        name: document.getElementById('edit-location-name').value.trim(),
        sortOrder: parseInt(document.getElementById('edit-location-sort-order').value, 10) || 0
    };

    if (!payload.name) {
        alert('장소명은 필수입니다.');
        return;
    }

    var url = id ? '/admin/schedule-locations/' + id : '/admin/schedule-locations';
    var method = id ? 'PUT' : 'POST';

    Admin.apiRequest(url, {
        method: method,
        body: JSON.stringify(payload)
    })
        .then(function (res) {
            if (res.success) {
                document.getElementById('modal-edit-location').classList.remove('show');
                loadScheduleLocations();
                alert(res.message || '저장되었습니다.');
            }
        })
        .catch(function (err) {
            var msg = err.message || '저장에 실패했습니다.';
            if (msg.indexOf('이미 존재') >= 0) {
                alert('이미 존재하는 장소명입니다.');
            } else {
                alert(msg);
            }
        });
}

function deleteLocation(id) {
    if (!confirm('이 장소를 삭제하시겠습니까? 해당 장소에 등록된 일정이 있으면 삭제할 수 없습니다.')) return;

    Admin.apiRequest('/admin/schedule-locations/' + id, { method: 'DELETE' })
        .then(function (res) {
            if (res.success) {
                loadScheduleLocations();
                alert('삭제되었습니다.');
            }
        })
        .catch(function (err) {
            var msg = err.message || '삭제에 실패했습니다.';
            if (msg.indexOf('등록된 일정') >= 0) {
                alert('해당 장소에 등록된 일정이 있어 삭제할 수 없습니다.');
            } else {
                alert(msg);
            }
        });
}

document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('btn-create-location').addEventListener('click', function () {
        openLocationModal(null);
    });
    document.getElementById('btn-submit-location').addEventListener('click', submitLocation);
});
