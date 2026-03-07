import '../models/post_model.dart';
import '../services/post_service.dart';
import 'auth_repository.dart';

class PostRepository {
  final PostService postService;
  final AuthRepository authRepository;

  PostRepository({
    PostService? postService,
    AuthRepository? authRepository,
  })  : postService = postService ?? PostService(),
        authRepository = authRepository ?? AuthRepository();

  Future<String?> _getAccessToken() async {
    var token = await authRepository.getAccessToken();
    if (token != null && token.isNotEmpty) return token;
    token = await authRepository.refreshAccessToken();
    return token;
  }

  Future<PostListPageModel> getPosts({int page = 1, int size = 20}) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    return postService.getPosts(accessToken: token, page: page, size: size);
  }

  Future<PostDetailModel> getPost(String postId) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    return postService.getPost(accessToken: token, postId: postId);
  }

  Future<PostDetailModel> createPost({
    required String title,
    required String content,
    PollCreatePayload? poll,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    return postService.createPost(
      accessToken: token,
      title: title,
      content: content,
      poll: poll,
    );
  }

  Future<void> votePoll({
    required String postId,
    required String optionId,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    await postService.votePoll(
      accessToken: token,
      postId: postId,
      optionId: optionId,
    );
  }

  Future<PostDetailModel> updatePost({
    required String postId,
    String? title,
    String? content,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    return postService.updatePost(
      accessToken: token,
      postId: postId,
      title: title,
      content: content,
    );
  }

  Future<void> deletePost(String postId) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    await postService.deletePost(accessToken: token, postId: postId);
  }

  Future<PostDetailModel> pinPost(String postId, bool isPinned) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    return postService.pinPost(
      accessToken: token,
      postId: postId,
      isPinned: isPinned,
    );
  }

  Future<CommentModel> createComment({
    required String postId,
    required String content,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    return postService.createComment(
      accessToken: token,
      postId: postId,
      content: content,
    );
  }

  Future<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    return postService.updateComment(
      accessToken: token,
      postId: postId,
      commentId: commentId,
      content: content,
    );
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception('로그인이 필요합니다.');
    await postService.deleteComment(
      accessToken: token,
      postId: postId,
      commentId: commentId,
    );
  }
}
