
import 'dart:async';
import 'package:base/core/loader_value.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _singleLineVerticalPadding = 14.0;
const Duration _snackBarTransitionDuration = Duration(milliseconds: 250);
const Duration _snackBarDisplayDuration = Duration(milliseconds: 4000);
const Curve _snackBarHeightCurve = Curves.fastOutSlowIn;
const Curve _snackBarM3HeightCurve = Curves.easeInOutQuart;

const Curve _snackBarFadeInCurve = Interval(0.4, 1.0);
const Curve _snackBarM3FadeInCurve =
    Interval(0.4, 0.6, curve: Curves.easeInCirc);
const Curve _snackBarFadeOutCurve =
    Interval(0.72, 1.0, curve: Curves.fastOutSlowIn);

class CustomSnackBar<U extends BaseProvider> extends ConsumerStatefulWidget {
  CustomSnackBar({
    super.key,
    required this.content,
    this.backgroundColor,
    this.elevation,
    this.margin,
    this.padding,
    this.width,
    this.shape,
    this.behavior,
    this.action,
    this.actionOverflowThreshold,
    this.showCloseIcon,
    this.closeIconColor,
    this.duration = _snackBarDisplayDuration,
    this.onVisible,
    this.dismissDirection = DismissDirection.down,
    this.clipBehavior = Clip.hardEdge,
    required this.provider
  })  : assert(elevation == null || elevation >= 0.0),
        assert(
          width == null || margin == null,
          'Width and margin can not be used together',
        ),
        assert(
            actionOverflowThreshold == null ||
                (actionOverflowThreshold >= 0 && actionOverflowThreshold <= 1),
            'Action overflow threshold must be between 0 and 1 inclusive');

  final Widget content;

  final Color? backgroundColor;

  final double? elevation;

  final EdgeInsetsGeometry? margin;

  final EdgeInsetsGeometry? padding;

  final double? width;

  final ShapeBorder? shape;

  final SnackBarBehavior? behavior;

  final SnackBarAction? action;

  final double? actionOverflowThreshold;

  final bool? showCloseIcon;

  final Color? closeIconColor;

  final Duration duration;

  final VoidCallback? onVisible;

  final DismissDirection dismissDirection;

  final Clip clipBehavior;

  final ProviderListenable<U> provider;

  static AnimationController createAnimationController(
      {required TickerProvider vsync}) {
    return AnimationController(
      duration: _snackBarTransitionDuration,
      debugLabel: 'SnackBar',
      vsync: vsync,
    );
  }


  CustomSnackBar withAnimation(Animation<double> newAnimation,
      {Key? fallbackKey}) {
    return CustomSnackBar(
      key: key ?? fallbackKey,
      content: content,
      backgroundColor: backgroundColor,
      elevation: elevation,
      margin: margin,
      padding: padding,
      width: width,
      shape: shape,
      behavior: behavior,
      action: action,
      actionOverflowThreshold: actionOverflowThreshold,
      showCloseIcon: showCloseIcon,
      closeIconColor: closeIconColor,
      duration: duration,
      onVisible: onVisible,
      dismissDirection: dismissDirection,
      clipBehavior: clipBehavior,
      provider: provider,
    );
  }

  @override
  ConsumerState<CustomSnackBar<U>> createState() => _CustomSnackBarState<U>();
}

