
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseStatelessConsumer<U extends BaseProvider> extends ConsumerWidget {
  final Widget Function(BuildContext, U, WidgetRef) builder;
  final ProviderListenable<U> provider;

  const BaseStatelessConsumer({
    Key? key,
    required this.builder,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(this.provider);
    return builder(context, provider, ref);
  }
}