import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map/bloc/search/search_bloc.dart';
import 'package:map/bloc/search/search_state.dart';

import '../bloc/search/search_event.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchBloc searchBloc = SearchBloc();
  final TextEditingController controller = TextEditingController();
  final FocusNode searchFocusNode = FocusNode(); // Khởi tạo FocusNode

  @override
  void initState() {
    super.initState();
    // Tự động focus vào ô tìm kiếm khi màn hình được hiển thị
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => searchBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Builder(
            builder: (context) {
              return BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchSuggestionsState) {
                    return TextField(
                      onSubmitted: (query) {
                        BlocProvider.of<SearchBloc>(context)
                            .add(ExecuteSearchEvent(placePrediction: state.suggestions.first));
                      },
                      focusNode: searchFocusNode,
                      controller: controller,
                      onChanged: (query) {
                        BlocProvider.of<SearchBloc>(context)
                            .add(SearchQueryEvent(query: query));
                      },
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm địa điểm',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: controller.text.isNotEmpty
                              ? const Icon(Icons.clear)
                              : const Icon(null),
                          onPressed: () {
                            controller.clear();
                            BlocProvider.of<SearchBloc>(context)
                                .add(InitSearchEvent());
                          },
                        ),
                      ),
                    );
                  }else if(state is SearchFailure){
                   return _alertDialog(context, state.message);
                  }else if (state is FinishSearchState){
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pop(context,state.place);
                    });
                  }
                  return const Text('Tìm kiếm địa điểm');
                },
              );
            },
          ),
        ),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchSuggestionsState) {
              if (state.suggestions.isEmpty) {
                return const Center(
                    child: Text('Không tìm thấy kết quả phù hợp.'));
              }
              return _listLocationBuilder(
                  context, state.suggestions, Icons.search);
            }else if(state is SearchLoading){
              return const Center(child: CircularProgressIndicator());
            }else if(state is SearchFailure){
              return _alertDialog(context, state.message);
            }
            else {
              return const Center(child: Text('Bắt đầu nhập để tìm kiếm.'));
            }
          },
        ),
      ),
    );
  }
  Widget _alertDialog(BuildContext context, String message) {
    return AlertDialog(
      title: Text('Thông báo'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            BlocProvider.of<SearchBloc>(context)
                .add(InitSearchEvent());
          },
          child: Text('Đồng ý'),
        ),
      ],
    );
  }
  Widget _listLocationBuilder(context, locations, icon) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const Divider(
          indent: 56,
          endIndent: 56,
          thickness: 0.4,
        );
      },
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return BlocProvider(
            create: (context) => searchBloc,
            child: ListTile(
              leading: Icon(icon),
              title: Text(location.mainText),
              subtitle: Text(location.secondaryText ?? ''),
              onTap: () {
                controller.text = location.mainText;
                BlocProvider.of<SearchBloc>(context)
                    .add(ExecuteSearchEvent(placePrediction: location));
              },
            ));
      },
    );
  }

  @override
  void dispose() {
    searchFocusNode.dispose(); // Đảm bảo giải phóng FocusNode
    controller.dispose();
    super.dispose();
  }
}
