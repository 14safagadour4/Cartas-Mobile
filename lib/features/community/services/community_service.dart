import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import 'package:file_picker/file_picker.dart';
import '../models/comment_model.dart';
import '../models/active_member_model.dart';
import '../models/topic_model.dart';

class CommunityService {
  final String baseUrl = 'http://10.0.2.2:8080/api/community';
  final String uploadUrl = 'http://10.0.2.2:8080/api/upload';

  Future<List<CommunityTopic>> getTopics() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/topics'));
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => CommunityTopic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load topics');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<CommunityPost>> getAllPosts({String? topic}) async {
    try {
      String url = '$baseUrl/posts';
      if (topic != null && topic != 'Tout') {
        url += '?topic=${Uri.encodeComponent(topic)}';
      }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => CommunityPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<CommunityComment>> getComments(String postId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$postId/comments'));
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => CommunityComment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<CommunityComment> addComment(String postId, CommunityComment comment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$postId/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(comment.toJson()),
      );
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return CommunityComment.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to add comment');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<String> uploadImage(PlatformFile file) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      
      if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath('file', file.path!));
      } else if (file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name));
      } else {
        throw Exception('File path and bytes are both null');
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        return responseData; // Returns the public URL of the uploaded image
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error during upload: $e');
    }
  }

  Future<CommunityPost> createPost(CommunityPost post) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(post.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return CommunityPost.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<CommunityPost> toggleLike(String postId) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/$postId/like'));
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        return CommunityPost.fromJson(json.decode(decodedBody));
      } else {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<ActiveMember>> getLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leaderboard'));
      print('Leaderboard Response Status: ${response.statusCode}');
      print('Leaderboard Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(decodedBody);
        return data.map((json) => ActiveMember.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
