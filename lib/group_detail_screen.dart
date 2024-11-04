import 'package:flutter/material.dart';
import 'package:map/dto/group_response_dto.dart';

class GroupDetailScreen extends StatelessWidget {
  final GroupResponseDto group;

  const GroupDetailScreen({Key? key, required this.group}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name ?? 'Chi tiết nhóm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name ?? 'Nhóm của tôi',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (group.description != null && group.description!.isNotEmpty)
              Text(
                group.description!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.group, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Text('${group.totalMembers} thành viên',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.security, color: Colors.green),
                const SizedBox(width: 8),
                Text('Vai trò: ${group.role}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Quyền hạn:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: group.permissions.map((permission) {
                return Chip(
                  label: Text(permission),
                  backgroundColor: Colors.blue.shade100,
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: group.permissions.contains('DELETE')
                  ? () {
                // Xử lý giải tán nhóm
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Xác nhận'),
                      content: Text(
                          'Bạn có chắc chắn muốn giải tán nhóm ${group.name ?? 'này'} không?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Hủy'),
                        ),
                        TextButton(
                          onPressed: () {
                            // Gọi API giải tán nhóm
                            Navigator.of(context).pop();
                          },
                          child: const Text('Đồng ý',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );
              }
                  : null,
              style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.red,
              ),
              child: const Text('Giải tán nhóm'),
            ),
          ],
        ),
      ),
    );
  }
}
