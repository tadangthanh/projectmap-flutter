import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/group/group_list_bloc.dart';
import 'package:map/bloc/group/group_list_state.dart';
import 'package:map/common_view/loading.dart';
import 'package:map/dto/group_response_dto.dart';

class MarkerInfoScreen extends StatefulWidget {
  final Function(String name, String description, List<GroupResponseDto> sharedGroups) onSave;

  MarkerInfoScreen({required this.onSave});

  @override
  _MarkerInfoScreenState createState() => _MarkerInfoScreenState();
}

class _MarkerInfoScreenState extends State<MarkerInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GroupListBloc _groupListBloc = GroupListBloc();

  // Trạng thái của các checkbox
  Map<GroupResponseDto, bool> _selectedGroupsStatus = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin điểm đánh dấu"),
      ),
      body: BlocProvider(
        create: (context) => _groupListBloc,
        child: BlocBuilder<GroupListBloc, GroupListState>(
          builder: (context, state) {
            if (state is GroupListLoading) {
              return loading();
            } else if (state is GroupListLoaded) {
              List<GroupResponseDto> groupsJoined = state.groupsJoined;

              // Khởi tạo trạng thái checkbox ban đầu nếu chưa được khởi tạo
              if (_selectedGroupsStatus.isEmpty) {
                _selectedGroupsStatus = {
                  for (var group in groupsJoined) group: false,
                };
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên địa điểm',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mô tả';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        "Chia sẻ với các nhóm:",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: groupsJoined.map((group) {
                            return CheckboxListTile(
                              title: Text(group.name),
                              subtitle: Text("Số thành viên: ${group.totalMembers}"),
                              value: _selectedGroupsStatus[group],
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedGroupsStatus[group] = value ?? false;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _selectedGroupsStatus.keys.every((element) => !_selectedGroupsStatus[element]!)
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  List<GroupResponseDto> sharedGroups = [];
                                  for (var group in _selectedGroupsStatus.keys) {
                                    if (_selectedGroupsStatus[group]!) {
                                      sharedGroups.add(group);
                                    }
                                  }
                                  widget.onSave(_nameController.text, _descriptionController.text, sharedGroups);
                                  Navigator.of(context).pop();
                                }
                              },
                        child: const Text("Lưu điểm đánh dấu"),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
