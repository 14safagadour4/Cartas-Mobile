import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/api_service.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/active_member_model.dart';
import '../models/topic_model.dart';

class CommunityService {
  Future<List<CommunityTopic>> getTopics() async {
    try {
      final response = await ApiService.get('/community/topics');
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => CommunityTopic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load topics (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<CommunityPost>> getAllPosts({String? topic}) async {
    try {
      String endpoint = '/community/posts';
      if (topic != null && topic != 'Tout') {
        endpoint += '?topic=${Uri.encodeComponent(topic)}';
      }
      final response = await ApiService.get(endpoint);
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => CommunityPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<CommunityComment>> getComments(String postId) async {
    try {
      final response = await ApiService.get('/community/$postId/comments');
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => CommunityComment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<CommunityComment> addComment(String postId, CommunityComment comment) async {
    try {
      final response = await ApiService.post(
        '/community/$postId/comments',
        comment.toJson(),
      );
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return CommunityComment.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to add comment (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> uploadImage(PlatformFile file) async {
    try {
      if (file.path != null) {
        final response = await ApiService.postMultipart(
          '/upload',
          {},
          file.path!,
          'file',
        );
        if (response.statusCode == 200) {
          return response.body; // Returns the public URL of the uploaded image
        } else {
          throw Exception('Failed to upload image: ${response.statusCode}');
        }
      } else {
        throw Exception('File path is null');
      }
    } catch (e) {
      throw Exception('Network error during upload: $e');
    }
  }

  Future<CommunityPost> createPost(CommunityPost post) async {
    try {
      final response = await ApiService.post(
        '/community/posts',
        post.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return CommunityPost.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to create post (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<CommunityPost> toggleLike(String postId) async {
    try {
      final response = await ApiService.put(
        '/community/$postId/like',
        {},
      );
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return CommunityPost.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to like post (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<ActiveMember>> getLeaderboard() async {
    try {
      final response = await ApiService.get('/community/leaderboard');
      print('Leaderboard Response Status: ${response.statusCode}');
      print('Leaderboard Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => ActiveMember.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load leaderboard (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
