import 'package:flutter/material.dart';
import 'package:pc_remote_control/features/audio/models/audio_session.dart';
import 'package:pc_remote_control/features/audio/state/audio_browser_state.dart';
import 'package:pc_remote_control/features/audio/theme/theme_context.dart';
import 'package:pc_remote_control/features/audio/widgets/audio_panel_card.dart';
import 'package:pc_remote_control/features/audio/widgets/audio_session_card.dart';
import 'package:pc_remote_control/features/audio/widgets/audio_status_card.dart';

class AudioSessionsPanel extends StatelessWidget {
  final AudioLoadStatus status;
  final String? selectedDeviceId;
  final List<AudioSession> sessions;
  final String title;
  final String description;
  final String liveChipLabel;
  final String emptyTitle;
  final String emptyMessage;
  final String errorTitle;
  final String errorMessage;
  final String loadingTitle;
  final String loadingMessage;
  final String selectPromptTitle;
  final String selectPromptMessage;
  final String refreshLabel;
  final String? errorDetails;
  final VoidCallback onRetry;
  final String activeLabel;
  final String inactiveLabel;
  final String expiredLabel;
  final String mutedLabel;
  final String unmutedLabel;

  const AudioSessionsPanel({
    required this.status,
    required this.selectedDeviceId,
    required this.sessions,
    required this.title,
    required this.description,
    required this.liveChipLabel,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.errorTitle,
    required this.errorMessage,
    required this.loadingTitle,
    required this.loadingMessage,
    required this.selectPromptTitle,
    required this.selectPromptMessage,
    required this.refreshLabel,
    required this.errorDetails,
    required this.onRetry,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.expiredLabel,
    required this.mutedLabel,
    required this.unmutedLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;

        return AudioPanelCard(
          backgroundColor: context.audioTheme.surfaceRaised,
          emphasize: false,
          padding: EdgeInsets.all(isCompact ? 20 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PanelHeadline(
                title: title,
                description: description,
                liveChipLabel: liveChipLabel,
              ),
              const SizedBox(height: 20),
              Container(
                height: 1,
                width: double.infinity,
                color: context.audioTheme.border.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: context.motionDuration,
                child: _buildBody(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (selectedDeviceId == null) {
      return _buildFullWidthBody(
        child: AudioStatusCard(
          key: const ValueKey('sessions-prompt'),
          icon: Icons.touch_app_rounded,
          title: selectPromptTitle,
          message: selectPromptMessage,
        ),
      );
    }

    if (status == AudioLoadStatus.loading) {
      return _buildFullWidthBody(
        child: AudioStatusCard(
          key: const ValueKey('sessions-loading'),
          icon: Icons.sync_rounded,
          title: loadingTitle,
          message: loadingMessage,
          loading: true,
        ),
      );
    }

    if (status == AudioLoadStatus.error) {
      final message = errorDetails?.isNotEmpty == true
          ? '$errorMessage\n$errorDetails'
          : errorMessage;

      return _buildFullWidthBody(
        child: AudioStatusCard(
          key: const ValueKey('sessions-error'),
          icon: Icons.error_outline_rounded,
          title: errorTitle,
          message: message,
          actionLabel: refreshLabel,
          onAction: onRetry,
        ),
      );
    }

    if (sessions.isEmpty) {
      return _buildFullWidthBody(
        child: AudioStatusCard(
          key: const ValueKey('sessions-empty'),
          icon: Icons.multitrack_audio_rounded,
          title: emptyTitle,
          message: emptyMessage,
        ),
      );
    }

    return Column(
      key: const ValueKey('sessions-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < sessions.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          AudioSessionCard(
            session: sessions[index],
            activeLabel: activeLabel,
            inactiveLabel: inactiveLabel,
            expiredLabel: expiredLabel,
            mutedLabel: mutedLabel,
            unmutedLabel: unmutedLabel,
          ),
        ],
      ],
    );
  }

  Widget _buildFullWidthBody({required Widget child}) {
    return SizedBox(
      width: double.infinity,
      child: child,
    );
  }
}

class _PanelHeadline extends StatelessWidget {
  final String title;
  final String description;
  final String liveChipLabel;

  const _PanelHeadline({
    required this.title,
    required this.description,
    required this.liveChipLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: context.audioTheme.signal,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              liveChipLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: context.audioTheme.mutedText,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: 8),
        Text(description, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
