/**
 * 게시글 관리 탭
 */
var PostsState = { page: 1, size: 20, currentPostId: null };

function loadPosts() {
    var params = new URLSearchParams();
    params.set('page', PostsState.page);
    params.set('size', PostsState.size);

    document.getElementById('posts-tbody').innerHTML =
        '<tr><td colspan="7" class="empty-state"><p>로딩 중...</p></td></tr>';

    Admin.apiRequest('/admin/posts?' + params.toString())
        .then(function (res) {
            if (!res.success || !res.data) return;
            var content = res.data.content || [];
            var total = res.data.totalElements || 0;
            document.getElementById('posts-total').textContent = total;

            if (content.length === 0) {
                document.getElementById('posts-tbody').innerHTML =
                    '<tr><td colspan="7" class="empty-state"><p>등록된 게시글이 없습니다.</p></td></tr>';
                document.getElementById('posts-pagination').innerHTML = '';
                return;
            }

            var html = content
                .map(function (p) {
                    var pinnedBadge = p.isPinned
                        ? '<span class="status-badge status-approved">공지</span>'
                        : '-';
                    var dateStr = p.createdAt
                        ? new Date(p.createdAt).toLocaleString('ko-KR')
                        : '-';
                    var titleShort = (p.title || '').length > 30
                        ? (p.title || '').substring(0, 30) + '...'
                        : (p.title || '-');
                    return (
                        '<tr>' +
                        '<td>' +
                        pinnedBadge +
                        '</td>' +
                        '<td><a href="#" class="post-title-link" data-id="' +
                        p.id +
                        '">' +
                        titleShort +
                        '</a></td>' +
                        '<td>' +
                        (p.authorName || '-') +
                        '</td>' +
                        '<td>' +
                        (p.viewCount || 0) +
                        '</td>' +
                        '<td>' +
                        (p.commentCount || 0) +
                        '</td>' +
                        '<td>' +
                        dateStr +
                        '</td>' +
                        '<td>' +
                        '<button type="button" class="action-btn btn-view-post" data-id="' +
                        p.id +
                        '">상세</button> ' +
                        '<button type="button" class="action-btn btn-pin-post-list" data-id="' +
                        p.id +
                        '" data-pinned="' +
                        !!p.isPinned +
                        '">' +
                        (p.isPinned ? '고정해제' : '공지') +
                        '</button> ' +
                        '<button type="button" class="action-btn btn-delete-post-list" data-id="' +
                        p.id +
                        '" style="background:#e53e3e">삭제</button>' +
                        '</td>' +
                        '</tr>'
                    );
                })
                .join('');
            document.getElementById('posts-tbody').innerHTML = html;

            renderPostsPagination(res.data.totalPages, res.data.currentPage);
            bindPostEvents();
        })
        .catch(function (err) {
            document.getElementById('posts-tbody').innerHTML =
                '<tr><td colspan="7" class="empty-state"><p>오류: ' + (err.message || '') + '</p></td></tr>';
            document.getElementById('posts-pagination').innerHTML = '';
        });
}

function renderPostsPagination(totalPages, currentPage) {
    var container = document.getElementById('posts-pagination');
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
            if (p === 'prev') PostsState.page = Math.max(1, PostsState.page - 1);
            else if (p === 'next') PostsState.page = Math.min(totalPages, PostsState.page + 1);
            else PostsState.page = parseInt(p, 10);
            loadPosts();
        });
    });
}

function bindPostEvents() {
    document.querySelectorAll('.btn-view-post, .post-title-link').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            var id = this.getAttribute('data-id');
            showPostDetail(id);
        });
    });
    document.querySelectorAll('.btn-pin-post-list').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = this.getAttribute('data-id');
            var isPinned = this.getAttribute('data-pinned') === 'true';
            togglePinPost(id, !isPinned);
        });
    });
    document.querySelectorAll('.btn-delete-post-list').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var id = this.getAttribute('data-id');
            deletePostConfirm(id);
        });
    });
}

