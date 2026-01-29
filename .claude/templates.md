# Code Templates - Copy & Customize

## Screen Template
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class FeatureNameView extends ConsumerStatefulWidget {
  const FeatureNameView({super.key});

  @override
  ConsumerState<FeatureNameView> createState() => _FeatureNameViewState();
}

class _FeatureNameViewState extends ConsumerState<FeatureNameView> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(l10n.feature_title, style: AppTypography.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Content here
              const Spacer(),
              AppButton(
                label: l10n.common_continue,
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    try {
      // Action here
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

## Form Screen Template
```dart
class FormView extends ConsumerStatefulWidget {
  const FormView({super.key});

  @override
  ConsumerState<FormView> createState() => _FormViewState();
}

class _FormViewState extends ConsumerState<FormView> {
  final _formKey = GlobalKey<FormState>();
  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(title: AppText(l10n.feature_title)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              AppInput(
                label: l10n.field_label1,
                controller: _controller1,
                validator: (v) => v?.isEmpty == true ? l10n.error_required : null,
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.field_label2,
                controller: _controller2,
              ),
              SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.common_submit,
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Submit logic
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

## Provider Template
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State
class FeatureState {
  final bool isLoading;
  final String? error;
  final List<Item> items;

  const FeatureState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  FeatureState copyWith({
    bool? isLoading,
    String? error,
    List<Item>? items,
  }) {
    return FeatureState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
    );
  }
}

// Notifier
class FeatureNotifier extends Notifier<FeatureState> {
  @override
  FeatureState build() => const FeatureState();

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final sdk = ref.read(sdkProvider);
      final items = await sdk.feature.getItems();
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Provider
final featureProvider = NotifierProvider<FeatureNotifier, FeatureState>(
  FeatureNotifier.new,
);
```

## Service Template
```dart
import 'package:dio/dio.dart';

class FeatureService {
  final Dio _dio;

  FeatureService(this._dio);

  Future<List<Item>> getItems() async {
    final response = await _dio.get('/feature/items');
    return (response.data['items'] as List)
        .map((json) => Item.fromJson(json))
        .toList();
  }

  Future<Item> createItem(CreateItemRequest request) async {
    final response = await _dio.post('/feature/items', data: request.toJson());
    return Item.fromJson(response.data);
  }

  Future<void> deleteItem(String id) async {
    await _dio.delete('/feature/items/$id');
  }
}
```

## Mock Template
```dart
import '../../base/api_contract.dart';
import '../../base/mock_interceptor.dart';

class FeatureMock {
  static void register() {
    // GET /feature/items
    MockInterceptor.register(MockEndpoint(
      method: 'GET',
      pathPattern: '/feature/items',
      handler: (options) => MockResponse.success({
        'items': [
          {'id': '1', 'name': 'Item 1'},
          {'id': '2', 'name': 'Item 2'},
        ],
      }),
    ));

    // POST /feature/items
    MockInterceptor.register(MockEndpoint(
      method: 'POST',
      pathPattern: '/feature/items',
      handler: (options) => MockResponse.success({
        'id': 'new-id',
        'name': options.data['name'],
      }),
    ));

    // DELETE /feature/items/:id
    MockInterceptor.register(MockEndpoint(
      method: 'DELETE',
      pathPattern: r'/feature/items/[\w-]+',
      handler: (options) => MockResponse.success({'success': true}),
    ));
  }
}
```

## Model Template
```dart
class Item {
  final String id;
  final String name;
  final DateTime createdAt;

  const Item({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
  };

  Item copyWith({String? id, String? name, DateTime? createdAt}) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

## Route Template
```dart
// Add to lib/router/app_router.dart in routes list:

GoRoute(
  path: '/feature',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context, state, const FeatureView(),
  ),
  routes: [
    GoRoute(
      path: 'detail/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return AppPageTransitions.slideLeft(
          context, state, FeatureDetailView(id: id),
        );
      },
    ),
  ],
),
```

## Test Template
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeatureService', () {
    late FeatureService service;

    setUp(() {
      service = FeatureService(mockDio);
    });

    test('should get items', () async {
      final items = await service.getItems();
      expect(items, isNotEmpty);
      expect(items.first.id, isNotNull);
    });

    test('should handle error', () async {
      expect(
        () => service.getItems(),
        throwsA(isA<DioException>()),
      );
    });
  });
}
```

## Dialog Template
```dart
Future<bool?> showConfirmDialog(BuildContext context, AppLocalizations l10n) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.charcoal,
      title: AppText(l10n.dialog_title, style: AppTypography.headlineSmall),
      content: AppText(l10n.dialog_message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: AppText(l10n.common_cancel),
        ),
        AppButton(
          label: l10n.common_confirm,
          onPressed: () => Navigator.pop(context, true),
          size: ButtonSize.small,
        ),
      ],
    ),
  );
}
```

## Bottom Sheet Template
```dart
Future<T?> showFeatureBottomSheet<T>(BuildContext context) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.charcoal,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.silver,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          // Content here
        ],
      ),
    ),
  );
}
```
