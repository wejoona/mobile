import 'package:usdc_wallet/design/tokens/index.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

enum VideoStep {
  instructions,
  recording,
  preview;
}

enum LivenessAction {
  lookStraight,
  turnLeft,
  turnRight,
  smile,
  blink;
}

class KycVideoView extends ConsumerStatefulWidget {
  const KycVideoView({super.key});

  @override
  ConsumerState<KycVideoView> createState() => _KycVideoViewState();
}

class _KycVideoViewState extends ConsumerState<KycVideoView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  VideoStep _currentStep = VideoStep.instructions;
  String? _videoPath;
  bool _isRecording = false;
  int _recordingDuration = 0;
  Timer? _recordingTimer;
  List<LivenessAction> _actions = [];
  int _currentActionIndex = 0;

  static const int maxRecordingSeconds = 15;
  static const int minRecordingSeconds = 5;

  @override
  void initState() {
    super.initState();
    _generateRandomActions();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _generateRandomActions() {
    // Generate 3-4 random liveness actions
    final allActions = LivenessAction.values.toList()..shuffle();
    _actions = allActions.take(3).toList();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      // Find front camera
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      AppLogger('Camera initialization error').error('Camera initialization error', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: _currentStep != VideoStep.recording
          ? AppBar(
              title: AppText(
                l10n.kyc_video_title,
                variant: AppTextVariant.headlineSmall,
              ),
              backgroundColor: Colors.transparent,
            )
          : null,
      body: SafeArea(
        child: _buildCurrentStep(l10n),
      ),
    );
  }

  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case VideoStep.instructions:
        return _buildInstructions(l10n);
      case VideoStep.recording:
        return _buildRecording(l10n);
      case VideoStep.preview:
        return _buildPreview(l10n);
    }
  }

  Widget _buildInstructions(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.gold.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.videocam,
                    size: 64,
                    color: context.colors.gold,
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),
                AppText(
                  l10n.kyc_video_instructions_title,
                  variant: AppTextVariant.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
                AppText(
                  l10n.kyc_video_instructions_description,
                  variant: AppTextVariant.bodyLarge,
                  color: context.colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xxl),
                _buildInstructionCard(
                  Icons.light_mode,
                  l10n.kyc_video_instruction_lighting_title,
                  l10n.kyc_video_instruction_lighting_description,
                ),
                SizedBox(height: AppSpacing.md),
                _buildInstructionCard(
                  Icons.face,
                  l10n.kyc_video_instruction_position_title,
                  l10n.kyc_video_instruction_position_description,
                ),
                SizedBox(height: AppSpacing.md),
                _buildInstructionCard(
                  Icons.volume_off,
                  l10n.kyc_video_instruction_quiet_title,
                  l10n.kyc_video_instruction_quiet_description,
                ),
                SizedBox(height: AppSpacing.md),
                _buildInstructionCard(
                  Icons.person,
                  l10n.kyc_video_instruction_solo_title,
                  l10n.kyc_video_instruction_solo_description,
                ),
                SizedBox(height: AppSpacing.xxl),
                AppCard(
                  variant: AppCardVariant.elevated,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.kyc_video_actions_title,
                        variant: AppTextVariant.labelLarge,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      AppText(
                        l10n.kyc_video_actions_description,
                        variant: AppTextVariant.bodySmall,
                        color: context.colors.textSecondary,
                      ),
                      SizedBox(height: AppSpacing.md),
                      ..._actions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final action = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.colors.gold.withOpacity(0.1),
                                ),
                                child: Center(
                                  child: AppText(
                                    '${index + 1}',
                                    variant: AppTextVariant.labelSmall,
                                    color: context.colors.gold,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              AppText(
                                _getActionLabel(l10n, action),
                                variant: AppTextVariant.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.kyc_video_startRecording,
            onPressed: () => _startRecordingFlow(context),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(IconData icon, String title, String description) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: context.colors.gold),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  description,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecording(AppLocalizations l10n) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentAction = _currentActionIndex < _actions.length
        ? _actions[_currentActionIndex]
        : null;

    return Stack(
      children: [
        // Camera preview
        SizedBox.expand(
          child: CameraPreview(_controller!),
        ),
        // Face oval guide
        Center(
          child: Container(
            width: 280,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.gold,
                width: 3,
              ),
            ),
          ),
        ),
        // Top instruction banner
        if (currentAction != null)
          Positioned(
            top: AppSpacing.xl,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.colors.canvas.withOpacity(0.9),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  AppText(
                    _getActionLabel(l10n, currentAction),
                    variant: AppTextVariant.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  LinearProgressIndicator(
                    value: (_currentActionIndex + 1) / _actions.length,
                    backgroundColor: context.colors.border,
                    valueColor: AlwaysStoppedAnimation(context.colors.gold),
                  ),
                ],
              ),
            ),
          ),
        // Recording indicator and timer
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: context.colors.error,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                AppText(
                  _formatDuration(_recordingDuration),
                  variant: AppTextVariant.labelMedium,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        // Stop button
        Positioned(
          bottom: AppSpacing.xxl,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _stopRecording,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.error,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 80,
                  color: context.colors.success,
                ),
                SizedBox(height: AppSpacing.lg),
                AppText(
                  l10n.kyc_video_preview_title,
                  variant: AppTextVariant.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
                AppText(
                  l10n.kyc_video_preview_description,
                  variant: AppTextVariant.bodyLarge,
                  color: context.colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xxl),
                if (_videoPath != null)
                  AppCard(
                    variant: AppCardVariant.elevated,
                    child: Row(
                      children: [
                        Icon(Icons.videocam, color: context.colors.gold),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                l10n.kyc_video_preview_videoRecorded,
                                variant: AppTextVariant.labelMedium,
                              ),
                              AppText(
                                '${_recordingDuration}s',
                                variant: AppTextVariant.bodySmall,
                                color: context.colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          AppButton(
            label: l10n.kyc_video_continue,
            onPressed: () => _handleContinue(context),
            isFullWidth: true,
          ),
          SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _retakeVideo,
            child: AppText(
              l10n.kyc_video_retake,
              variant: AppTextVariant.labelMedium,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecordingFlow(BuildContext context) async {
    await _initializeCamera();
    if (_controller == null || !_controller!.value.isInitialized) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera initialization failed')),
      );
      return;
    }

    setState(() {
      _currentStep = VideoStep.recording;
      _currentActionIndex = 0;
    });

    await _startRecording();
  }

  Future<void> _startRecording() async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = path.join(
        directory.path,
        'kyc_video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      await _controller!.startVideoRecording();

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordingDuration++);

        // Auto-advance actions every 3 seconds
        if (_recordingDuration % 3 == 0 && _currentActionIndex < _actions.length - 1) {
          setState(() => _currentActionIndex++);
        }

        // Auto-stop at max duration
        if (_recordingDuration >= maxRecordingSeconds) {
          _stopRecording();
        }
      });

      setState(() => _videoPath = filePath);
    } catch (e) {
      AppLogger('Error starting recording').error('Error starting recording', e);
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      _recordingTimer?.cancel();
      final video = await _controller!.stopVideoRecording();

      setState(() {
        _isRecording = false;
        _videoPath = video.path;
        _currentStep = VideoStep.preview;
      });
    } catch (e) {
      AppLogger('Error stopping recording').error('Error stopping recording', e);
    }
  }

  void _retakeVideo() {
    setState(() {
      _currentStep = VideoStep.instructions;
      _videoPath = null;
      _recordingDuration = 0;
      _currentActionIndex = 0;
    });
    _controller?.dispose();
    _controller = null;
    _generateRandomActions();
  }

  Future<void> _handleContinue(BuildContext context) async {
    if (_videoPath == null) return;

    // Navigate to additional documents or submission
    context.push('/kyc/additional-docs');
  }

  String _getActionLabel(AppLocalizations l10n, LivenessAction action) {
    switch (action) {
      case LivenessAction.lookStraight:
        return l10n.kyc_video_action_lookStraight;
      case LivenessAction.turnLeft:
        return l10n.kyc_video_action_turnLeft;
      case LivenessAction.turnRight:
        return l10n.kyc_video_action_turnRight;
      case LivenessAction.smile:
        return l10n.kyc_video_action_smile;
      case LivenessAction.blink:
        return l10n.kyc_video_action_blink;
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
