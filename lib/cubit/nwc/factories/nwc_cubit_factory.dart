import 'package:breez_sdk_liquid/breez_sdk_liquid.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:misty_breez/cubit/cubit.dart';
import 'package:service_injector/service_injector.dart';

class NwcCubitFactory {
  static NwcCubit of(BuildContext context) => create(ServiceInjector());

  static NwcCubit create(ServiceInjector injector) {
    final BreezSDKLiquid breezSdkLiquid = injector.breezSdkLiquid;

    return NwcCubit(
      breezSdkLiquid: breezSdkLiquid,
      nwcService: breezSdkLiquid.nwc!,
    );
  }
}
