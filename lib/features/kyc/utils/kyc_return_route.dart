String? safeKycReturnRoute({required String? raw, String? intent}) {
  final returnTo = raw?.trim();
  if (returnTo == null || returnTo.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(returnTo);
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !returnTo.startsWith('/') ||
      returnTo.startsWith('//')) {
    return null;
  }

  const blockedPrefixes = [
    '/login',
    '/signup',
    '/onboarding',
    '/session-locked',
    '/security-alert',
    '/force-update',
    '/kyc',
  ];
  if (blockedPrefixes.any(returnTo.startsWith)) {
    return null;
  }

  if (intent == 'deposit') {
    final path = uri.path;
    return path == '/deposit' || path.startsWith('/deposit/') ? returnTo : null;
  }

  return returnTo;
}
