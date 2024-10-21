import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop(); // Đóng màn hình khi nhấn vào ảnh
        },
        onHorizontalDragEnd: (details) {
          Navigator.of(context).pop(); // Quay lại màn hình trước khi vuốt ngang
        },
        onVerticalDragEnd: (details) {
          Navigator.of(context).pop(); // Quay lại màn hình trước khi vuốt dọc
        },
        child: Stack(
          children: [
            PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained, // Tỉ lệ phóng to tối thiểu
              maxScale: PhotoViewComputedScale.covered * 2, // Tỉ lệ phóng to tối đa
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl), // Thêm hiệu ứng hero
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.of(context).pop(); // Quay lại màn hình trước
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
