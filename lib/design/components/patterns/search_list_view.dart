import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Search + list pattern with filtering.
class SearchListView<T> extends StatefulWidget {
  const SearchListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.searchPredicate,
    this.hintText = 'Search...',
    this.emptySearchResult,
    this.emptyState,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final bool Function(T item, String query) searchPredicate;
  final String hintText;
  final Widget? emptySearchResult;
  final Widget? emptyState;

  @override
  State<SearchListView<T>> createState() => _SearchListViewState<T>();
}

class _SearchListViewState<T> extends State<SearchListView<T>> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    if (_query.isEmpty) return widget.items;
    return widget.items
        .where((item) => widget.searchPredicate(item, _query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filtered = _filteredItems;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _controller,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: _query.isNotEmpty
                      ? (widget.emptySearchResult ??
                          Text(
                            'No results for "$_query"',
                            style: TextStyle(color: colors.textSecondary),
                          ))
                      : (widget.emptyState ?? const SizedBox.shrink()),
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      widget.itemBuilder(context, filtered[index]),
                ),
        ),
      ],
    );
  }
}
