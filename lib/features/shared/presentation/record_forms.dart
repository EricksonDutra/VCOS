import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/data/date_formatting.dart';
import '../../../core/data/money.dart';
import '../../../core/models/expense.dart';
import '../../../core/models/sale.dart';
import '../../../core/state/vcos_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

Future<void> showSaleDialog(BuildContext context, {Sale? sale}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _SaleDialog(sale: sale),
  );
}

Future<void> showExpenseDialog(BuildContext context, {Expense? expense}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ExpenseDialog(expense: expense),
  );
}

class _SaleDialog extends StatefulWidget {
  const _SaleDialog({this.sale});

  final Sale? sale;

  @override
  State<_SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<_SaleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _customerController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final sale = widget.sale;
    _selectedDate = dateOnly(sale?.createdAt ?? DateTime.now());
    if (sale == null) return;
    _descriptionController.text = sale.description;
    _customerController.text = sale.customerName;
    _amountController.text =
        sale.amount.toStringAsFixed(2).replaceAll('.', ',');
    _notesController.text = sale.notes;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _customerController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RecordDialogFrame(
      title: widget.sale == null ? 'Nova venda' : 'Editar venda',
      formKey: _formKey,
      submitLabel: widget.sale == null ? 'Salvar venda' : 'Atualizar venda',
      onSubmit: () async {
        if (!_formKey.currentState!.validate()) return;
        final controller = context.read<VcosController>();
        final sale = widget.sale;
        if (sale == null) {
          await controller.addSale(
            description: _descriptionController.text,
            customerName: _customerController.text,
            amount: parseMoney(_amountController.text),
            date: _selectedDate,
            notes: _notesController.text,
          );
        } else {
          await controller.updateSale(
            sale: sale,
            description: _descriptionController.text,
            customerName: _customerController.text,
            amount: parseMoney(_amountController.text),
            date: _selectedDate,
            notes: _notesController.text,
          );
        }
        if (context.mounted) Navigator.of(context).pop();
      },
      children: [
        _DateField(
          label: 'Data da venda',
          value: _selectedDate,
          onChanged: (date) => setState(() => _selectedDate = date),
        ),
        _SuggestionTextField(
          controller: _descriptionController,
          suggestionField: 'sale_description',
          label: 'Produto vendido',
          hint: 'Ex.: Avental patchwork',
        ),
        _SuggestionTextField(
          controller: _customerController,
          suggestionField: 'sale_customer',
          label: 'Cliente',
          hint: 'Nome da cliente',
        ),
        _AccessibleTextField(
          controller: _amountController,
          label: 'Valor',
          hint: 'Ex.: 85,00',
          keyboardType: TextInputType.number,
          validator: _moneyValidator,
        ),
        _AccessibleTextField(
          controller: _notesController,
          label: 'Observacoes',
          hint: 'Opcional',
          required: false,
          maxLines: 3,
        ),
      ],
    );
  }
}

class _ExpenseDialog extends StatefulWidget {
  const _ExpenseDialog({this.expense});

  final Expense? expense;

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  static const _maxExpensePhotos = 10;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(text: 'Materiais');
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _imagePicker = ImagePicker();
  late List<String> _photoPaths;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _selectedDate = dateOnly(expense?.createdAt ?? DateTime.now());
    _photoPaths = [...?expense?.photoPaths];
    if (expense == null) return;
    _descriptionController.text = expense.description;
    _categoryController.text = expense.category;
    _amountController.text =
        expense.amount.toStringAsFixed(2).replaceAll('.', ',');
    _notesController.text = expense.notes;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _categoryController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RecordDialogFrame(
      title: widget.expense == null ? 'Novo gasto' : 'Editar gasto',
      formKey: _formKey,
      submitLabel: widget.expense == null ? 'Salvar gasto' : 'Atualizar gasto',
      onSubmit: () async {
        if (!_formKey.currentState!.validate()) return;
        final controller = context.read<VcosController>();
        final expense = widget.expense;
        if (expense == null) {
          await controller.addExpense(
            description: _descriptionController.text,
            category: _categoryController.text,
            amount: parseMoney(_amountController.text),
            date: _selectedDate,
            notes: _notesController.text,
            photoPaths: _photoPaths,
          );
        } else {
          await controller.updateExpense(
            expense: expense,
            description: _descriptionController.text,
            category: _categoryController.text,
            amount: parseMoney(_amountController.text),
            date: _selectedDate,
            notes: _notesController.text,
            photoPaths: _photoPaths,
          );
        }
        if (context.mounted) Navigator.of(context).pop();
      },
      children: [
        _DateField(
          label: 'Data do gasto',
          value: _selectedDate,
          onChanged: (date) => setState(() => _selectedDate = date),
        ),
        _SuggestionTextField(
          controller: _descriptionController,
          suggestionField: 'expense_description',
          label: 'Material ou despesa',
          hint: 'Ex.: Tecido floral',
        ),
        _SuggestionTextField(
          controller: _categoryController,
          suggestionField: 'expense_category',
          label: 'Categoria',
          hint: 'Ex.: Materiais',
        ),
        _AccessibleTextField(
          controller: _amountController,
          label: 'Valor',
          hint: 'Ex.: 42,50',
          keyboardType: TextInputType.number,
          validator: _moneyValidator,
        ),
        _AccessibleTextField(
          controller: _notesController,
          label: 'Observacoes',
          hint: 'Opcional',
          required: false,
          maxLines: 3,
        ),
        _ExpensePhotoPicker(
          photoPaths: _photoPaths,
          maxPhotos: _maxExpensePhotos,
          onAddPhoto: _takePhoto,
          onRemovePhoto: (path) {
            setState(() => _photoPaths.remove(path));
          },
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    if (_photoPaths.length >= _maxExpensePhotos) return;

    try {
      final pickedPhoto = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 68,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedPhoto == null) return;

      final savedPath = await _persistExpensePhoto(pickedPhoto);
      if (!mounted) return;
      setState(() => _photoPaths = [..._photoPaths, savedPath]);
    } on PlatformException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_cameraErrorMessage(error))),
      );
    }
  }

  Future<String> _persistExpensePhoto(XFile pickedPhoto) async {
    final supportDir = await getApplicationSupportDirectory();
    final photosDir = Directory(p.join(supportDir.path, 'expense_photos'));
    if (!photosDir.existsSync()) {
      await photosDir.create(recursive: true);
    }

    final extension = p.extension(pickedPhoto.path).toLowerCase();
    final safeExtension = extension.isEmpty ? '.jpg' : extension;
    final fileName =
        'expense-${DateTime.now().microsecondsSinceEpoch}$safeExtension';
    final savedFile = File(p.join(photosDir.path, fileName));
    await savedFile.writeAsBytes(await pickedPhoto.readAsBytes(), flush: true);
    return savedFile.path;
  }

  String _cameraErrorMessage(PlatformException error) {
    if (error.code == 'camera_access_denied' ||
        error.code == 'camera_access_restricted') {
      return 'Permita o acesso a camera para registrar a foto.';
    }
    return 'Nao foi possivel abrir a camera. Tente novamente.';
  }
}

