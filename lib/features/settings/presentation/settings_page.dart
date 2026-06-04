import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/app_settings.dart';
import '../../../core/state/vcos_controller.dart';
import '../../../core/theme/app_spacing.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _studioController = TextEditingController();
  final _ownerController = TextEditingController();
  final _phoneController = TextEditingController();
  var _autoSyncEnabled = true;
  var _highContrastEnabled = false;
  var _loadedSettings = false;

  @override
  void dispose() {
    _studioController.dispose();
    _ownerController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VcosController>();
    if (!_loadedSettings && !controller.isLoading) {
      _applySettings(controller.settings);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ajuste prefer\u00eancias, dados do ateli\u00ea e op\u00e7\u00f5es de acessibilidade.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dados do ateli\u00ea',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: _studioController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do ateli\u00ea',
                      hintText: 'VCOS Retalhos',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _ownerController,
                    decoration: const InputDecoration(
                      labelText: 'Artes\u00e3',
                      hintText: 'Nome da respons\u00e1vel',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                      hintText: '(11) 99999-9999',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _autoSyncEnabled,
                    onChanged: (value) {
                      setState(() => _autoSyncEnabled = value);
                    },
                    title: const Text('Sincronizar automaticamente'),
                    subtitle: const Text(
                      'Quando a API for integrada, o app tentara enviar os dados sozinho.',
                    ),
                  ),
                  SwitchListTile(
                    value: _highContrastEnabled,
                    onChanged: (value) {
                      setState(() => _highContrastEnabled = value);
                    },
                    title: const Text('Preferir alto contraste'),
                    subtitle: const Text(
                      'Mantem textos grandes, bordas fortes e leitura mais limpa.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () async {
              await controller.updateSettings(
                AppSettings(
                  studioName: _studioController.text.trim().isEmpty ? 'VCOS Retalhos' : _studioController.text.trim(),
                  ownerName: _ownerController.text.trim(),
                  phone: _phoneController.text.trim(),
                  autoSyncEnabled: _autoSyncEnabled,
                  highContrastEnabled: _highContrastEnabled,
                  updatedAt: DateTime.now(),
                ),
              );
            },
            icon: const Icon(Icons.save_rounded),
            label: const Text('Salvar configura\u00e7\u00f5es'),
          ),
        ],
      ),
    );
  }

  void _applySettings(AppSettings settings) {
    _loadedSettings = true;
    _studioController.text = settings.studioName;
    _ownerController.text = settings.ownerName;
    _phoneController.text = settings.phone;
    _autoSyncEnabled = settings.autoSyncEnabled;
    _highContrastEnabled = settings.highContrastEnabled;
  }
}
