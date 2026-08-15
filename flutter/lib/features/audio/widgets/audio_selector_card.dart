import 'package:flutter/material.dart';
import 'package:pc_remote_control/features/audio/models/audio_request.dart';
import 'package:pc_remote_control/features/audio/theme/theme_context.dart';
import 'package:pc_remote_control/features/audio/widgets/audio_panel_card.dart';

class AudioSelectorCard extends StatelessWidget {
  final String title;
  final String description;
  final String fieldLabel;
  final String hintText;
  final String devicesCountLabel;
  final String refreshLabel;
  final String reloadSessionsLabel;
  final List<DeviceSound> devices;
  final String? selectedDeviceId;
  final bool loadingDevices;
  final bool loadingSessions;
  final ValueChanged<String?> onChanged;
  final VoidCallback onRefreshDevices;
  final VoidCallback onRefreshSessions;

  const AudioSelectorCard({
    required this.title,
    required this.description,
    required this.fieldLabel,
    required this.hintText,
    required this.devicesCountLabel,
    required this.refreshLabel,
    required this.reloadSessionsLabel,
    required this.devices,
    required this.selectedDeviceId,
    required this.loadingDevices,
    required this.loadingSessions,
    required this.onChanged,
    required this.onRefreshDevices,
    required this.onRefreshSessions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = context.isCompactLayout;
    final selector = DropdownButtonFormField<String>(
      key: const Key('audio-device-selector'),
      value: selectedDeviceId,
      isExpanded: true,
      decoration: InputDecoration(labelText: fieldLabel),
      hint: Text(hintText),
      items: devices
          .map(
            (device) => DropdownMenuItem<String>(
              value: device.id,
              child: Text(
                device.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: loadingDevices ? null : onChanged,
    );
    final desktopActions = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: loadingDevices ? null : onRefreshDevices,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(refreshLabel),
        ),
        OutlinedButton.icon(
          onPressed: selectedDeviceId == null || loadingSessions
              ? null
              : onRefreshSessions,
          icon: const Icon(Icons.sync_rounded),
          label: Text(reloadSessionsLabel),
        ),
      ],
    );

    return AudioPanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: isCompact ? double.infinity : 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.audioTheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: context.audioTheme.border),
                ),
                child: Text(
                  devicesCountLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: context.audioTheme.mutedText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final inlineActions = !isCompact && constraints.maxWidth >= 620;

              if (!inlineActions) {
                return selector;
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: selector),
                  const SizedBox(width: 12),
                  Flexible(child: desktopActions),
                ],
              );
            },
          ),
          if (loadingDevices || loadingSessions) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 5,
                color: context.audioTheme.accent,
                backgroundColor: context.audioTheme.accentSoft,
              ),
            ),
          ],
          if (isCompact) ...[
            const SizedBox(height: 18),
            desktopActions,
          ] else ...[
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 620) {
                  return const SizedBox.shrink();
                }

                return desktopActions;
              },
            ),
          ],
        ],
      ),
    );
  }
}
