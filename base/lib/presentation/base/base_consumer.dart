
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseConsumer<U extends BaseProvider> extends ConsumerStatefulWidget {
  final Widget Function(BuildContext, U, WidgetRef) builder;
  final Function(BuildContext)? didChangeDependencies;
  final Function(BuildContext, U, WidgetRef)? initState;
  final Function(BuildContext)? dispose;
  final ProviderListenable<U> provider;

  const BaseConsumer({
    Key? key,
    required this.builder,
    required this.provider,
    this.initState,
    this.didChangeDependencies,
    this.dispose,
  }) : super(key: key);

  @override
  ConsumerState<BaseConsumer<U>> createState() => _BaseConsumerState();
}

class _BaseConsumerState<U extends BaseProvider>
    extends ConsumerState<BaseConsumer<U>> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (widget.initState != null) {
        final provider = ref.read(widget.provider);
        widget.initState!(context, provider, ref);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      if (widget.didChangeDependencies != null) {
        widget.didChangeDependencies!(context);
      }
    });
  }

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose!(context);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(widget.provider);
    return widget.builder(context, provider, ref);
  }
}
