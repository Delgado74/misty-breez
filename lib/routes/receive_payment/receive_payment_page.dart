import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:misty_breez/cubit/cubit.dart';
import 'package:misty_breez/routes/routes.dart';
import 'package:misty_breez/widgets/back_button.dart' as back_button;

class ReceivePaymentPage extends StatefulWidget {
  static const String routeName = '/receive_payment';

  final int? initialPageIndex;

  const ReceivePaymentPage({this.initialPageIndex, super.key});

  @override
  State<ReceivePaymentPage> createState() => _ReceivePaymentPageState();
}

class _ReceivePaymentPageState extends State<ReceivePaymentPage> {
  static const List<StatefulWidget> pages = <StatefulWidget>[
    ReceiveLightningPaymentPage(),
    ReceiveAmountlessBitcoinAddressPage(),
    ReceiveBitcoinAddressPaymentPage(),
    ReceiveLiquidAddressPage(),
  ];

  bool _hasAmountlessBtcAddressError = false;

  late int _currentPageIndex;
  bool _showBtcPaymentRequestPage = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentPageIndex = widget.initialPageIndex ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    _hasAmountlessBtcAddressError = context.select<AmountlessBtcCubit, bool>(
      (AmountlessBtcCubit cubit) => cubit.state.hasError,
    );

    return Scaffold(
      appBar: AppBar(
        leading: back_button.BackButton(
          onPressed: () {
            if (_showBtcPaymentRequestPage && !_hasAmountlessBtcAddressError) {
              setState(() {
                _showBtcPaymentRequestPage = false;
              });
              return;
            }
            Navigator.of(context).pushReplacementNamed(Home.routeName);
          },
        ),
        title: PaymentMethodDropdown(
          currentPaymentMethod: _currentPaymentMethod,
          onPaymentMethodChanged: _onPaymentMethodChanged,
        ),
        centerTitle: true,
        actions: <Widget>[
          if (_currentPageIndex == ReceiveAmountlessBitcoinAddressPage.pageIndex)
            IconButton(
              alignment: Alignment.center,
              icon: const Icon(Icons.edit_note_rounded, size: 24.0),
              tooltip: 'Specify amount for payment request',
              onPressed: () {
                setState(() {
                  _showBtcPaymentRequestPage = true;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: pages.elementAt(_currentPageIndex),
      ),
    );
  }

  int _getEffectivePageIndex() {
    if (_currentPaymentMethod == PaymentMethod.bitcoinAddress) {
      return _showBtcPaymentRequestPage || _hasAmountlessBtcAddressError
          ? ReceiveBitcoinAddressPaymentPage.pageIndex
          : ReceiveAmountlessBitcoinAddressPage.pageIndex;
    }
    if (_currentPaymentMethod == PaymentMethod.liquidAddress) {
      return ReceiveLiquidAddressPage.pageIndex;
    }
    return 0;
  }

  PaymentMethod get _currentPaymentMethod {
    if (_currentPageIndex == ReceiveLiquidAddressPage.pageIndex) {
      return PaymentMethod.liquidAddress;
    }
    if (_currentPageIndex == ReceiveAmountlessBitcoinAddressPage.pageIndex ||
        _currentPageIndex == ReceiveBitcoinAddressPaymentPage.pageIndex) {
      return PaymentMethod.bitcoinAddress;
    }
    return PaymentMethod.bolt11Invoice;
  }

  Future<void> _onPaymentMethodChanged(PaymentMethod newMethod) async {
    if (newMethod == _currentPaymentMethod) {
      return;
    }
    Future<void>.microtask(() async {
      setState(() {
        _showBtcPaymentRequestPage = false;
        _currentPageIndex = newMethod == PaymentMethod.bitcoinAddress
            ? ReceiveAmountlessBitcoinAddressPage.pageIndex
            : newMethod == PaymentMethod.liquidAddress
                ? ReceiveLiquidAddressPage.pageIndex
                : 0;
      });
    });
  }
}
