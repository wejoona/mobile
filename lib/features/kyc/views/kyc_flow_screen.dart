import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_submission_provider.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/theme/spacing.dart';

/// Multi-step KYC flow screen.
class KycFlowScreen extends ConsumerStatefulWidget {
  const KycFlowScreen({super.key});

  @override
  ConsumerState<KycFlowScreen> createState() => _KycFlowScreenState();
}

class _KycFlowScreenState extends ConsumerState<KycFlowScreen> {
  final _picker = ImagePicker();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kycSubmissionProvider);
    final notifier = ref.read(kycSubmissionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.kycVerification),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (state.currentStep.index + 1) / KycStep.values.length,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildStep(state, notifier),
      ),
    );
  }

  Widget _buildStep(KycSubmissionState state, KycSubmissionNotifier notifier) {
    switch (state.currentStep) {
      case KycStep.personalInfo:
        return _PersonalInfoStep(
          firstNameController: _firstNameController,
          lastNameController: _lastNameController,
          dobController: _dobController,
          addressController: _addressController,
          onNext: () {
            notifier.setPersonalInfo({
              'firstName': _firstNameController.text,
              'lastName': _lastNameController.text,
              'dateOfBirth': _dobController.text,
              'address': _addressController.text,
            });
            notifier.nextStep();
          },
        );
      case KycStep.documentType:
        return _DocumentTypeStep(onNext: () => notifier.nextStep());
      case KycStep.documentCapture:
        return _DocumentCaptureStep(
          idFront: state.idFront,
          idBack: state.idBack,
          onCaptureFront: () async {
            final img = await _picker.pickImage(source: ImageSource.camera);
            if (img != null) notifier.setIdFront(File(img.path));
          },
          onCaptureBack: () async {
            final img = await _picker.pickImage(source: ImageSource.camera);
            if (img != null) notifier.setIdBack(File(img.path));
          },
          onNext: () => notifier.nextStep(),
        );
      case KycStep.selfie:
        return _SelfieStep(
          selfie: state.selfie,
          onCapture: () async {
            final img = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
            if (img != null) notifier.setSelfie(File(img.path));
          },
          onNext: () => notifier.nextStep(),
        );
      case KycStep.review:
        return _ReviewStep(
          state: state,
          isLoading: state.isLoading,
          error: state.error,
          onSubmit: () => notifier.submit(),
        );
      case KycStep.submitted:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSpacing.md),
              Text('Documents soumis', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              const Text('Votre verification sera traitee sous 24-48h.'),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.done)),
            ],
          ),
        );
    }
  }
}

class _PersonalInfoStep extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController dobController;
  final TextEditingController addressController;
  final VoidCallback onNext;

  const _PersonalInfoStep({required this.firstNameController, required this.lastNameController, required this.dobController, required this.addressController, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Prenom')),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Nom')),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: dobController, decoration: const InputDecoration(labelText: 'Date de naissance', hintText: 'JJ/MM/AAAA')),
          const SizedBox(height: AppSpacing.md),
          TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Adresse')),
          const Spacer(),
          FilledButton(onPressed: onNext, child: Text(AppStrings.next)),
        ],
      ),
    );
  }
}

class _DocumentTypeStep extends StatelessWidget {
  final VoidCallback onNext;
  const _DocumentTypeStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Type de document', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          ...[
            ('Carte nationale d\'identite', Icons.credit_card),
            ('Passeport', Icons.flight),
            ('Permis de conduire', Icons.directions_car),
          ].map((doc) => ListTile(
            leading: Icon(doc.$2),
            title: Text(doc.$1),
            trailing: const Icon(Icons.chevron_right),
            onTap: onNext,
          )),
        ],
      ),
    );
  }
}

class _DocumentCaptureStep extends StatelessWidget {
  final File? idFront;
  final File? idBack;
  final VoidCallback onCaptureFront;
  final VoidCallback onCaptureBack;
  final VoidCallback onNext;

  const _DocumentCaptureStep({this.idFront, this.idBack, required this.onCaptureFront, required this.onCaptureBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CaptureButton(label: 'Recto du document', file: idFront, onCapture: onCaptureFront),
          const SizedBox(height: AppSpacing.md),
          _CaptureButton(label: 'Verso du document', file: idBack, onCapture: onCaptureBack),
          const Spacer(),
          FilledButton(onPressed: idFront != null ? onNext : null, child: Text(AppStrings.next)),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onCapture;

  const _CaptureButton({required this.label, this.file, required this.onCapture});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCapture,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: file != null ? Theme.of(context).colorScheme.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: file != null
            ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file!, fit: BoxFit.cover, width: double.infinity))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey),
                  const SizedBox(height: AppSpacing.sm),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
      ),
    );
  }
}

class _SelfieStep extends StatelessWidget {
  final File? selfie;
  final VoidCallback onCapture;
  final VoidCallback onNext;

  const _SelfieStep({this.selfie, required this.onCapture, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Prenez un selfie', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (selfie != null)
            ClipOval(child: Image.file(selfie!, width: 200, height: 200, fit: BoxFit.cover))
          else
            GestureDetector(
              onTap: onCapture,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade300, width: 2)),
                child: const Icon(Icons.face, size: 80, color: Colors.grey),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          if (selfie != null) TextButton(onPressed: onCapture, child: const Text('Reprendre')),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: selfie != null ? onNext : null, child: Text(AppStrings.next)),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final KycSubmissionState state;
  final bool isLoading;
  final String? error;
  final VoidCallback onSubmit;

  const _ReviewStep({required this.state, required this.isLoading, this.error, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Verification', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          _ReviewItem(label: 'Prenom', value: state.personalInfo['firstName'] ?? '-'),
          _ReviewItem(label: 'Nom', value: state.personalInfo['lastName'] ?? '-'),
          _ReviewItem(label: 'Date de naissance', value: state.personalInfo['dateOfBirth'] ?? '-'),
          _ReviewItem(label: 'Document recto', value: state.idFront != null ? 'Capture' : 'Manquant'),
          _ReviewItem(label: 'Selfie', value: state.selfie != null ? 'Capture' : 'Manquant'),
          const Spacer(),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          FilledButton(
            onPressed: !isLoading ? onSubmit : null,
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Soumettre'),
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
