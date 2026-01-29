import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';
import '../../../services/payment_links/payment_links_service.dart';
import '../models/index.dart';

// Service Provider
final paymentLinksServiceProvider = Provider<PaymentLinksService>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentLinksService(dio);
});

// State
class PaymentLinksState {
  final bool isLoading;
  final String? error;
  final List<PaymentLink> links;
  final PaymentLink? currentLink;
  final PaymentLinkStatus? filterStatus;

  const PaymentLinksState({
    this.isLoading = false,
    this.error,
    this.links = const [],
    this.currentLink,
    this.filterStatus,
  });

  PaymentLinksState copyWith({
    bool? isLoading,
    String? error,
    List<PaymentLink>? links,
    PaymentLink? currentLink,
    PaymentLinkStatus? filterStatus,
  }) {
    return PaymentLinksState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      links: links ?? this.links,
      currentLink: currentLink ?? this.currentLink,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }

  List<PaymentLink> get filteredLinks {
    if (filterStatus == null) return links;
    return links.where((link) => link.status == filterStatus).toList();
  }

  int get activeLinksCount =>
      links.where((link) => link.isActive).length;

  int get paidLinksCount =>
      links.where((link) => link.isPaid).length;

  double get totalEarned =>
      links.where((link) => link.isPaid).fold(0.0, (sum, link) => sum + link.amount);
}

// Notifier
class PaymentLinksNotifier extends Notifier<PaymentLinksState> {
  @override
  PaymentLinksState build() => const PaymentLinksState();

  /// Load all payment links
  Future<void> loadLinks({PaymentLinkStatus? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(paymentLinksServiceProvider);
      final links = await service.getLinks(status: status);
      state = state.copyWith(
        isLoading: false,
        links: links,
        filterStatus: status,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create a new payment link
  Future<PaymentLink?> createLink(CreateLinkRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(paymentLinksServiceProvider);
      final link = await service.createLink(request);

      // Add to list
      final updatedLinks = [link, ...state.links];
      state = state.copyWith(
        isLoading: false,
        currentLink: link,
        links: updatedLinks,
      );
      return link;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Get a specific link
  Future<void> loadLink(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(paymentLinksServiceProvider);
      final link = await service.getLink(id);
      state = state.copyWith(
        isLoading: false,
        currentLink: link,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cancel a payment link
  Future<bool> cancelLink(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final service = ref.read(paymentLinksServiceProvider);
      await service.cancelLink(id);

      // Update local state
      final updatedLinks = state.links.map((link) {
        if (link.id == id) {
          return link.copyWith(status: PaymentLinkStatus.cancelled);
        }
        return link;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        links: updatedLinks,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Refresh a link's status
  Future<void> refreshLink(String id) async {
    try {
      final service = ref.read(paymentLinksServiceProvider);
      final updatedLink = await service.refreshLink(id);

      // Update in list
      final updatedLinks = state.links.map((link) {
        if (link.id == id) {
          return updatedLink;
        }
        return link;
      }).toList();

      state = state.copyWith(
        links: updatedLinks,
        currentLink: state.currentLink?.id == id ? updatedLink : state.currentLink,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set filter status
  void setFilter(PaymentLinkStatus? status) {
    state = state.copyWith(filterStatus: status);
  }

  /// Clear current link
  void clearCurrentLink() {
    state = state.copyWith(currentLink: null);
  }
}

// Provider
final paymentLinksProvider = NotifierProvider<PaymentLinksNotifier, PaymentLinksState>(
  PaymentLinksNotifier.new,
);
