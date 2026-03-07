import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import 'post_create_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostDetailModel? _post;
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    final provider = context.read<CommunityProvider>();
    final post = await provider.getPost(widget.postId);

    if (mounted) {
      setState(() {
        _post = post;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final provider = context.read<CommunityProvider>();
    final comment = await provider.createComment(
      postId: widget.postId,
      content: content,
    );

    if (mounted && comment != null) {
      _commentController.clear();
      await _loadPost();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글이 작성되었습니다.')),
        );
      }
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
    }
  }

  Future<void> _togglePin() async {
    if (_post == null) return;

    final provider = context.read<CommunityProvider>();
    final updated = await provider.pinPost(widget.postId, !_post!.isPinned);

    if (mounted && updated != null) {
      setState(() => _post = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updated.isPinned ? '상단 고정되었습니다.' : '고정이 해제되었습니다.',
          ),
        ),
      );
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<CommunityProvider>();
      final success = await provider.deletePost(widget.postId);

      if (mounted && success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글이 삭제되었습니다.')),
        );
      }
    }
  }

  void _editPost() {
    if (_post == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostCreateScreen(
          postId: widget.postId,
          initialTitle: _post!.title,
          initialContent: _post!.content,
        ),
      ),
    ).then((_) => _loadPost());
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.userId;
    final isAuthor = currentUserId != null && _post?.authorId == currentUserId;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.headerGrey,
        elevation: 0,
        title: const Text(
          '게시글',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (isAuthor && _post != null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.white),
              onSelected: (value) {
                if (value == 'edit') _editPost();
                if (value == 'pin') _togglePin();
                if (value == 'delete') _deletePost();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('수정'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'pin',
                  child: Row(
                    children: [
                      Icon(_post!.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                      const SizedBox(width: 8),
                      Text(_post!.isPinned ? '고정 해제' : '상단 고정'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.errorRed),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: AppColors.errorRed)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _post == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('게시글을 불러올 수 없습니다.'),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('돌아가기'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPost,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildContent(),
                        if (_post!.poll != null) ...[
                          const SizedBox(height: 20),
                          _buildPollSection(),
                        ],
                        const SizedBox(height: 24),
                        const Divider(),
                        _buildCommentSection(),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: _post != null ? _buildCommentInput() : null,
    );
  }

  Widget _buildHeader() {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.boxBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_post!.isPinned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.alertOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '공지',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.alertOrange,
                ),
              ),
            ),
          Text(
            _post!.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.titleText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: _post!.authorProfileImageUrl.isNotEmpty
                    ? NetworkImage(_post!.authorProfileImageUrl)
                    : null,
                child: _post!.authorProfileImageUrl.isEmpty
                    ? Text(
                        _post!.authorName.isNotEmpty
                            ? _post!.authorName[0]
                            : '?',
                        style: const TextStyle(fontSize: 14),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _post!.authorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.titleText,
                    ),
                  ),
                  Text(
                    dateFormat.format(_post!.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: AppColors.subText.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_post!.viewCount}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.subText,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: AppColors.subText.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_post!.comments.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.boxBorder),
      ),
      child: Text(
        _post!.content,
        style: const TextStyle(
          fontSize: 15,
          height: 1.6,
          color: AppColors.titleText,
        ),
      ),
    );
  }

  bool _isPollVoting = false;

  Widget _buildPollSection() {
    final poll = _post!.poll!;
    final canVote = !poll.isExpired &&
        poll.myVoteOptionId == null &&
        context.read<AuthProvider>().currentUser != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.boxBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.poll, size: 20, color: AppColors.subText),
              const SizedBox(width: 8),
              Text(
                poll.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.titleText,
                ),
              ),
            ],
          ),
          if (poll.expiresAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                poll.isExpired
                    ? '투표가 종료되었습니다.'
                    : '만료: ${DateFormat('yyyy.MM.dd').format(poll.expiresAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: poll.isExpired
                      ? AppColors.errorRed
                      : AppColors.subText,
                ),
              ),
            ),
          const SizedBox(height: 12),
          ...poll.options.map((opt) {
            final isMyVote = poll.myVoteOptionId == opt.id;
            final ratio = poll.totalVotes > 0
                ? opt.voteCount / poll.totalVotes
                : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: canVote && !_isPollVoting
                    ? () => _vote(opt.id)
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMyVote
                        ? AppColors.activeBlue.withValues(alpha: 0.15)
                        : AppColors.pageBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isMyVote
                          ? AppColors.activeBlue
                          : AppColors.boxBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              opt.text,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isMyVote ? FontWeight.w600 : null,
                                color: AppColors.titleText,
                              ),
                            ),
                            if (!canVote || poll.myVoteOptionId != null) ...[
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 6,
                                  backgroundColor:
                                      AppColors.boxBorder.withValues(alpha: 0.5),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isMyVote
                                        ? AppColors.activeBlue
                                        : AppColors.subText,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${opt.voteCount}표',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.subText,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (canVote && !_isPollVoting)
                        FilledButton(
                          onPressed: () => _vote(opt.id),
                          child: const Text('선택'),
                        )
                      else if (isMyVote)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.check_circle,
                            color: AppColors.activeBlue,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (poll.totalVotes > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '총 ${poll.totalVotes}명 참여',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.subText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _vote(String optionId) async {
    setState(() => _isPollVoting = true);
    final provider = context.read<CommunityProvider>();
    final success = await provider.votePoll(
      postId: widget.postId,
      optionId: optionId,
    );
    if (mounted) {
      setState(() => _isPollVoting = false);
      if (success) {
        await _loadPost();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('투표가 반영되었습니다.')),
        );
      } else if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
      }
    }
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '댓글 ${_post!.comments.length}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.titleText,
          ),
        ),
        const SizedBox(height: 12),
        if (_post!.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                '아직 댓글이 없습니다.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.subText.withValues(alpha: 0.8),
                ),
              ),
            ),
          )
        else
          ..._post!.comments.map((c) => _CommentTile(
                comment: c,
                currentUserId: context.read<AuthProvider>().currentUser?.userId,
                onDelete: () async {
                  final provider = context.read<CommunityProvider>();
                  await provider.deleteComment(
                    postId: widget.postId,
                    commentId: c.id,
                  );
                  _loadPost();
                },
              )),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.boxBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _submitComment,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final int? currentUserId;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd HH:mm');
    final isAuthor = currentUserId == comment.authorId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pageBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.authorProfileImageUrl.isNotEmpty
                ? NetworkImage(comment.authorProfileImageUrl)
                : null,
            child: comment.authorProfileImageUrl.isEmpty
                ? Text(
                    comment.authorName.isNotEmpty
                        ? comment.authorName[0]
                        : '?',
                    style: const TextStyle(fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.titleText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subText,
                      ),
                    ),
                    if (isAuthor) ...[
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('댓글 삭제'),
                              content: const Text('정말 삭제하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('취소'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.errorRed,
                                  ),
                                  child: const Text('삭제'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) onDelete();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: const Text(
                          '삭제',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.titleText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