function showPostDetail(postId) {
    PostsState.currentPostId = postId;
    document.getElementById('modal-post-detail-body').innerHTML = '<p>로딩 중...</p>';
    document.getElementById('modal-post-detail').classList.add('show');

    Admin.apiRequest('/admin/posts/' + postId)
        .then(function (res) {
            if (!res.success || !res.data) return;
            var p = res.data;
            var dateStr = p.createdAt
                ? new Date(p.createdAt).toLocaleString('ko-KR')
                : '-';

            var commentsHtml = (p.comments || [])
                .map(function (c) {
                    var cDate = c.createdAt
                        ? new Date(c.createdAt).toLocaleString('ko-KR')
                        : '-';
                    return (
                        '<div class="comment-item" style="padding:12px;margin:8px 0;background:#f7fafc;border-radius:8px;">' +
                        '<div style="font-weight:600;margin-bottom:4px;">' +
                        (c.authorName || '-') +
                        ' <span style="font-size:12px;color:#718096;">' +
                        cDate +
                        '</span></div>' +
                        '<div>' +
                        (c.content || '') +
                        '</div>' +
                        '<button type="button" class="action-btn btn-delete-comment" data-id="' +
                        c.id +
                        '" style="margin-top:8px;background:#e53e3e;font-size:12px">댓글 삭제</button>' +
                        '</div>'
                    );
                })
                .join('');

            var html =
                '<div class="post-detail">' +
                (p.isPinned
                    ? '<span class="status-badge status-approved" style="margin-bottom:8px">공지</span>'
                    : '') +
                '<h3 style="margin-bottom:12px;">' +
                (p.title || '-') +
                '</h3>' +
                '<p style="color:#718096;font-size:14px;margin-bottom:16px;">' +
                (p.authorName || '-') +
                ' · ' +
                dateStr +
                ' · 조회 ' +
                (p.viewCount || 0) +
                '</p>' +
                '<div style="white-space:pre-wrap;margin-bottom:24px;line-height:1.6;">' +
                (p.content || '') +
                '</div>' +
                '<hr style="margin:20px 0;">' +
                '<h4 style="margin-bottom:12px;">댓글 ' +
                (p.comments ? p.comments.length : 0) +
                '</h4>' +
                '<button type="button" class="action-btn" id="btn-add-comment-in-detail" style="margin-bottom:12px">+ 댓글 작성</button>' +
                '<div id="post-detail-comments">' +
                (commentsHtml || '<p style="color:#a0aec0">댓글이 없습니다.</p>') +
                '</div>' +
                '</div>';

            document.getElementById('modal-post-detail-body').innerHTML = html;

            document.getElementById('btn-add-comment-in-detail').addEventListener('click', function () {
                document.getElementById('modal-post-detail').classList.remove('show');
                openAddCommentModal(postId);
            });

            document.querySelectorAll('.btn-delete-comment').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    var cId = this.getAttribute('data-id');
                    deleteCommentConfirm(cId, postId);
                });
            });
        })
        .catch(function (err) {
            document.getElementById('modal-post-detail-body').innerHTML =
                '<p style="color:#e53e3e">오류: ' + (err.message || '') + '</p>';
        });
}

function openCreatePostModal() {
    document.getElementById('modal-post-title').textContent = '공지 작성';
    document.getElementById('edit-post-id').value = '';
    document.getElementById('edit-post-title').value = '';
    document.getElementById('edit-post-content').value = '';
    document.getElementById('edit-post-pin-wrap').style.display = 'none';
    document.getElementById('edit-post-pinned').checked = true;
    document.getElementById('modal-edit-post').classList.add('show');
}

function openEditPostModal(postId, title, content, isPinned) {
    document.getElementById('modal-post-title').textContent = '게시글 수정';
    document.getElementById('edit-post-id').value = postId || '';
    document.getElementById('edit-post-title').value = title || '';
    document.getElementById('edit-post-content').value = content || '';
    document.getElementById('edit-post-pin-wrap').style.display = 'block';
    document.getElementById('edit-post-pinned').checked = !!isPinned;
    document.getElementById('modal-edit-post').classList.add('show');
}

function openAddCommentModal(postId) {
    document.getElementById('comment-post-id').value = postId || '';
    document.getElementById('comment-content').value = '';
    document.getElementById('modal-add-comment').classList.add('show');
}

function togglePinPost(postId, isPinned) {
    Admin.apiRequest('/admin/posts/' + postId + '/pin', {
        method: 'PATCH',
        body: JSON.stringify({ isPinned: isPinned }),
    })
        .then(function (res) {
            if (res.success) {
                loadPosts();
                alert(isPinned ? '상단 고정되었습니다.' : '고정이 해제되었습니다.');
            }
        })
        .catch(function (err) {
            alert(err.message || '처리 실패');
        });
}

function deletePostConfirm(postId) {
    if (!confirm('정말 이 게시글을 삭제하시겠습니까?')) return;
    Admin.apiRequest('/admin/posts/' + postId, { method: 'DELETE' })
        .then(function (res) {
            if (res.success) {
                loadPosts();
                document.getElementById('modal-post-detail').classList.remove('show');
                alert('게시글이 삭제되었습니다.');
            }
        })
        .catch(function (err) {
            alert(err.message || '삭제 실패');
        });
}

