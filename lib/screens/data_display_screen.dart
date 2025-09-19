import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todos_api_app/models/post.dart';
import 'package:http/http.dart' as http;

class DataDisplayScreen extends StatefulWidget {
  const DataDisplayScreen({super.key});

  @override
  State<DataDisplayScreen> createState() => _DataDisplayScreenState();
}

class _DataDisplayScreenState extends State<DataDisplayScreen> {
  late Future<List<Post>> futurePosts; // เก็บ Future ไว้ใน state

  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันดึงข้อมูล *ครั้งเดียว* ใน initState
    futurePosts =
        fetchPosts(); // สมมติว่า fetchPosts() ส่งคืน Future<List<Post>>
  }

  // ฟังก์ชันตัวอย่างสำหรับดึงข้อมูล (ควรอยู่ในไฟล์ service/repository แยกต่างหาก)
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> decodedList = jsonDecode(response.body) as List;
      List<Post> posts = decodedList
          .map((item) => Post.fromJson(item as Map<String, dynamic>))
          .toList();
      return posts;
    } else {
      throw Exception(
          'Failed to load posts: ${response.statusCode} ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Posts from API')),
      body: Center(
        child: FutureBuilder<List<Post>>(
          future: futurePosts, // ส่ง Future ที่เราต้องการ listen
          builder: (context, snapshot) {
            // ตรวจสอบสถานะ ConnectionState
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 1. ขณะกำลังรอ Future: แสดง loading indicator
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // 2. หาก Future เสร็จสิ้นพร้อมข้อผิดพลาด: แสดงข้อความข้อผิดพลาด
              return Text('เกิดข้อผิดพลาด: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // 3. หาก Future เสร็จสิ้นพร้อมข้อมูล: แสดงข้อมูล
              final posts = snapshot
                  .data!; // เข้าถึงข้อมูล (ใช้ ! เพราะเราเช็ค hasData แล้ว)

              // แสดงข้อมูลใน ListView
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(post.id.toString())),
                    title: Text(post.title),
                    subtitle: Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              );
            } else {
              // 4. กรณีอื่นๆ (เช่น Future เป็น null หรือสถานะเริ่มต้น): แสดงข้อความว่าง
              return const Text('ไม่มีข้อมูล');
            }
          },
        ),
      ),
    );
  }
}