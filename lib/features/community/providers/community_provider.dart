import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/post_model.dart';
import '../models/topic_model.dart';
import '../models/comment_model.dart';
import '../models/active_member_model.dart';
import '../services/community_service.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityService _service = CommunityService();
  List<CommunityPost> _posts = [];
  List<CommunityTopic> _topics = [];
  String _selectedTopic = 'Tout';
  final Map<String, List<CommunityComment>> _postComments = {};
  final Map<String, bool> _isCommentsLoading = {};
  String _searchQuery = '';
  String _timeFilter = 'Tous';
  List<ActiveMember> _leaderboard = [];
  bool _isLoading = false;
  bool _isLeaderboardLoading = false;
  String? _error;
  String? _leaderboardError;
  int _notificationCount = 3;

  List<CommunityPost> get posts => _posts;
  List<CommunityTopic> get topics => _topics;
  int get notificationCount => _notificationCount;
  List<ActiveMember> get leaderboard {
    List<ActiveMember> filtered = _leaderboard;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((m) => m.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    // Note: Actual time filtering would require backend support or date fields in ActiveMember.
    // For now, we simulate the UI behavior.
    return filtered;
  }
  String get selectedTopic => _selectedTopic;
  String get searchQuery => _searchQuery;
  String get timeFilter => _timeFilter;
  bool get isLoading => _isLoading;
  bool get isLeaderboardLoading => _isLeaderboardLoading;
  String? get error => _error;
  String? get leaderboardError => _leaderboardError;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setTimeFilter(String filter) {
    _timeFilter = filter;
    notifyListeners();
  }

  List<CommunityComment> getComments(String postId) => _postComments[postId] ?? [];
  bool isCommentsLoading(String postId) => _isCommentsLoading[postId] ?? false;

  CommunityProvider() {
    init();
  }

  Future<void> init() async {
    await Future.wait([
      fetchTopics(),
      fetchPosts(),
      fetchLeaderboard(),
    ]);
  }

  Future<void> fetchTopics() async {
    try {
      _topics = await _service.getTopics();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading topics: $e');
    }
  }

  Future<void> fetchLeaderboard() async {
    _isLeaderboardLoading = true;
    _leaderboardError = null;
    notifyListeners();
    try {
      _leaderboard = await _service.getLeaderboard();
    } catch (e) {
      _leaderboardError = e.toString();
      debugPrint('Error loading leaderboard: $e');
    } finally {
      _isLeaderboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectTopic(String topic) async {
    _selectedTopic = topic;
    notifyListeners();
    await fetchPosts();
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _service.getAllPosts(topic: _selectedTopic);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchComments(String postId) async {
    _isCommentsLoading[postId] = true;
    notifyListeners();

    try {
      final comments = await _service.getComments(postId);
      _postComments[postId] = comments;
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      _isCommentsLoading[postId] = false;
      notifyListeners();
    }
  }

  Future<void> addCommentToPost(String postId, String content) async {
    final comment = CommunityComment(
      id: '0',
      authorName: 'Vous',
      authorAvatar: 'assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg',
      content: content,
      createdAt: DateTime.now(),
    );

    try {
      final savedComment = await _service.addComment(postId, comment);
      if (_postComments.containsKey(postId)) {
        _postComments[postId]!.add(savedComment);
      } else {
        _postComments[postId] = [savedComment];
      }
      
      // Update post comment count locally
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].comments++;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  Future<void> toggleLike(String postId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      post.isLiked = !post.isLiked;
      post.likes += post.isLiked ? 1 : -1;
      notifyListeners();

      try {
        await _service.toggleLike(postId);
      } catch (e) {
        post.isLiked = !post.isLiked;
        post.likes += post.isLiked ? 1 : -1;
        notifyListeners();
      }
    }
  }

  Future<void> addPost(String content, {PlatformFile? imageFile}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      List<String> images = [];
      if (imageFile != null) {
        final imageUrl = await _service.uploadImage(imageFile);
        images.add(imageUrl);
      }

      final newPost = CommunityPost(
        id: '0', 
        authorName: 'Vous', 
        authorAvatar: 'assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg',
        timeAgo: 'À l\'instant',
        content: content,
        images: images,
        likes: 0,
        comments: 0,
        shares: 0,
      );

      final createdPost = await _service.createPost(newPost);
      _posts.insert(0, createdPost);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
