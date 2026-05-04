
import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BaseStatelessView<U extends BaseProvider> extends ConsumerWidget {
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget Function(BuildContext, U, WidgetRef) builder;
  final Widget? drawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final ProviderListenable<U> provider;
  final Future<bool> Function(BuildContext)? onWillPop;

  const BaseStatelessView({
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
              GoRouter.of(context).pop();
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
            visible: provider.loadingStatus.loader == Loader.loading,
            child: BaseLoadingView(
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