class _ExpensePhotoPicker extends StatelessWidget {
  const _ExpensePhotoPicker({
    required this.photoPaths,
    required this.maxPhotos,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final List<String> photoPaths;
  final int maxPhotos;
  final VoidCallback onAddPhoto;
  final ValueChanged<String> onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    final canAddPhoto = photoPaths.length < maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Fotos dos produtos comprados',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${photoPaths.length} de $maxPhotos fotos',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: canAddPhoto ? onAddPhoto : null,
          icon: const Icon(Icons.photo_camera_rounded),
          label: Text(canAddPhoto ? 'Tirar foto' : 'Limite de fotos atingido'),
        ),
        if (photoPaths.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: photoPaths.map((path) {
              return _ExpensePhotoThumb(
                path: path,
                onRemove: () => onRemovePhoto(path),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _ExpensePhotoThumb extends StatelessWidget {
  const _ExpensePhotoThumb({
    required this.path,
    required this.onRemove,
  });

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _ExpensePhotoImage(
              path: path,
              width: 104,
              height: 104,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filled(
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded),
              tooltip: 'Remover foto',
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpensePhotoImage extends StatelessWidget {
  const _ExpensePhotoImage({
    required this.path,
    required this.width,
    required this.height,
  });

  final String path;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (_isRemotePhoto(path)) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _BrokenPhoto(
          width: width,
          height: height,
        ),
      );
    }

    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _BrokenPhoto(
        width: width,
        height: height,
      ),
    );
  }
}

class _BrokenPhoto extends StatelessWidget {
  const _BrokenPhoto({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.linen,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_rounded),
    );
  }
}

bool _isRemotePhoto(String path) {
  return path.startsWith('http://') || path.startsWith('https://');
}

class _RecordDialogFrame extends StatelessWidget {
  const _RecordDialogFrame({
    required this.title,
    required this.formKey,
    required this.children,
    required this.submitLabel,
    required this.onSubmit,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final String submitLabel;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.lg),
                ...children.expand(
                  (child) => [child, const SizedBox(height: AppSpacing.md)],
                ),
                ElevatedButton.icon(
                  onPressed: onSubmit,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(submitLabel),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessibleTextField extends StatelessWidget {
  const _AccessibleTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.required = true,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      validator: validator ??
          (value) {
            if (!required) return null;
            if (value == null || value.trim().isEmpty) {
              return 'Preencha este campo.';
            }
            return null;
          },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(dateOnly(picked));
        }
      },
      icon: const Icon(Icons.calendar_month_rounded),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text('$label: ${formatDate(value)}'),
      ),
    );
  }
}

class _SuggestionTextField extends StatefulWidget {
  const _SuggestionTextField({
    required this.controller,
    required this.suggestionField,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String suggestionField;
  final String label;
  final String hint;

  @override
  State<_SuggestionTextField> createState() => _SuggestionTextFieldState();
}

class _SuggestionTextFieldState extends State<_SuggestionTextField> {
  final _focusNode = FocusNode();
  var _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _showSuggestions = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSuggestions = context.select<VcosController, List<String>>(
      (controller) => controller.suggestionsFor(widget.suggestionField),
    );
    final typed = widget.controller.text.trim().toLowerCase();
    final suggestions = allSuggestions
        .where((value) => typed.isEmpty || value.toLowerCase().contains(typed))
        .take(5)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            suffixIcon:
                suggestions.isEmpty ? null : const Icon(Icons.history_rounded),
          ),
          onChanged: (_) {
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Preencha este campo.';
            }
            return null;
          },
        ),
        if (_showSuggestions && suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Card(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: suggestions.map((suggestion) {
                return InkWell(
                  onTap: () {
                    widget.controller.text = suggestion;
                    widget.controller.selection = TextSelection.collapsed(
                      offset: suggestion.length,
                    );
                    _focusNode.unfocus();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

String? _moneyValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Informe o valor.';
  }
  if (parseMoney(value) <= 0) {
    return 'Informe um valor maior que zero.';
  }
  return null;
}
