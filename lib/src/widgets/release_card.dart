import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fwupd/fwupd.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../fwupd_x.dart';
import 'dialogs.dart';

class ReleaseCard extends StatelessWidget {
  const ReleaseCard({
    super.key,
    required this.release,
    required this.device,
    this.onInstall,
  });

  final FwupdRelease release;
  final FwupdDevice device;
  final VoidCallback? onInstall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final String action;
    final String dialogText;
    final dialogDesc = device.flags.contains(FwupdDeviceFlag.usableDuringUpdate)
        ? null
        : l10n.deviceUnavailable;

    if (release.isDowngrade) {
      action = l10n.downgrade;
      dialogText = l10n.downgradeConfirm(
        device.name,
        release.version,
      );
    } else if (release.isUpgrade) {
      action = l10n.update;
      dialogText = l10n.updateConfirm(
        device.name,
        release.version,
      );
    } else {
      action = l10n.reinstall;
      dialogText = l10n.reinstallConfirm(
        device.name,
        device.version,
      );
    }
    void confirmAndInstall() {
      showConfirmationDialog(
        context,
        title: dialogText,
        message: dialogDesc,
        actionText: action,
        onConfirm: onInstall,
        onCancel: () {},
        icon: YaruIcons.sync,
      );
    }

    return YaruSection(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      headlinePadding: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      headline: Row(
        children: [
          Badge(
            isLabelVisible: release.isUpgrade,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Text(
                release.version,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          Visibility(
            visible: release.version == device.version,
            child: Chip(
              label: Text(l10n.currentVersion),
              labelStyle: Theme.of(context).textTheme.bodySmall,
              labelPadding: EdgeInsets.zero,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: confirmAndInstall,
            child: Text(
              release.isUpgrade
                  ? l10n.update
                  : release.isDowngrade
                      ? l10n.downgrade
                      : l10n.reinstall,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Html(
            data: '${release.summary}${release.description}',
            style: {
              'body': Style(margin: Margins.zero),
              'h3': Style(margin: Margins.zero)
            },
            shrinkWrap: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
