import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/group/group_create_bloc.dart';
import 'package:map/bloc/group/group_create_state.dart';
import 'package:map/common_view/loading.dart';
import 'package:map/entity/user.dart';
import 'package:map/group_screen.dart';
import 'bloc/group/group_create_event.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GroupCreateBloc _groupCreateBloc = GroupCreateBloc();

  bool _showAppBarActions = true;

  @override
  void dispose() {
    _groupNameController.dispose();
    _searchController.dispose();
    _descriptionController.dispose();
    _groupCreateBloc.close();
    super.dispose();
  }

  void _addMember(User member) {
    _groupCreateBloc.add(GrcAddMemberEvent(member: member));
  }

  void _removeMember(User member) {
    _groupCreateBloc.add(GrcRemoveMemberEvent(member: member));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _groupCreateBloc,
      child: Scaffold(
        appBar: AppBar(
          leading: _showAppBarActions
              ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          )
              : null,
          title: const Text('Tạo Nhóm Mới'),
          actions: _showAppBarActions
              ? [
            TextButton(
              onPressed: () {
                setState(() {
                  _showAppBarActions = false;
                });
                _groupCreateBloc.add(GrcCreateGroupEvent(
                  groupName: _groupNameController.text,
                  description: _descriptionController.text,
                ));
              },
              child: const Text('Tạo', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ]
              : [],
        ),
        body: BlocBuilder<GroupCreateBloc, GroupCreateState>(
          builder: (context, state) {
            if (state is GrcLoadingState) {
              return loading();
            } else if (state is GrcErrorState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Wrap(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        Text(state.message),
                      ],
                    ),
                    duration: const Duration(seconds: 10),
                  ),
                );
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => GroupListScreen()),
                );
              });
            } else if (state is GrcSuccessState) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(
                   content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check, color: Colors.green),
                            Text('Tạo nhóm thành công'),
                          ],
                        ),
                        Text('Vui lòng chờ xác nhận từ các thành viên khác'),
                      ],
                   ),
                   duration: Duration(seconds: 10),
                 ),
               );
               Navigator.of(context).pop();
               Navigator.of(context).pushReplacement(
                 MaterialPageRoute(builder: (context) => GroupListScreen()),
               );
             });
            } else if (state is GrcLoadedState) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _groupNameController,
                      label: 'Tên nhóm (không bắt buộc)',
                      icon: Icons.group,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Mô tả (không bắt buộc)',
                      icon: Icons.description,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _searchController,
                      label: 'Email, tên bạn bè',
                      icon: Icons.search,
                      onChanged: (value) {
                        _groupCreateBloc.add(GrcSearchEvent(query: value));
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Thành viên đã chọn:',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: state.selectedMembers.map((member) {
                        return Chip(
                          backgroundColor: Colors.blue.shade50,
                          avatar: CircleAvatar(
                            backgroundImage: NetworkImage(member.avatarUrl),
                          ),
                          label: Text(
                            member.name,
                            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                          ),
                          deleteIcon: const Icon(Icons.close, color: Colors.red),
                          onDeleted: () => _removeMember(member),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Gợi ý thành viên:',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _listMemberSuggestionBuilder(context, state),
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _listMemberSuggestionBuilder(BuildContext context, GroupCreateState state) {
    if (state is GrcLoadedState) {
      List<User> friends = state.friends;
      List<User> selectedMembers = state.selectedMembers;
      return ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          User member = friends[index];
          bool isSelected = selectedMembers.contains(member);
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(member.avatarUrl),
              ),
              title: Text(
                member.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Checkbox(
                activeColor: Colors.blue,
                value: isSelected,
                onChanged: (bool? value) {
                  if (value == true) {
                    _addMember(member);
                  } else {
                    _removeMember(member);
                  }
                },
              ),
              onTap: () {
                if (isSelected) {
                  _removeMember(member);
                } else {
                  _addMember(member);
                }
              },
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}