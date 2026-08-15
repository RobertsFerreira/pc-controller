import 'package:flutter/material.dart';
import 'package:pc_remote_control/core/di/service_locator.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_controller.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_state.dart';
import 'package:pc_remote_control/features/audio/theme/theme_context.dart';
import 'package:pc_remote_control/features/audio/widgets/audio_selector_card.dart';
import 'package:pc_remote_control/features/audio/widgets/audio_sessions_panel.dart';
import 'package:pc_remote_control/features/audio/widgets/audio_status_card.dart';
import 'package:pc_remote_control/l10n/l10n_context.dart';

class AudioPage extends StatefulWidget {
  final AudioBrowserController? controller;

  const AudioPage({super.key, this.controller});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  late final AudioBrowserController _controller =
      widget.controller ?? serviceLocator<AudioBrowserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.bootstrapSessions();
    });
  }

  Future<void> _refreshAll() async {
    await _controller.loadDevices();

    final selectedDeviceId = _controller.value.selectedDeviceId;
    if (selectedDeviceId != null) {
      await _controller.selectDevice(selectedDeviceId);
    }
  }

  Future<void> _refreshSelectedSessions() async {
    final selectedDeviceId = _controller.value.selectedDeviceId;
    if (selectedDeviceId == null) return;

    await _controller.selectDevice(selectedDeviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: context.audioTheme.background,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final state = _controller.value;

              return RefreshIndicator(
                onRefresh: _refreshAll,
                color: context.audioTheme.accent,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: context.pagePadding,
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1480),
                            child: _AudioPageContent(
                              state: state,
                              controller: _controller,
                              onRefreshSelectedSessions:
                                  _refreshSelectedSessions,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AudioPageContent extends StatelessWidget {
  final AudioBrowserState state;
  final AudioBrowserController controller;
  final Future<void> Function() onRefreshSelectedSessions;

  const _AudioPageContent({
    required this.state,
    required this.controller,
    required this.onRefreshSelectedSessions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCompact = context.isCompactLayout;

    final selectorSection = _buildSelectorSection(context);
    final sessionsPanel = AudioSessionsPanel(
      status: state.sessionsStatus,
      selectedDeviceId: state.selectedDeviceId,
      sessions: state.sessions,
      title: l10n.audioSessionsTitle,
      description: l10n.audioSessionsDescription,
      liveChipLabel: l10n.audioSessionsLiveChip,
      emptyTitle: l10n.audioSessionsEmptyTitle,
      emptyMessage: l10n.audioSessionsEmptyMessage,
      errorTitle: l10n.audioSessionsErrorTitle,
      errorMessage: l10n.audioSessionsErrorMessage,
      loadingTitle: l10n.audioSessionsLoadingTitle,
      loadingMessage: l10n.audioSessionsLoadingMessage,
      selectPromptTitle: l10n.audioSelectPromptTitle,
      selectPromptMessage: l10n.audioSelectPromptMessage,
      refreshLabel: l10n.audioSelectorReloadSessions,
      errorDetails: state.errorMessage,
      onRetry: () => onRefreshSelectedSessions(),
      activeLabel: l10n.audioSessionActive,
      inactiveLabel: l10n.audioSessionInactive,
      expiredLabel: l10n.audioSessionExpired,
      mutedLabel: l10n.audioSessionMuted,
      unmutedLabel: l10n.audioSessionUnmuted,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        selectorSection,
        SizedBox(height: isCompact ? 16 : 18),
        sessionsPanel,
      ],
    );
  }

  Widget _buildSelectorSection(BuildContext context) {
    final l10n = context.l10n;
    final isInitial = state.devicesStatus == AudioLoadStatus.idle;
    final isLoadingWithoutData =
        (state.devicesStatus == AudioLoadStatus.loading || isInitial) &&
        state.devices.isEmpty;
    final hasDeviceError =
        state.devicesStatus == AudioLoadStatus.error && state.devices.isEmpty;
    final hasNoDevices =
        state.devicesStatus == AudioLoadStatus.success && state.devices.isEmpty;

    if (isLoadingWithoutData) {
      return AudioStatusCard(
        icon: Icons.speaker_group_rounded,
        title: l10n.audioLoadingDevicesTitle,
        message: l10n.audioLoadingDevicesMessage,
        loading: true,
      );
    }

    if (hasDeviceError) {
      final message = state.errorMessage?.isNotEmpty == true
          ? '${l10n.audioDevicesErrorMessage}\n${state.errorMessage}'
          : l10n.audioDevicesErrorMessage;

      return AudioStatusCard(
        icon: Icons.portable_wifi_off_rounded,
        title: l10n.audioDevicesErrorTitle,
        message: message,
        actionLabel: l10n.audioSelectorRefresh,
        onAction: controller.loadDevices,
      );
    }

    if (hasNoDevices) {
      return AudioStatusCard(
        icon: Icons.speaker_notes_off_rounded,
        title: l10n.audioDevicesEmptyTitle,
        message: l10n.audioDevicesEmptyMessage,
        actionLabel: l10n.audioSelectorRefresh,
        onAction: controller.loadDevices,
      );
    }

    return AudioSelectorCard(
      title: l10n.audioSelectorTitle,
      description: l10n.audioSelectorDescription,
      fieldLabel: l10n.audioSelectorFieldLabel,
      hintText: l10n.audioSelectorFieldHint,
      devicesCountLabel: l10n.audioSelectorDevicesCount(state.devices.length),
      refreshLabel: l10n.audioSelectorRefresh,
      reloadSessionsLabel: l10n.audioSelectorReloadSessions,
      devices: state.devices,
      selectedDeviceId: state.selectedDeviceId,
      loadingDevices: state.devicesStatus == AudioLoadStatus.loading,
      loadingSessions: state.sessionsStatus == AudioLoadStatus.loading,
      onChanged: (deviceId) {
        if (deviceId == null || deviceId.isEmpty) return;
        controller.selectDevice(deviceId);
      },
      onRefreshDevices: controller.loadDevices,
      onRefreshSessions: () => onRefreshSelectedSessions(),
    );
  }
}
