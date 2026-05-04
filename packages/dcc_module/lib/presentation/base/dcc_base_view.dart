import 'package:dcc_module/core/loading_status.dart';
import 'package:dcc_module/core/dcc_base_provider.dart';
import 'package:dcc_module/presentation/widgets/dcc_loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DccBaseView<U extends DccBaseProvider> extends ConsumerStatefulWidget {
  final PreferredSizeWidget? appBar;
  final Function(U, BuildContext)? onDidChange;
  final Widget? floatingActionButton;
  final Widget Function(BuildContext, U, WidgetRef) builder;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? virtualFloatingActionButton;
  final Widget Function(BuildContext, U, WidgetRef)? bottomNavigationBar;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Function(BuildContext)? didChangeDependencies;
  final Function(BuildContext, U, WidgetRef) initState;
  final Function(BuildContext)? dispose;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final bool isLoaderRequired;
  final bool endDrawerEnableOpenDragGesture;
  final ProviderListenable<U> provider;
  final Future<bool> Function(BuildContext)? onWillPop;
  final Color? bottomSafeAreaColor;
  final void Function(bool)? onEndDrawerChanged;

  const DccBaseView({
    Key? key,
    this.scaffoldKey,
    this.appBar,
    this.onDidChange,
    this.floatingActionButton,
    required this.builder,
    required this.initState,
    required this.provider,
    this.didChangeDependencies,
    this.dispose,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.onWillPop,
    this.resizeToAvoidBottomInset = true,
    this.isLoaderRequired = true,
    this.endDrawerEnableOpenDragGesture = false,
    this.bottomSafeAreaColor,
    this.virtualFloatingActionButton,
    this.endDrawer,
    this.onEndDrawerChanged
  }) : super(key: key);

  @override
  ConsumerState<DccBaseView<U>> createState() => _DccBaseViewState<U>();
}

class _DccBaseViewState<U extends DccBaseProvider> extends ConsumerState<DccBaseView<U>> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final providerInstance = ref.read(widget.provider);
      widget.initState(context, providerInstance, ref);
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
    ref.listen(widget.provider, (previous, next) {
      if (widget.onDidChange != null && previous != next) {
        widget.onDidChange!(next, context);
      }
    });
    final provider = ref.watch(widget.provider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = widget.onWillPop != null
              ? await widget.onWillPop!(context)
              : true; // Default behavior is to allow pop

          if (shouldPop && context.mounted) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: Consumer(
        builder: (context, ref, child) => Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                systemStatusBarContrastEnforced: true,
                statusBarColor: Colors.black,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.light,
              ),
              child: Scaffold(
                backgroundColor: widget.backgroundColor,
                key: widget.scaffoldKey,
                onEndDrawerChanged: widget.onEndDrawerChanged,
                endDrawerEnableOpenDragGesture: widget.endDrawerEnableOpenDragGesture,
                resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                floatingActionButtonLocation: widget.floatingActionButtonLocation,
                floatingActionButton: widget.floatingActionButton,
                appBar: widget.appBar,
                drawer: widget.drawer,
                endDrawer: widget.endDrawer,
                bottomNavigationBar: widget.bottomNavigationBar != null ? widget.bottomNavigationBar!(context, provider, ref) : null,
                body: SafeArea(child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    widget.builder(context, provider, ref),
                    widget.virtualFloatingActionButton == null
                        ? const SizedBox(height: 1)
                        : Positioned(
                            bottom: 42,
                            right: 26,
                            child: widget.virtualFloatingActionButton!)
                  ],
                )),
              ),
            ),
            Visibility(
              visible: widget.isLoaderRequired && provider.loadingStatus.loader == DccLoader.loading,
              child: DccBaseLoadingView(
                message: provider.loadingStatus.message,
                progress: provider.loadingProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
