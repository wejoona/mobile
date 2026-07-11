import 'package:dio/dio.dart';

class SupportTicketSummary {
  const SupportTicketSummary({
    required this.id,
    required this.subject,
    required this.status,
  });

  final String id;
  final String subject;
  final String status;

  factory SupportTicketSummary.fromJson(Map<String, dynamic> json) =>
      SupportTicketSummary(
        id: json['id']?.toString() ?? '',
        subject: json['subject']?.toString() ?? '',
        status: json['status']?.toString() ?? 'open',
      );
}

class SupportApi {
  SupportApi(this._dio);

  final Dio _dio;

  Future<SupportTicketSummary> createTicket({
    required String subject,
    required String message,
    String category = 'other',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/support/tickets',
      data: {
        'subject': subject,
        'message': message,
        'category': category,
        'priority': 'medium',
      },
    );
    final payload = response.data?['data'] ?? response.data;
    return SupportTicketSummary.fromJson(payload ?? const {});
  }
}
