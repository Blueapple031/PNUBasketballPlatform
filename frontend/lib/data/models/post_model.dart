class PostListModel {
  final String id;
  final String title;
  final String authorName;
  final String authorProfileImageUrl;
  final int viewCount;
  final int commentCount;
  final bool isPinned;
  final DateTime createdAt;

  PostListModel({
    required this.id,
    required this.title,
    required this.authorName,
    required this.authorProfileImageUrl,
    required this.viewCount,
    required this.commentCount,
    required this.isPinned,
    required this.createdAt,
  });

  factory PostListModel.fromJson(Map<String, dynamic> json) {
    return PostListModel(
      id: json['id'] as String,
      title: json['title'] as String,
      authorName: json['authorName'] as String? ?? '',
      authorProfileImageUrl: json['authorProfileImageUrl'] as String? ?? '',
      viewCount: json['viewCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class PostDetailModel {
  final String id;
  final String title;
  final String content;
  final int authorId;
  final String authorName;
  final String authorProfileImageUrl;
  final int viewCount;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CommentModel> comments;
  final PollModel? poll;

  PostDetailModel({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.authorProfileImageUrl,
    required this.viewCount,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    required this.comments,
    this.poll,
  });

  factory PostDetailModel.fromJson(Map<String, dynamic> json) {
    final commentsList = json['comments'] as List<dynamic>? ?? [];
    final pollJson = json['poll'] as Map<String, dynamic>?;
    return PostDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: (json['authorId'] as num?)?.toInt() ?? 0,
      authorName: json['authorName'] as String? ?? '',
      authorProfileImageUrl: json['authorProfileImageUrl'] as String? ?? '',
      viewCount: json['viewCount'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      comments: commentsList
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      poll: pollJson != null ? PollModel.fromJson(pollJson) : null,
    );
  }
}

class PollModel {
  final String id;
  final String question;
  final List<PollOptionModel> options;
  final DateTime? expiresAt;
  final int totalVotes;
  final String? myVoteOptionId;

  PollModel({
    required this.id,
    required this.question,
    required this.options,
    this.expiresAt,
    required this.totalVotes,
    this.myVoteOptionId,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final optionsList = json['options'] as List<dynamic>? ?? [];
    return PollModel(
      id: json['id']?.toString() ?? '',
      question: json['question'] as String? ?? '',
      options: optionsList
          .map((e) => PollOptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
      totalVotes: json['totalVotes'] as int? ?? 0,
      myVoteOptionId: json['myVoteOptionId']?.toString(),
    );
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

class PollCreatePayload {
  final String question;
  final List<String> options;
  final DateTime? expiresAt;

  PollCreatePayload({
    required this.question,
    required this.options,
    this.expiresAt,
  });
}

class PollOptionModel {
  final String id;
  final String text;
  final int voteCount;

  PollOptionModel({
    required this.id,
    required this.text,
    required this.voteCount,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id']?.toString() ?? '',
      text: json['text'] as String? ?? '',
      voteCount: json['voteCount'] as int? ?? 0,
    );
  }
}

class CommentModel {
  final String id;
  final int authorId;
  final String authorName;
  final String authorProfileImageUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorProfileImageUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      authorId: (json['authorId'] as num?)?.toInt() ?? 0,
      authorName: json['authorName']?.toString() ?? '',
      authorProfileImageUrl: json['authorProfileImageUrl']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
}

DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is String) return DateTime.parse(value);
  if (value is List && value.length >= 6) {
    return DateTime(
      (value[0] as num).toInt(),
      (value[1] as num).toInt(),
      (value[2] as num).toInt(),
      (value[3] as num).toInt(),
      (value[4] as num).toInt(),
      value.length > 5 ? (value[5] as num).toInt() : 0,
    );
  }
  return DateTime.now();
}

class PostListPageModel {
  final List<PostListModel> content;
  final int totalPages;
  final int currentPage;
  final int totalElements;

  PostListPageModel({
    required this.content,
    required this.totalPages,
    required this.currentPage,
    required this.totalElements,
  });

  factory PostListPageModel.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>? ?? [];
    return PostListPageModel(
      content: contentList
          .map((e) => PostListModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 1,
      totalElements: json['totalElements'] as int? ?? 0,
    );
  }
}
