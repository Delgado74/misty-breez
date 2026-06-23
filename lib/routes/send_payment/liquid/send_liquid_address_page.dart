import 'package:breez_translations/breez_translations_locales.dart';
import 'package:breez_translations/generated/breez_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:logging/logging.dart';
import 'package:misty_breez/cubit/cubit.dart';
import 'package:misty_breez/theme/theme.dart';
import 'package:misty_breez/utils/utils.dart';
import 'package:misty_breez/widgets/back_button.dart' as back_button;
import 'package:misty_breez/widgets/widgets.dart';

const _liquidBtcAssetId = '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d';
const _usdtAssetId = 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2';

final Logger _logger = Logger('SendLiquidAddressPage');

class SendLiquidAddressPage extends StatefulWidget {
  final LiquidAddressData? liquidAddressData;

  static const String routeName = '/send_liquid_address';

  const SendLiquidAddressPage({required this.liquidAddressData, super.key});

  @override
  State<SendLiquidAddressPage> createState() => _SendLiquidAddressPageState();
}

class _SendLiquidAddressPageState extends State<SendLiquidAddressPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  String _selectedAssetId = _liquidBtcAssetId;

  @override
  void initState() {
    super.initState();
    if (widget.liquidAddressData?.assetId != null) {
      _selectedAssetId = widget.liquidAddressData!.assetId!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String get _selectedAssetLabel {
    return _selectedAssetId == _liquidBtcAssetId ? 'L-BTC' : 'USDt';
  }

  String get _selectedAssetTicker {
    return _selectedAssetId == _liquidBtcAssetId ? 'L-BTC' : 'USDT';
  }

  @override
  Widget build(BuildContext context) {
    final BreezTranslations texts = context.texts();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(leading: const back_button.BackButton(), title: Text('Send to $_selectedAssetLabel Address')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildAddressInfo(),
              const SizedBox(height: 24),
              if (widget.liquidAddressData?.assetId == null) _buildAssetSelector(),
              if (widget.liquidAddressData?.assetId == null) const SizedBox(height: 24),
              _buildAmountForm(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SingleButtonBottomBar(
        stickToBottom: true,
        text: 'Send $_selectedAssetLabel',
        onPressed: _prepareSend,
      ),
    );
  }

  Widget _buildAddressInfo() {
    final ThemeData themeData = Theme.of(context);
    final LiquidAddressData? data = widget.liquidAddressData;

    return Container(
      decoration: ShapeDecoration(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        color: themeData.customData.surfaceBgColor,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Recipient', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SelectableText(
            data?.address ?? '',
            style: const TextStyle(fontSize: 14),
          ),
          if (data?.assetId != null) ...[
            const SizedBox(height: 8),
            Text('Asset: $_selectedAssetLabel', style: const TextStyle(fontSize: 14)),
          ],
          if (data?.amount != null) ...[
            const SizedBox(height: 8),
            Text('Amount: ${data!.amount}', style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }

  Widget _buildAssetSelector() {
    final ThemeData themeData = Theme.of(context);
    return Container(
      decoration: ShapeDecoration(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        color: themeData.customData.surfaceBgColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Asset', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: _liquidBtcAssetId, label: Text('L-BTC')),
              ButtonSegment<String>(value: _usdtAssetId, label: Text('USDt')),
            ],
            selected: <String>{_selectedAssetId},
            onSelectionChanged: (Set<String> selected) {
              setState(() {
                _selectedAssetId = selected.first;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmountForm() {
    final ThemeData themeData = Theme.of(context);

    return Container(
      decoration: ShapeDecoration(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        color: themeData.customData.surfaceBgColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              prefixIconConstraints: BoxConstraints.tight(const Size(16, 56)),
              prefixIcon: const SizedBox.shrink(),
              contentPadding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
              border: const OutlineInputBorder(),
              labelText: 'Amount ($_selectedAssetLabel)',
            ),
            style: FieldTextStyle.textStyle,
          ),
        ],
      ),
    );
  }

  void _prepareSend() async {
    final BreezTranslations texts = context.texts();
    final NavigatorState navigator = Navigator.of(context);
    if (_formKey.currentState?.validate() ?? false) {
      final TransparentPageRoute<void> loaderRoute = createLoaderRoute(context);
      navigator.push(loaderRoute);
      try {
        final LiquidAddressData addressData = widget.liquidAddressData!;
        final SendDestination destination = SendDestination_LiquidAddress(
          addressData: addressData,
          bip353Address: null,
        );

        final double amount = double.tryParse(_amountController.text) ?? 0;
        final PayAmount payAmount = PayAmount_Asset(
          toAsset: _selectedAssetId,
          receiverAmount: amount,
          estimateAssetFees: null,
          fromAsset: null,
        );

        final PrepareSendRequest req = PrepareSendRequest(
          destination: destination,
          amount: payAmount,
        );

        final PaymentsCubit paymentsCubit = context.read<PaymentsCubit>();
        final PrepareSendResponse prepareResponse = await paymentsCubit.prepareSendPayment(req: req);

        if (loaderRoute.isActive) {
          navigator.removeRoute(loaderRoute);
        }

        if (!context.mounted) return;

        await showProcessingPaymentSheet(
          context,
          paymentFunc: () async {
            return await paymentsCubit.sendPayment(prepareResponse: prepareResponse);
          },
        ).then((dynamic result) {
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(Home.routeName, (Route<dynamic> route) => false);
            if (result is SendPaymentResponse) {
              _logger.info('Payment sent - status: ${result.payment.status}');
            }
          }
        });
      } catch (error) {
        if (loaderRoute.isActive) {
          navigator.removeRoute(loaderRoute);
        }
        _logger.severe('Error sending Liquid payment: $error');
        if (!context.mounted) return;
        showFlushbar(
          context,
          message: texts.reverse_swap_upstream_generic_error_message(
            ExceptionHandler.extractMessage(error, texts),
          ),
        );
      }
    }
  }
}
