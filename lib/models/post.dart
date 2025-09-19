// ตัวอย่าง Model Class สำหรับ Post จาก JSONPlaceholder
import 'dart:convert';

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  // Factory constructor สำหรับสร้าง Post จาก Map (JSON)
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] as int, // ต้อง cast ประเภทให้ถูกต้อง
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

// การใช้งานภายใน processJsonData
void processJsonData(String jsonString) {
  try {
    dynamic decodedData = jsonDecode(jsonString);

    if (decodedData is Map<String, dynamic>) {
      // แปลง Map เป็นออบเจกต์ Post
      Post post = Post.fromJson(decodedData);
      print('Parsed Post Object: ID=${post.id}, Title=${post.title}');
    } else if (decodedData is List<dynamic>) {
      // แปลง List ของ Maps เป็น List ของ Posts
      List<Post> posts = decodedData
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
      print('Parsed List of Posts (${posts.length} items)');
      for (var post in posts) {
         print('- Post ID: ${post.id}');
      }
    }
  } catch (e) {
    print('เกิดข้อผิดพลาดในการ parse JSON หรือสร้าง Model: $e');
  }
}