function deleteCommentConfirm(commentId, postId) {
    if (!confirm('정말 이 댓글을 삭제하시겠습니까?')) return;
    Admin.apiRequest('/admin/comments/' + commentId, { method: 'DELETE' })
        .then(function (res) {
            if (res.success) {
                showPostDetail(postId);
                alert('댓글이 삭제되었습니다.');
            }
        })
        .catch(function (err) {
            alert(err.message || '삭제 실패');
        });
}

document.addEventListener('DOMContentLoaded', function () {
    var btnCreate = document.getElementById('btn-create-post');
    var btnSubmit = document.getElementById('btn-submit-post');
    var btnEditFromDetail = document.getElementById('btn-edit-post-from-detail');
    var btnPinPost = document.getElementById('btn-pin-post');
    var btnDeletePost = document.getElementById('btn-delete-post');
    var btnSubmitComment = document.getElementById('btn-submit-comment');

    if (btnCreate) {
        btnCreate.addEventListener('click', openCreatePostModal);
    }

    if (btnSubmit) {
        btnSubmit.addEventListener('click', function () {
            var postId = document.getElementById('edit-post-id').value.trim();
            var title = document.getElementById('edit-post-title').value.trim();
            var content = document.getElementById('edit-post-content').value.trim();
            var isPinned = document.getElementById('edit-post-pinned').checked;

            if (!title || !content) {
                alert('제목과 내용을 입력하세요.');
                return;
            }

            if (postId) {
                Admin.apiRequest('/admin/posts/' + postId, {
                    method: 'PUT',
                    body: JSON.stringify({ title: title, content: content }),
                })
                    .then(function (res) {
                        if (res.success) {
                            document.getElementById('modal-edit-post').classList.remove('show');
                            loadPosts();
                            if (PostsState.currentPostId === postId) {
                                showPostDetail(postId);
                            }
                            alert('게시글이 수정되었습니다.');
                        }
                    })
                    .catch(function (err) {
                        alert(err.message || '수정 실패');
                    });
            } else {
                Admin.apiRequest('/admin/posts', {
                    method: 'POST',
                    body: JSON.stringify({ title: title, content: content }),
                })
                    .then(function (res) {
                        if (res.success && res.data) {
                            var createdId = res.data.id;
                            document.getElementById('modal-edit-post').classList.remove('show');
                            if (isPinned && createdId) {
                                Admin.apiRequest('/admin/posts/' + createdId + '/pin', {
                                    method: 'PATCH',
                                    body: JSON.stringify({ isPinned: true }),
                                }).then(function () {
                                    loadPosts();
                                    alert('공지가 작성되었습니다.');
                                });
                            } else {
                                loadPosts();
                                alert('게시글이 작성되었습니다.');
                            }
                        }
                    })
                    .catch(function (err) {
                        alert(err.message || '작성 실패');
                    });
            }
        });
    }

    if (btnEditFromDetail) {
        btnEditFromDetail.addEventListener('click', function () {
            if (!PostsState.currentPostId) return;
            Admin.apiRequest('/admin/posts/' + PostsState.currentPostId).then(function (res) {
                if (res.success && res.data) {
                    document.getElementById('modal-post-detail').classList.remove('show');
                    openEditPostModal(
                        res.data.id,
                        res.data.title,
                        res.data.content,
                        res.data.isPinned
                    );
                }
            });
        });
    }

    if (btnPinPost) {
        btnPinPost.addEventListener('click', function () {
            if (!PostsState.currentPostId) return;
            Admin.apiRequest('/admin/posts/' + PostsState.currentPostId).then(function (res) {
                if (res.success && res.data) {
                    var isPinned = !res.data.isPinned;
                    togglePinPost(PostsState.currentPostId, isPinned);
                    document.getElementById('modal-post-detail').classList.remove('show');
                }
            });
        });
    }

    if (btnDeletePost) {
        btnDeletePost.addEventListener('click', function () {
            if (!PostsState.currentPostId) return;
            deletePostConfirm(PostsState.currentPostId);
        });
    }

    if (btnSubmitComment) {
        btnSubmitComment.addEventListener('click', function () {
            var postId = document.getElementById('comment-post-id').value;
            var content = document.getElementById('comment-content').value.trim();
            if (!postId || !content) {
                alert('댓글 내용을 입력하세요.');
                return;
            }
            Admin.apiRequest('/admin/posts/' + postId + '/comments', {
                method: 'POST',
                body: JSON.stringify({ content: content }),
            })
                .then(function (res) {
                    if (res.success) {
                        document.getElementById('modal-add-comment').classList.remove('show');
                        if (PostsState.currentPostId === postId) {
                            showPostDetail(postId);
                        }
                        loadPosts();
                        alert('댓글이 작성되었습니다.');
                    }
                })
                .catch(function (err) {
                    alert(err.message || '댓글 작성 실패');
                });
        });
    }
});
