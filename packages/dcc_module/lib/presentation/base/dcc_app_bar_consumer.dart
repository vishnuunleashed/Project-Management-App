import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DccConsumerAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final PreferredSizeWidget Function(BuildContext context, WidgetRef ref) builder;

  const DccConsumerAppBar({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return builder(context, ref);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
