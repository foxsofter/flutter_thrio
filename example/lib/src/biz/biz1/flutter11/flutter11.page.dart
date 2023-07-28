// Copyright (c) 2023 foxsofter.
//

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thrio/flutter_thrio.dart';
import 'package:permission_handler/permission_handler.dart';

part 'flutter11.context.dart';
part 'flutter11.state.dart';

class Flutter11Page extends NavigatorStatefulPage {
  const Flutter11Page({
    super.key,
    required super.moduleContext,
    required super.settings,
  });

  @override
  _Flutter11PageState createState() => _Flutter11PageState();
}

class _Flutter11PageState extends State<Flutter11Page> {
  @override
  Widget build(final BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('thrio_deeplink_example',
            style: TextStyle(color: Colors.black)),
        leading: context.showPopAwareWidget(const IconButton(
          color: Colors.black,
          tooltip: 'back',
          icon: Icon(Icons.arrow_back_ios),
          onPressed: ThrioNavigator.pop,
        )),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: const PermissionHandlerWidget());
}

class PermissionHandlerWidget extends StatefulWidget {
  const PermissionHandlerWidget({super.key});


  @override
  _PermissionHandlerWidgetState createState() =>
      _PermissionHandlerWidgetState();
}

class _PermissionHandlerWidgetState extends State<PermissionHandlerWidget> {
  @override
  Widget build(final BuildContext context) => Center(
      child: ListView(
          children: Permission.values
              .where((final permission) {
                if (Platform.isIOS) {
                  return permission != Permission.unknown &&
                      permission != Permission.phone &&
                      permission != Permission.sms &&
                      permission != Permission.ignoreBatteryOptimizations &&
                      permission != Permission.accessMediaLocation &&
                      permission != Permission.activityRecognition &&
                      permission != Permission.manageExternalStorage &&
                      permission != Permission.systemAlertWindow &&
                      permission != Permission.requestInstallPackages &&
                      permission != Permission.accessNotificationPolicy &&
                      permission != Permission.bluetoothScan &&
                      permission != Permission.bluetoothAdvertise &&
                      permission != Permission.bluetoothConnect &&
                      permission != Permission.nearbyWifiDevices &&
                      permission != Permission.videos &&
                      permission != Permission.audio &&
                      permission != Permission.scheduleExactAlarm &&
                      permission != Permission.sensorsAlways;
                } else {
                  return permission != Permission.unknown &&
                      permission != Permission.mediaLibrary &&
                      permission != Permission.photosAddOnly &&
                      permission != Permission.reminders &&
                      permission != Permission.bluetooth &&
                      permission != Permission.appTrackingTransparency &&
                      permission != Permission.criticalAlerts;
                }
              })
              .map(PermissionWidget.new)
              .toList()),
    );
}

/// Permission widget containing information about the passed [Permission]
class PermissionWidget extends StatefulWidget {
  /// Constructs a [PermissionWidget] for the supplied [Permission]
  const PermissionWidget(this._permission, {super.key});

  final Permission _permission;

  @override
  _PermissionState createState() => _PermissionState();
}

class _PermissionState extends State<PermissionWidget> {
  _PermissionState();

   Permission get _permission => widget._permission;
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus();
  }

  Future<void> _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Color getPermissionColor() {
    switch (_permissionStatus) {
      case PermissionStatus.denied:
        return Colors.red;
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.limited:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(final BuildContext context) => ListTile(
      title: Text(
        _permission.toString(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        _permissionStatus.toString(),
        style: TextStyle(color: getPermissionColor()),
      ),
      trailing: (_permission is PermissionWithService)
          ? IconButton(
              icon: const Icon(
                Icons.info,
                color: Colors.white,
              ),
              onPressed: () {
                checkServiceStatus(
                    context, _permission as PermissionWithService);
              })
          : null,
      onTap: () {
        requestPermission(_permission);
      },
    );

  Future<void> checkServiceStatus(
      final BuildContext context, final PermissionWithService permission) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((await permission.serviceStatus).toString()),
    ));
  }

  Future<void> requestPermission(final Permission permission) async {
    final status = await permission.request();

    setState(() {
      debugPrint(status.toString());
      _permissionStatus = status;
      debugPrint(_permissionStatus.toString());
    });
  }
}
