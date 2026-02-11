/// Request DTO for verifying a PIN.
class VerifyPinRequest {
  final String pin;
  final String? context;

  const VerifyPinRequest({
    required this.pin,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'pin': pin,
        if (context != null) 'context': context,
      };
}
