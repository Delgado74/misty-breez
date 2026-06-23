import 'package:auto_size_text/auto_size_text.dart';
import 'package:breez_translations/breez_translations_locales.dart';
import 'package:breez_translations/generated/breez_translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:misty_breez/cubit/cubit.dart';
import 'package:misty_breez/routes/routes.dart';
import 'package:misty_breez/theme/theme.dart';
import 'package:misty_breez/utils/utils.dart';
import 'package:misty_breez/widgets/widgets.dart';

const _liquidBtcAssetId = '6f0279e9ed041c3d710a9f57d0c02928416460c4b722ae3457a11eec381c526d';
const _usdtAssetId = 'ce091c998b83c78bb71a632313ba3760f1763d9cfcffae02258ffa9865a37bd2';

class ReceiveLiquidAddressPage extends StatefulWidget {
  static const String routeName = '/receive_liquid_address';
  static const int pageIndex = 4;

  const ReceiveLiquidAddressPage({super.key});

  @override
  State<ReceiveLiquidAddressPage> createState() => _ReceiveLiquidAddressPageState();
}

class _ReceiveLiquidAddressPageState extends State<ReceiveLiquidAddressPage> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  String _selectedAssetId = _liquidBtcAssetId;

  Future<PrepareReceiveResponse>? prepareResponseFuture;
  Future<ReceivePaymentResponse>? receivePaymentResponseFuture;

  @override
  void initState() {
    super.initState();
    if (_amountFocusNode.canRequestFocus) {
      _amountFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  String get _selectedAssetLabel {
    return _selectedAssetId == _liquidBtcAssetId ? 'L-BTC' : 'USDt';
  }

  @override
  Widget build(BuildContext context) {
    final BreezTranslations texts = context.texts();

    return Scaffold(
      body: prepareResponseFuture == null
          ? Padding(
              padding: const EdgeInsets.only(top: 32, bottom: 40.0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildAssetSelector(),
                    const SizedBox(height: 24),
                    _buildAmountForm(),
                  ],
                ),
              ),
            )
          : _buildQRCode(),
      bottomNavigationBar: prepareResponseFuture == null && receivePaymentResponseFuture == null
          ? SingleButtonBottomBar(
              stickToBottom: true,
              text: 'Generate $_selectedAssetLabel Address',
              onPressed: _generateAddress,
            )
          : FutureBuilder<PrepareReceiveResponse>(
              future: prepareResponseFuture,
              builder: (BuildContext context, AsyncSnapshot<PrepareReceiveResponse> prepareSnapshot) {
                if (prepareSnapshot.hasData) {
                  return FutureBuilder<ReceivePaymentResponse>(
                    future: receivePaymentResponseFuture,
                    builder: (BuildContext context, AsyncSnapshot<ReceivePaymentResponse> receiveSnapshot) {
                      if (receiveSnapshot.hasData) {
                        return SingleButtonBottomBar(
                          stickToBottom: true,
                          text: texts.qr_code_dialog_action_close,
                          onPressed: () => Navigator.of(context).pop(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
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
    final BreezTranslations texts = context.texts();
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
            focusNode: _amountFocusNode,
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
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: AutoSizeText(
              'Enter the amount in $_selectedAssetLabel to receive',
              style: paymentLimitInformationTextStyle,
              maxLines: 1,
              minFontSize: MinFontSize(context).minFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode() {
    final BreezTranslations texts = context.texts();
    final ThemeData themeData = Theme.of(context);

    return FutureBuilder<PrepareReceiveResponse>(
      future: prepareResponseFuture,
      builder: (BuildContext context, AsyncSnapshot<PrepareReceiveResponse> prepareSnapshot) {
        if (prepareSnapshot.hasError) {
          return ScrollableErrorMessageWidget(
            showIcon: true,
            title: '${texts.qr_code_dialog_warning_message_error}:',
            message: ExceptionHandler.extractMessage(prepareSnapshot.error!, texts),
            padding: EdgeInsets.zero,
          );
        }

        if (prepareSnapshot.hasData) {
          return FutureBuilder<ReceivePaymentResponse>(
            future: receivePaymentResponseFuture,
            builder: (BuildContext context, AsyncSnapshot<ReceivePaymentResponse> receiveSnapshot) {
              if (receiveSnapshot.hasError) {
                return ScrollableErrorMessageWidget(
                  showIcon: true,
                  title: '${texts.qr_code_dialog_warning_message_error}:',
                  message: ExceptionHandler.extractMessage(receiveSnapshot.error!, texts),
                  padding: EdgeInsets.zero,
                );
              }

              if (receiveSnapshot.hasData) {
                return Container(
                  decoration: ShapeDecoration(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    color: themeData.customData.surfaceBgColor,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                  child: SingleChildScrollView(
                    child: DestinationWidget(
                      snapshot: receiveSnapshot,
                      destination: receiveSnapshot.data?.destination,
                      paymentLabel: '$_selectedAssetLabel Liquid Address',
                      infoWidget: PaymentFeesMessageBox(
                        feesSat: prepareSnapshot.data!.feesSat.toInt(),
                        isBitcoinPayment: true,
                      ),
                      isBitcoinPayment: true,
                    ),
                  ),
                );
              }

              return const CenteredLoader();
            },
          );
        }

        return const CenteredLoader();
      },
    );
  }

  void _generateAddress() {
    final PaymentsCubit paymentsCubit = context.read<PaymentsCubit>();

    final double? payerAmount = double.tryParse(_amountController.text);
    final Future<PrepareReceiveResponse> prepareReceiveResponse = paymentsCubit.prepareReceivePayment(
      paymentMethod: PaymentMethod.liquidAddress,
      assetId: _selectedAssetId,
      payerAmount: payerAmount,
    );

    setState(() {
      prepareResponseFuture = prepareReceiveResponse;
    });
    prepareReceiveResponse.then((PrepareReceiveResponse prepareResponse) {
      setState(() {
        receivePaymentResponseFuture = paymentsCubit.receivePayment(
          prepareResponse: prepareResponse,
        );
      });
    });
  }
}