class _CustomSnackBarState<U extends BaseProvider> extends ConsumerState<CustomSnackBar<U>>
    with SingleTickerProviderStateMixin {
  bool _wasVisible = false;
  late AnimationController _snackBarController;
  late Animation<double>? animation;

  @override
  void initState() {
    _snackBarController = AnimationController(
      duration: _snackBarTransitionDuration,
      debugLabel: 'SnackBar',
      vsync: this,
    );
    super.initState();
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_snackBarController);
    Future.microtask(() async {
      _snackBarController.forward();
      await Future.delayed(widget.duration);
      _snackBarController.reverse();
      Future.microtask(() {
        final providerInstance = ref.read(widget.provider);
        providerInstance.changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.init,message: "",exception: UnNamedMessage("")));
      });

    });

  }

  @override
  void dispose() {
    _snackBarController.dispose();
    // TODO: implement dispose
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final bool accessibleNavigation =
        MediaQuery.accessibleNavigationOf(context);
    assert(animation != null);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final SnackBarThemeData snackBarTheme = theme.snackBarTheme;
    final bool isThemeDark = theme.brightness == Brightness.dark;
    final Color buttonColor =
        isThemeDark ? colorScheme.primary : colorScheme.secondary;
    final SnackBarThemeData defaults = theme.useMaterial3
        ? _SnackbarDefaultsM3(context)
        : _SnackbarDefaultsM2(context);

    // SnackBar uses a theme that is the opposite brightness from
    // the surrounding theme.
    final Brightness brightness =
        isThemeDark ? Brightness.light : Brightness.dark;

    // Invert the theme values for Material 2. Material 3 values are tokenized to pre-inverted values.
    final ThemeData effectiveTheme = theme.useMaterial3
        ? theme
        : theme.copyWith(
            colorScheme: ColorScheme(
              primary: colorScheme.onPrimary,
              primaryContainer: colorScheme.onPrimary,
              secondary: buttonColor,
              secondaryContainer: colorScheme.onSecondary,
              surface: colorScheme.onSurface,
              background: defaults.backgroundColor!,
              error: colorScheme.onError,
              onPrimary: colorScheme.primary,
              onSecondary: colorScheme.secondary,
              onSurface: colorScheme.surface,
              onBackground: colorScheme.background,
              onError: colorScheme.error,
              brightness: brightness,
            ),
          );

    final TextStyle? contentTextStyle =
        snackBarTheme.contentTextStyle ?? defaults.contentTextStyle;
    final SnackBarBehavior snackBarBehavior =
        widget.behavior ?? snackBarTheme.behavior ?? defaults.behavior!;
    final double? width = widget.width ?? snackBarTheme.width;
    assert(() {
      // Whether the behavior is set through the constructor or the theme,
      // assert that our other properties are configured properly.
      if (snackBarBehavior != SnackBarBehavior.floating) {
        String message(String parameter) {
          final String prefix =
              '$parameter can only be used with floating behavior.';
          if (widget.behavior != null) {
            return '$prefix SnackBarBehavior.fixed was set in the SnackBar constructor.';
          } else if (snackBarTheme.behavior != null) {
            return '$prefix SnackBarBehavior.fixed was set by the inherited SnackBarThemeData.';
          } else {
            return '$prefix SnackBarBehavior.fixed was set by default.';
          }
        }

        assert(widget.margin == null, message('Margin'));
        assert(width == null, message('Width'));
      }
      return true;
    }());

    final bool showCloseIcon = widget.showCloseIcon ??
        snackBarTheme.showCloseIcon ??
        defaults.showCloseIcon!;

    final bool isFloatingSnackBar =
        snackBarBehavior == SnackBarBehavior.floating;
    final double horizontalPadding = isFloatingSnackBar ? 16.0 : 24.0;
    final EdgeInsetsGeometry padding = widget.padding ??
        EdgeInsetsDirectional.only(
            start: horizontalPadding,
            end:
                widget.action != null || showCloseIcon ? 0 : horizontalPadding);

    final double actionHorizontalMargin =
        (widget.padding?.resolve(TextDirection.ltr).right ??
                horizontalPadding) /
            2;
    final double iconHorizontalMargin =
        (widget.padding?.resolve(TextDirection.ltr).right ??
                horizontalPadding) /
            12.0;

    final CurvedAnimation heightAnimation =
        CurvedAnimation(parent: animation!, curve: _snackBarHeightCurve);
    final CurvedAnimation fadeInAnimation =
        CurvedAnimation(parent: animation!, curve: _snackBarFadeInCurve);
    final CurvedAnimation fadeInM3Animation =
        CurvedAnimation(parent: animation!, curve: _snackBarM3FadeInCurve);

    final CurvedAnimation fadeOutAnimation = CurvedAnimation(
      parent: animation!,
      curve: _snackBarFadeOutCurve,
      reverseCurve: const Threshold(0.0),
    );
    // Material 3 Animation has a height animation on entry, but a direct fade out on exit.
    final CurvedAnimation heightM3Animation = CurvedAnimation(
      parent: animation!,
      curve: _snackBarM3HeightCurve,
      reverseCurve: const Threshold(0.0),
    );

    final IconButton? iconButton = showCloseIcon
        ? IconButton(
            icon: const Icon(Icons.close),
            iconSize: 24.0,
            color: widget.closeIconColor ??
                snackBarTheme.closeIconColor ??
                defaults.closeIconColor,
            onPressed: () => ScaffoldMessenger.of(context)
                .hideCurrentSnackBar(reason: SnackBarClosedReason.dismiss),
          )
        : null;

    // Calculate combined width of Action, Icon, and their padding, if they are present.
    final TextPainter actionTextPainter = TextPainter(
        text: TextSpan(
          text: widget.action?.label ?? '',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout();
    final double actionAndIconWidth = actionTextPainter.size.width +
        (widget.action != null ? actionHorizontalMargin : 0) +
        (showCloseIcon
            ? (iconButton?.iconSize ?? 0 + iconHorizontalMargin)
            : 0);

    final EdgeInsets margin = widget.margin?.resolve(TextDirection.ltr) ??
        snackBarTheme.insetPadding ??
        defaults.insetPadding!;

    final double snackBarWidth = widget.width ??
        MediaQuery.sizeOf(context).width - (margin.left + margin.right);
    final double actionOverflowThreshold = widget.actionOverflowThreshold ??
        snackBarTheme.actionOverflowThreshold ??
        defaults.actionOverflowThreshold!;

    final bool willOverflowAction =
        actionAndIconWidth / snackBarWidth > actionOverflowThreshold;

    final List<Widget> maybeActionAndIcon = <Widget>[
      if (widget.action != null)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: actionHorizontalMargin),
          child: TextButtonTheme(
            data: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: buttonColor,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              ),
            ),
            child: widget.action!,
          ),
        ),
      if (showCloseIcon)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: iconHorizontalMargin),
          child: iconButton,
        ),
    ];

    Widget snackBar = Padding(
      padding: padding,
      child: Wrap(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: widget.padding == null
                      ? const EdgeInsets.symmetric(
                          vertical: _singleLineVerticalPadding)
                      : null,
                  child: DefaultTextStyle(
                    style: contentTextStyle!,
                    child: widget.content,
                  ),
                ),
              ),
              if (!willOverflowAction) ...maybeActionAndIcon,
              if (willOverflowAction) SizedBox(width: snackBarWidth * 0.4),
            ],
          ),
          if (willOverflowAction)
            Padding(
              padding:
                  const EdgeInsets.only(bottom: _singleLineVerticalPadding),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: maybeActionAndIcon),
            ),
        ],
      ),
    );

    if (!isFloatingSnackBar) {
      snackBar = SafeArea(
        top: false,
        child: snackBar,
      );
    }

    final double elevation =
        widget.elevation ?? snackBarTheme.elevation ?? defaults.elevation!;
    final Color backgroundColor = widget.backgroundColor ??
        snackBarTheme.backgroundColor ??
        defaults.backgroundColor!;
    final ShapeBorder? shape = widget.shape ??
        snackBarTheme.shape ??
        (isFloatingSnackBar ? defaults.shape : null);

    snackBar = Material(
      shape: shape,
      elevation: elevation,
      color: backgroundColor,
      child: Theme(
        data: effectiveTheme,
        child: accessibleNavigation || theme.useMaterial3
            ? snackBar
            : FadeTransition(
                opacity: fadeOutAnimation,
                child: snackBar,
              ),
      ),
    );

    if (isFloatingSnackBar) {
      // If width is provided, do not include horizontal margins.
      if (width != null) {
        snackBar = Container(
          margin: EdgeInsets.only(top: margin.top, bottom: margin.bottom),
          width: width,
          child: snackBar,
        );
      } else {
        snackBar = Padding(
          padding: margin,
          child: snackBar,
        );
      }
      snackBar = SafeArea(
        top: false,
        bottom: false,
        child: snackBar,
      );
    }

    snackBar = Semantics(
      container: true,
      liveRegion: true,
      onDismiss: () {
        ScaffoldMessenger.of(context)
            .removeCurrentSnackBar(reason: SnackBarClosedReason.dismiss);
      },
      child: Dismissible(
        key: const Key('dismissible'),
        direction: widget.dismissDirection,
        resizeDuration: null,
        onDismissed: (DismissDirection direction) {
          ScaffoldMessenger.of(context)
              .removeCurrentSnackBar(reason: SnackBarClosedReason.swipe);
        },
        child: snackBar,
      ),
    );

    final Widget snackBarTransition;
    if (accessibleNavigation) {
      snackBarTransition = snackBar;
    } else if (isFloatingSnackBar && !theme.useMaterial3) {
      snackBarTransition = FadeTransition(
        opacity: fadeInAnimation,
        child: snackBar,
      );
      // Is Material 3 Floating Snack Bar.
    } else if (isFloatingSnackBar && theme.useMaterial3) {
      snackBarTransition = FadeTransition(
        opacity: fadeInM3Animation,
        child: AnimatedBuilder(
          animation: heightM3Animation,
          builder: (BuildContext context, Widget? child) {
            return Align(
              alignment: AlignmentDirectional.bottomStart,
              heightFactor: heightM3Animation.value,
              child: child,
            );
          },
          child: snackBar,
        ),
      );
    } else {
      snackBarTransition = AnimatedBuilder(
        animation: heightAnimation,
        builder: (BuildContext context, Widget? child) {
          return Align(
            alignment: AlignmentDirectional.topStart,
            heightFactor: heightAnimation.value,
            child: child,
          );
        },
        child: snackBar,
      );
    }

    return Hero(
      tag: '<SnackBar Hero tag - ${widget.content}>',
      transitionOnUserGestures: true,
      child: ClipRect(
        clipBehavior: widget.clipBehavior,
        child: snackBarTransition,
      ),
    );
  }
}

