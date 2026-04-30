import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/core/theme/theme_context.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_controller.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_state.dart';

class AudioDevicesPage extends StatefulWidget {
  const AudioDevicesPage({super.key});

  @override
  State<AudioDevicesPage> createState() => _AudioDevicesPageState();
}

class _AudioDevicesPageState extends State<AudioDevicesPage> {
  late final AudioBrowserController _controller;

  @override
  void initState() {
    super.initState();
    _controller = serviceLocator<AudioBrowserController>();

    if (_controller.value.devicesStatus == AudioLoadStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadDevices();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final layout = context.appLayoutTokens;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(layout.radiusXl),
      ),
      padding: EdgeInsets.all(layout.spacing2xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dispositivos de audio',
            style: context.textTheme.headlineSmall,
          ),
          SizedBox(height: layout.spacingMd),
          Text(
            'Selecione um dispositivo para carregar as sessoes de audio correspondentes.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: layout.spacingXl),
          Expanded(
            child: ValueListenableBuilder<AudioBrowserState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                if (state.devicesStatus == AudioLoadStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.devicesStatus == AudioLoadStatus.error) {
                  return Center(
                    child: Text(state.errorMessage ?? 'Falha ao carregar dispositivos.'),
                  );
                }

                if (state.devices.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum dispositivo encontrado.',
                      style: context.textTheme.titleMedium,
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: state.devices.length,
                  separatorBuilder: (_, _) => SizedBox(height: layout.spacingMd),
                  itemBuilder: (context, index) {
                    final device = state.devices[index];
                    final isSelected = state.selectedDeviceId == device.id;

                    return Card(
                      color: isSelected ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                      child: ListTile(
                        title: Text(device.name),
                        subtitle: Text(device.id),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: scheme.primary)
                            : null,
                        onTap: () => _controller.selectDevice(device.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
