/*------------------------------------------------------------------------------
AUTHOR		    : Karan Sreyas
CREATED DATE	: 08/08/2025
PURPOSE		    : Settings Provider
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/provider/settings/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSetting extends StatelessWidget {
  final SettingsProvider value;
  const NotificationSetting({super.key,required this.value});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: themeData.cardColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
                color: Theme.of(context).disabledColor)
        ),
        child: ListTile(
          leading: Icon(
            CupertinoIcons.bell,
            color: Theme.of(context).textTheme.labelMedium?.color,),
          title: Text("Notification Settings",style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).textTheme.labelMedium?.color,
          ),),
          onTap: () async {
            final container = ProviderScope.containerOf(context);
            SettingsProvider provider = container.read(settingsProvider);
            await provider.platform.invokeMethod('openNotificationSettings');
          },
          trailing: Icon(
            Icons.chevron_right_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
    );
  }
}