// Hand coded defaults based on Material Design 2.
class _SnackbarDefaultsM2 extends SnackBarThemeData {
  _SnackbarDefaultsM2(BuildContext context)
      : _theme = Theme.of(context),
        _colors = Theme.of(context).colorScheme,
        super(elevation: 6.0);

  late final ThemeData _theme;
  late final ColorScheme _colors;

  @override
  Color get backgroundColor => _theme.brightness == Brightness.light
      ? Color.alphaBlend(_colors.onSurface.withOpacity(0.80), _colors.surface)
      : _colors.onSurface;

  @override
  TextStyle? get contentTextStyle => ThemeData(
          brightness: _theme.brightness == Brightness.light
              ? Brightness.dark
              : Brightness.light)
      .textTheme
      .titleMedium;

  @override
  SnackBarBehavior get behavior => SnackBarBehavior.fixed;

  @override
  Color get actionTextColor => _colors.secondary;

  @override
  Color get disabledActionTextColor => _colors.onSurface
      .withOpacity(_theme.brightness == Brightness.light ? 0.38 : 0.3);

  @override
  ShapeBorder get shape => const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
      );

  @override
  EdgeInsets get insetPadding =>
      const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0);

  @override
  bool get showCloseIcon => false;

  @override
  Color get closeIconColor => _colors.onSurface;

  @override
  double get actionOverflowThreshold => 0.25;
}

