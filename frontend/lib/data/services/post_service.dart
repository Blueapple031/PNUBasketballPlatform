import '../models/post_model.dart';
import 'api_service.dart';
import '../../core/constants/api_endpoints.dart';

class PostService {
  final ApiService apiService;

  PostService({ApiService? apiService}) : apiService = apiService ?? ApiService();

  Map<String, String> _authHeaders(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
      };

  Future<PostListPageModel> getPosts({
    required String accessToken,
    int page = 1,
    int size = 20,
  }) async {
    final response = await apiService.get<Map<String, dynamic>>(
      '${ApiEndpoints.posts}?page=$page&size=$size',
      headers: _authHeaders(accessToken),
      fromJson: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return PostListPageModel.fromJson(response.data!);
    }
    throw Exception(response.error?['message'] ?? '게시글 목록 조회 실패');
  }

  Future<PostDetailModel> getPost({
    required String accessToken,
    required String postId,
  }) async {
    final response = await apiService.get<PostDetailModel>(
      ApiEndpoints.post(postId),
      headers: _authHeaders(accessToken),
      fromJson: (json) => PostDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?['message'] ?? '게시글 조회 실패');
  }

  Future<PostDetailModel> createPost({
    required String accessToken,
    required String title,
    required String content,
  }) async {
    final response = await apiService.post<PostDetailModel>(
      ApiEndpoints.posts,
      headers: _authHeaders(accessToken),
      body: {'title': title, 'content': content},
      fromJson: (json) => PostDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?['message'] ?? '게시글 작성 실패');
  }

  Future<PostDetailModel> updatePost({
    required String accessToken,
    required String postId,
    String? title,
    String? content,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (content != null) body['content'] = content;

    final response = await apiService.put<PostDetailModel>(
      ApiEndpoints.post(postId),
      headers: _authHeaders(accessToken),
      body: body.isNotEmpty ? body : null,
      fromJson: (json) => PostDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?['message'] ?? '게시글 수정 실패');
  }

  Future<void> deletePost({
    required String accessToken,
    required String postId,
  }) async {
    final response = await apiService.delete<dynamic>(
      ApiEndpoints.post(postId),
      headers: _authHeaders(accessToken),
    );

    if (!response.success) {
      throw Exception(response.error?['message'] ?? '게시글 삭제 실패');
    }
  }

  Future<PostDetailModel> pinPost({
    required String accessToken,
    required String postId,
    required bool isPinned,
  }) async {
    final response = await apiService.patch<PostDetailModel>(
      ApiEndpoints.postPin(postId),
      headers: _authHeaders(accessToken),
      body: {'isPinned': isPinned},
      fromJson: (json) => PostDetailModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?['message'] ?? '핀 설정 실패');
  }

  Future<CommentModel> createComment({
    required String accessToken,
    required String postId,
    required String content,
  }) async {
    final response = await apiService.post<CommentModel>(
      ApiEndpoints.postComments(postId),
      headers: _authHeaders(accessToken),
      body: {'content': content},
      fromJson: (json) => CommentModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?['message'] ?? '댓글 작성 실패');
  }

  Future<CommentModel> updateComment({
    required String accessToken,
    required String postId,
    required String commentId,
    required String content,
  }) async {
    final response = await apiService.put<CommentModel>(
      ApiEndpoints.postComment(postId, commentId),
      headers: _authHeaders(accessToken),
      body: {'content': content},
      fromJson: (json) => CommentModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error?['message'] ?? '댓글 수정 실패');
  }

  Future<void> deleteComment({
    required String accessToken,
    required String postId,
    required String commentId,
  }) async {
    final response = await apiService.delete<dynamic>(
      ApiEndpoints.postComment(postId, commentId),
      headers: _authHeaders(accessToken),
    );

    if (!response.success) {
      throw Exception(response.error?['message'] ?? '댓글 삭제 실패');
    }
  }
}
