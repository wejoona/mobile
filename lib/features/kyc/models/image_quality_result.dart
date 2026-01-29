class ImageQualityResult {
  final bool isAcceptable;
  final String? errorKey;
  final bool isBlurry;
  final bool hasGlare;
  final bool isTooDark;

  const ImageQualityResult({
    required this.isAcceptable,
    this.errorKey,
    this.isBlurry = false,
    this.hasGlare = false,
    this.isTooDark = false,
  });

  factory ImageQualityResult.acceptable() {
    return const ImageQualityResult(isAcceptable: true);
  }

  factory ImageQualityResult.blurry() {
    return const ImageQualityResult(
      isAcceptable: false,
      isBlurry: true,
      errorKey: 'kyc_error_imageBlurry',
    );
  }

  factory ImageQualityResult.glare() {
    return const ImageQualityResult(
      isAcceptable: false,
      hasGlare: true,
      errorKey: 'kyc_error_imageGlare',
    );
  }

  factory ImageQualityResult.tooDark() {
    return const ImageQualityResult(
      isAcceptable: false,
      isTooDark: true,
      errorKey: 'kyc_error_imageTooDark',
    );
  }
}