// BEGIN GENERATED TOKEN PROPERTIES - Snackbar

// Do not edit by hand. The code between the "BEGIN GENERATED" and
// "END GENERATED" comments are generated from data in the Material
// Design token database by the script:
//   dev/tools/gen_defaults/bin/gen_defaults.dart.

// Token database version: v0_162

class _SnackbarDefaultsM3 extends SnackBarThemeData {
  _SnackbarDefaultsM3(this.context);

  final BuildContext context;
  late final ThemeData _theme = Theme.of(context);
  late final ColorScheme _colors = _theme.colorScheme;

  @override
  Color get backgroundColor => _colors.inverseSurface;

  @override
  Color get actionTextColor =>
      MaterialStateColor.resolveWith((Set<MaterialState> states) {
        if (states.contains(MaterialState.disabled)) {
          return _colors.inversePrimary;
        }
        if (states.contains(MaterialState.pressed)) {
          return _colors.inversePrimary;
        }
        if (states.contains(MaterialState.hovered)) {
          return _colors.inversePrimary;
        }
        if (states.contains(MaterialState.focused)) {
          return _colors.inversePrimary;
        }
        return _colors.inversePrimary;
      });

  @override
  Color get disabledActionTextColor => _colors.inversePrimary;

  @override
  TextStyle get contentTextStyle =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: _colors.onInverseSurface,
          );

  @override
  double get elevation => 6.0;

  @override
  ShapeBorder get shape => const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.0)));

  @override
  SnackBarBehavior get behavior => SnackBarBehavior.fixed;

  @override
  EdgeInsets get insetPadding =>
      const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0);

  @override
  bool get showCloseIcon => false;

  @override
  Color? get closeIconColor => _colors.onInverseSurface;

  @override
  double get actionOverflowThreshold => 0.25;
}

// END GENERATED TOKEN PROPERTIES - Snackbar
