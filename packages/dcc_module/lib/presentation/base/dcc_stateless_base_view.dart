import 'package:dcc_module/core/loading_status.dart';
import 'package:dcc_module/core/dcc_base_provider.dart';
import 'package:dcc_module/presentation/widgets/dcc_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DccBaseStatelessView<U extends DccBaseProvider> extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget Function(BuildContext, U, WidgetRef) builder;
  final Widget? drawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final ProviderListenable<U> provider;
  final Future<bool> Function(BuildContext)? onWillPop;

  const DccBaseStatelessView({
    Key? key,
    this.scaffoldKey,
    this.appBar,
    this.floatingActionButton,
    required this.builder,
    required this.provider,
    this.drawer,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.onWillPop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(this.provider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Future.microtask(() async {
          if (!didPop) {
            final shouldPop = onWillPop != null
                ? await onWillPop!(context)
                : await _defaultWillPop(context);
            if (shouldPop && context.mounted) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          }
        });
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Scaffold(
            backgroundColor: backgroundColor,
            key: scaffoldKey,
            resizeToAvoidBottomInset: true,
            floatingActionButtonLocation: floatingActionButtonLocation,
            floatingActionButton: floatingActionButton,
            appBar: appBar,
            drawer: drawer,
            body: SafeArea(
                child: builder(context, provider, ref)
            ),
          ),
          Visibility(
            visible: provider.loadingStatus.loader == DccLoader.loading,
            child: DccBaseLoadingView(
              message: provider.loadingStatus.message,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _defaultWillPop(BuildContext context) {
    return Future.value(true);
  }
}
