
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseLookupDialog<T> extends StatefulWidget {
  final Future<List<T>> Function(String search, int page) fetchPage;
  final Widget Function(T item) itemBuilder;
  final String Function(T item) displayText;
  final int pageSize;
  final String title;

  const BaseLookupDialog({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    required this.displayText,
    this.pageSize = 20,
    required this.title,
  });

  @override
  State<BaseLookupDialog<T>> createState() => _BaseLookupDialogState<T>();
}

class _BaseLookupDialogState<T> extends State<BaseLookupDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<T> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    _fetchItems();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100 &&
          !_isLoading &&
          _hasMore) {
        _fetchItems();
      }
    });
  }

  Future<void> _fetchItems({bool reset = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    if (reset) {
      _items.clear();
      _currentPage = 1;
      _hasMore = true;
    }

    final newItems = await widget.fetchPage(
      _searchController.text.trim(),
      _currentPage,
    );

    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
      _currentPage++;
      _hasMore = newItems.length == widget.pageSize;
    });
  }

  void _onSearchChanged() {
    _fetchItems(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => _onSearchChanged(),
              decoration: const InputDecoration(
                hintText: "Search...",
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _items.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _items.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final item = _items[index];
                  final isSelected = _selectedItem == item;

                  return ListTile(
                    title: widget.itemBuilder(item),
                    selected: isSelected,
                    onTap: () => setState(() {
                      _selectedItem = item;
                      GoRouter.of(context).pop(item);
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
