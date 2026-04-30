import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/core/theme/theme_context.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_controller.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_state.dart';

class AudioSessionsPage extends StatefulWidget {
  const AudioSessionsPage({super.key});

  @override
  State<AudioSessionsPage> createState() => _AudioSessionsPageState();
}

class _AudioSessionsPageState extends State<AudioSessionsPage> {
  late final AudioBrowserController _controller;

  @override
  void initState() {
    super.initState();
    _controller = serviceLocator<AudioBrowserController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.bootstrapSessions();
    });
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
            'Sessoes de audio',
            style: context.textTheme.headlineSmall,
          ),
          SizedBox(height: layout.spacingMd),
          Text(
            'Escolha um dispositivo para visualizar as sessoes e seu estado atual.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: layout.spacingXl),
          Expanded(
            child: ValueListenableBuilder<AudioBrowserState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                if (state.devicesStatus == AudioLoadStatus.loading &&
                    state.devices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.devicesStatus == AudioLoadStatus.error &&
                    state.devices.isEmpty) {
                  return Center(
                    child: Text(state.errorMessage ?? 'Falha ao carregar dispositivos.'),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: state.selectedDeviceId,
                      decoration: const InputDecoration(
                        labelText: 'Dispositivo',
                      ),
                      items: state.devices
                          .map(
                            (device) => DropdownMenuItem<String>(
                              value: device.id,
                              child: Text(device.name),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) {
                        if (value != null) {
                          _controller.selectDevice(value);
                        }
                      },
                    ),
                    SizedBox(height: layout.spacingXl),
                    Expanded(
                      child: _buildSessionsBody(context, state, scheme),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsBody(
    BuildContext context,
    AudioBrowserState state,
    ColorScheme scheme,
  ) {
    if (state.selectedDeviceId == null) {
      return Center(
        child: Text(
          'Selecione um dispositivo para carregar as sessoes.',
          style: context.textTheme.titleMedium,
        ),
      );
    }

    if (state.sessionsStatus == AudioLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.sessionsStatus == AudioLoadStatus.error) {
      return Center(
        child: Text(state.errorMessage ?? 'Falha ao carregar sessoes.'),
      );
    }

    if (state.sessions.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma sessao encontrada para o dispositivo selecionado.',
          style: context.textTheme.titleMedium,
        ),
      );
    }

    return ListView.separated(
      itemCount: state.sessions.length,
      separatorBuilder: (_, _) => SizedBox(height: context.appLayoutTokens.spacingMd),
      itemBuilder: (context, index) {
        final session = state.sessions[index];

        return Card(
          color: scheme.surfaceContainerHighest,
          child: ListTile(
            title: Text(session.displayName),
            subtitle: Text(session.id),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${session.volumeLevel.toStringAsFixed(0)}%'),
                Text(session.state.name),
              ],
            ),
          ),
        );
      },
    );
  }
}
