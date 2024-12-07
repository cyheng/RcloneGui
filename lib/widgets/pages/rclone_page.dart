import 'package:alisthelper/i18n/strings.g.dart';
import 'package:alisthelper/model/virtual_disk_state.dart';
import 'package:alisthelper/provider/rclone_provider.dart';
import 'package:alisthelper/provider/settings_provider.dart';
import 'package:alisthelper/widgets/add_new_vdisk.dart';

import 'package:alisthelper/widgets/button_card.dart';
import 'package:alisthelper/widgets/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RclonePage extends ConsumerWidget {
  final SizingInformation sizingInformation;

  const RclonePage({super.key, required this.sizingInformation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final rclone = ref.watch(rcloneProvider);

    return Scaffold(
        appBar: (sizingInformation.isDesktop
            ? null
            : AppBar(
                title: const Text('Rclone',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              )),
        body: settings.rcloneDirectory == ''
            ? Center(
                child: Text(t.settings.rcloneSettings.rcloneDirNotSet,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 18)),
              )
            : Center(
                child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    ListTile(
                        title: Text(t.home.options,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18)),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline_rounded),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                  title: const Text('Q&A'),
                                  content: Text(t.rcloneOperation.help)),
                            );
                          },
                        )),
                    const RcloneMultiButtonCard(),
                    ListTile(
                      title: Text('t.rclone.manageVDisks',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18)),
                      trailing: Wrap(
                        children: [
                          AddNewRcloneDisk(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: (rclone.vdList.isEmpty)
                          ? Center(
                              child: Text('t.rclone.noVDisks',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18)),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: ListView.builder(
                                itemCount: rclone.vdList.length,
                                itemBuilder: (context, index) {
                                  return RcloneVirtualDisk(
                                      vd: rclone.vdList[index]);
                                },
                              ),
                            ),
                    )
                  ],
                ),
              )));
  }
}

class RcloneVirtualDisk extends ConsumerWidget {
  const RcloneVirtualDisk({
    super.key,
    required this.vd,
  });

  final VirtualDiskState vd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rcloneNotifier = ref.read(rcloneProvider.notifier);

    return Card(
        margin: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: ListTile(
            titleAlignment: ListTileTitleAlignment.center,
            leading: Icon(Icons.settings_system_daydream),
            title: Text(vd.name.toUpperCase(),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            subtitle: Text(
              '${vd.mountPoint}:  webdav/${vd.path}',
            ),
            trailing: Wrap(
              children: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    //rcloneNotifier.deleteSpecific(vd);
                    // showDialog to confirm deletion
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('t.rcloneOperation.deleteVdisk(vd.name)'),
                        content: Text('t.rcloneOperation.deleteVdiskConfirm'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('t.cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              rcloneNotifier.deleteSpecific(vd);
                              Navigator.of(context).pop();
                            },
                            child: Text('t.delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: vd.isMounted
                      ? const Icon(Icons.stop)
                      : const Icon(Icons.play_arrow),
                  onPressed: () {
                    rcloneNotifier.toggleMount(vd);
                  },
                ),
              ],
            )));
  }
}
