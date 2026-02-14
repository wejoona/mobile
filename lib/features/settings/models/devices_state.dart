class DevicesState {
  final bool isLoading;
  final String? error;
  final List<dynamic> devices;

  const DevicesState({this.isLoading = false, this.error, this.devices = const []});
}
