import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_text.dart';
import '../../../design/components/primitives/app_input.dart';
import '../../../design/components/primitives/app_select.dart';
import '../services/expenses_service.dart';
import '../providers/expenses_provider.dart';
import '../models/expense.dart';
import '../../../utils/logger.dart';

class CaptureReceiptView extends ConsumerStatefulWidget {
  const CaptureReceiptView({super.key});

  @override
  ConsumerState<CaptureReceiptView> createState() => _CaptureReceiptViewState();
}

class _CaptureReceiptViewState extends ConsumerState<CaptureReceiptView> {
  CameraController? _cameraController;
  final ImagePicker _picker = ImagePicker();

  File? _capturedImage;
  OcrResult? _ocrResult;
  bool _isProcessing = false;
  bool _showEditForm = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      AppLogger('Error initializing camera').error('Error initializing camera', e);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _amountController.dispose();
    _vendorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_showEditForm) {
      return _buildEditForm(context, l10n);
    }

    if (_capturedImage != null) {
      return _buildPreview(context, l10n);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: AppText(
          l10n.expenses_captureReceipt,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_cameraController!),
                _buildCameraOverlay(context, l10n),
              ],
            ),
    );
  }

  Widget _buildCameraOverlay(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              AppText(
                l10n.expenses_positionReceipt,
                style: AppTypography.bodyMedium.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCameraButton(
                    icon: Icons.photo_library,
                    onTap: _pickFromGallery,
                  ),
                  _buildCameraButton(
                    icon: Icons.camera,
                    onTap: _capturePhoto,
                    isPrimary: true,
                  ),
                  const SizedBox(width: 64), // Placeholder for symmetry
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildCameraButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isPrimary ? 72 : 56,
        height: isPrimary ? 72 : 56,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.gold500 : Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
          border: isPrimary
              ? Border.all(color: Colors.white, width: 4)
              : null,
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.black : Colors.white,
          size: isPrimary ? 32 : 24,
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.expenses_receiptPreview,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            _capturedImage = null;
            _ocrResult = null;
            _isProcessing = false;
          }),
        ),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.lg),
                  AppText(
                    l10n.expenses_processingReceipt,
                    style: AppTypography.bodyLarge,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: Image.file(_capturedImage!),
                  ),
                ),
                if (_ocrResult != null) _buildOcrResults(context, l10n),
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      AppButton(
                        label: l10n.expenses_confirmAndEdit,
                        onPressed: _showEditFormWithData,
                      ),
                      SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: l10n.expenses_retake,
                        onPressed: () => setState(() {
                          _capturedImage = null;
                          _ocrResult = null;
                          _isProcessing = false;
                        }),
                        variant: AppButtonVariant.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOcrResults(BuildContext context, AppLocalizations l10n) {
    final currencyFormat = NumberFormat.currency(symbol: 'XOF', decimalDigits: 0);
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      color: AppColors.charcoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.expenses_extractedData,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.md),
          if (_ocrResult!.amount != null)
            _buildOcrItem(
              l10n.expenses_amount,
              currencyFormat.format(_ocrResult!.amount),
            ),
          if (_ocrResult!.date != null)
            _buildOcrItem(
              l10n.expenses_date,
              dateFormat.format(_ocrResult!.date!),
            ),
          if (_ocrResult!.vendor != null)
            _buildOcrItem(
              l10n.expenses_vendor,
              _ocrResult!.vendor!,
            ),
        ],
      ),
    );
  }

  Widget _buildOcrItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 16),
          SizedBox(width: AppSpacing.xs),
          AppText(
            '$label: ',
            style: AppTypography.bodySmall.copyWith(color: AppColors.silver),
          ),
          AppText(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.expenses_confirmDetails,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              if (_capturedImage != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.file(
                    _capturedImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
              ],
              AppSelect(
                label: l10n.expenses_category,
                value: _selectedCategory,
                items: ExpenseCategory.all.map((category) {
                  return AppSelectItem(
                    value: category,
                    label: _getCategoryLabel(l10n, category),
                    icon: _getCategoryIcon(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.expenses_amount,
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefix: const Text('XOF '),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.expenses_errorAmountRequired;
                  }
                  if (double.tryParse(value!) == null) {
                    return l10n.expenses_errorInvalidAmount;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.expenses_vendor,
                controller: _vendorController,
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.expenses_date,
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('MMMM dd, yyyy').format(_selectedDate),
                ),
                suffixIcon: Icons.calendar_today,
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.expenses_description,
                controller: _descriptionController,
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.expenses_saveExpense,
                onPressed: _handleSaveExpense,
                isLoading: _isProcessing,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(image.path);
      });
      await _processReceipt(image.path);
    } catch (e) {
      AppLogger('Error capturing photo').error('Error capturing photo', e);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
        await _processReceipt(image.path);
      }
    } catch (e) {
      AppLogger('Error picking from gallery').error('Error picking from gallery', e);
    }
  }

  Future<void> _processReceipt(String imagePath) async {
    setState(() => _isProcessing = true);

    try {
      final result = await ExpensesService.processReceipt(imagePath);
      setState(() {
        _ocrResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.orange,
          ),
        );
      }
      AppLogger('Error processing receipt').error('Error processing receipt', e);
    }
  }

  void _showEditFormWithData() {
    if (_ocrResult != null) {
      if (_ocrResult!.amount != null) {
        _amountController.text = _ocrResult!.amount!.toStringAsFixed(0);
      }
      if (_ocrResult!.vendor != null) {
        _vendorController.text = _ocrResult!.vendor!;
      }
      if (_ocrResult!.date != null) {
        _selectedDate = _ocrResult!.date!;
      }
    }

    setState(() => _showEditForm = true);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.gold500,
              onPrimary: AppColors.obsidian,
              surface: AppColors.charcoal,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSaveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        currency: 'XOF',
        date: _selectedDate,
        vendor: _vendorController.text.isEmpty ? null : _vendorController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        receiptImagePath: _capturedImage?.path,
        createdAt: DateTime.now(),
      );

      await ref.read(expensesProvider.notifier).addExpense(expense);

      if (mounted) {
        context.go('/expenses');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.expenses_addedSuccessfully,
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Icons.flight;
      case ExpenseCategory.meals:
        return Icons.restaurant;
      case ExpenseCategory.office:
        return Icons.business;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.other:
      default:
        return Icons.more_horiz;
    }
  }

  String _getCategoryLabel(AppLocalizations l10n, String category) {
    switch (category) {
      case ExpenseCategory.travel:
        return l10n.expenses_categoryTravel;
      case ExpenseCategory.meals:
        return l10n.expenses_categoryMeals;
      case ExpenseCategory.office:
        return l10n.expenses_categoryOffice;
      case ExpenseCategory.transport:
        return l10n.expenses_categoryTransport;
      case ExpenseCategory.other:
      default:
        return l10n.expenses_categoryOther;
    }
  }
}
