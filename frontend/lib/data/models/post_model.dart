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
  });

  factory PostDetailModel.fromJson(Map<String, dynamic> json) {
    final commentsList = json['comments'] as List<dynamic>? ?? [];
    return PostDetailModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      authorId: json['authorId'] as int,
      authorName: json['authorName'] as String? ?? '',
      authorProfileImageUrl: json['authorProfileImageUrl'] as String? ?? '',
      viewCount: json['viewCount'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      comments: commentsList
          .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      id: json['id'] as String,
      authorId: json['authorId'] as int,
      authorName: json['authorName'] as String? ?? '',
      authorProfileImageUrl: json['authorProfileImageUrl'] as String? ?? '',
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
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
