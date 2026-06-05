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
  var _fontScale = 1.0;
  var _reduceMotionEnabled = false;
  var _largeTouchTargetsEnabled = true;
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
          _SettingsCard(
            title: 'Dados do ateli\u00ea',
            icon: Icons.storefront_rounded,
            children: [
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
          const SizedBox(height: AppSpacing.md),
          _SettingsCard(
            title: 'Acessibilidade',
            icon: Icons.visibility_rounded,
            children: [
              Text(
                'Tamanho da fonte',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _fontScaleLabel,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Slider(
                value: _fontScale,
                min: 0.9,
                max: 1.35,
                divisions: 6,
                label: _fontScaleLabel,
                onChanged: (value) {
                  setState(() => _fontScale = value);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                value: _highContrastEnabled,
                onChanged: (value) {
                  setState(() => _highContrastEnabled = value);
                },
                title: const Text('Preferir alto contraste'),
                subtitle: const Text(
                  'Refor\u00e7a bordas, foco e contraste dos campos.',
                ),
              ),
              SwitchListTile(
                value: _reduceMotionEnabled,
                onChanged: (value) {
                  setState(() => _reduceMotionEnabled = value);
                },
                title: const Text('Reduzir anima\u00e7\u00f5es'),
                subtitle: const Text(
                  'Diminui movimentos para uma leitura mais tranquila.',
                ),
              ),
              SwitchListTile(
                value: _largeTouchTargetsEnabled,
                onChanged: (value) {
                  setState(() => _largeTouchTargetsEnabled = value);
                },
                title: const Text('Bot\u00f5es maiores'),
                subtitle: const Text(
                  'Aumenta a \u00e1rea de toque das a\u00e7\u00f5es principais.',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsCard(
            title: 'Sincroniza\u00e7\u00e3o',
            icon: Icons.cloud_sync_rounded,
            compact: true,
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
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            onPressed: () async {
              await controller.updateSettings(
                AppSettings(
                  studioName: _studioController.text.trim().isEmpty
                      ? 'VCOS Retalhos'
                      : _studioController.text.trim(),
                  ownerName: _ownerController.text.trim(),
                  phone: _phoneController.text.trim(),
                  autoSyncEnabled: _autoSyncEnabled,
                  highContrastEnabled: _highContrastEnabled,
                  fontScale: _fontScale,
                  reduceMotionEnabled: _reduceMotionEnabled,
                  largeTouchTargetsEnabled: _largeTouchTargetsEnabled,
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
    _fontScale = settings.fontScale;
    _reduceMotionEnabled = settings.reduceMotionEnabled;
    _largeTouchTargetsEnabled = settings.largeTouchTargetsEnabled;
  }

  String get _fontScaleLabel {
    final percent = (_fontScale * 100).round();
    if (_fontScale >= 1.25) return 'Muito grande ($percent%)';
    if (_fontScale >= 1.1) return 'Grande ($percent%)';
    if (_fontScale < 1) return 'Compacta ($percent%)';
    return 'Padr\u00e3o ($percent%)';
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.children,
    this.compact = false,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 32),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.lg),
            ...children,
          ],
        ),
      ),
    );
  }
}
