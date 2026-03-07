import 'package:flutter/foundation.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';

class CommunityProvider with ChangeNotifier {
  final PostRepository postRepository;

  CommunityProvider({PostRepository? postRepository})
      : postRepository = postRepository ?? PostRepository();

  List<PostListModel> _posts = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalElements = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<PostListModel> get posts => _posts;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _currentPage < _totalPages;

  Future<void> loadPosts({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    if (refresh) _currentPage = 1;
    notifyListeners();

    try {
      final result = await postRepository.getPosts(
        page: _currentPage,
        size: 20,
      );

      if (refresh) {
        _posts = result.content;
      } else {
        _posts = [..._posts, ...result.content];
      }
      _totalPages = result.totalPages;
      _currentPage = result.currentPage;
      _totalElements = result.totalElements;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !hasMore) return;
    _currentPage++;
    await loadPosts();
  }

  Future<PostDetailModel?> getPost(String postId) async {
    try {
      _errorMessage = null;
      return await postRepository.getPost(postId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<PostDetailModel?> createPost({
    required String title,
    required String content,
  }) async {
    try {
      _errorMessage = null;
      final post = await postRepository.createPost(
        title: title,
        content: content,
      );
      await loadPosts(refresh: true);
      return post;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<PostDetailModel?> updatePost({
    required String postId,
    String? title,
    String? content,
  }) async {
    try {
      _errorMessage = null;
      final post = await postRepository.updatePost(
        postId: postId,
        title: title,
        content: content,
      );
      notifyListeners();
      return post;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      _errorMessage = null;
      await postRepository.deletePost(postId);
      await loadPosts(refresh: true);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<PostDetailModel?> pinPost(String postId, bool isPinned) async {
    try {
      _errorMessage = null;
      final post = await postRepository.pinPost(postId, isPinned);
      await loadPosts(refresh: true);
      return post;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<CommentModel?> createComment({
    required String postId,
    required String content,
  }) async {
    try {
      _errorMessage = null;
      return await postRepository.createComment(
        postId: postId,
        content: content,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<CommentModel?> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    try {
      _errorMessage = null;
      return await postRepository.updateComment(
        postId: postId,
        commentId: commentId,
        content: content,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      _errorMessage = null;
      await postRepository.deleteComment(
        postId: postId,
        commentId: commentId,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
