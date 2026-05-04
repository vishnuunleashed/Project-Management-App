
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



AutoDisposeChangeNotifierProvider<T> baseChangeNotifier<T extends BaseProvider>(
    T Function() create,
    ) {
  return ChangeNotifierProvider.autoDispose<T>((ref) => create());
}

ChangeNotifierProvider<T> baseChangeNotifierKeepAlive<T extends BaseProvider>(
    T Function() create,
    ) {
  return ChangeNotifierProvider<T>((ref) => create());
}