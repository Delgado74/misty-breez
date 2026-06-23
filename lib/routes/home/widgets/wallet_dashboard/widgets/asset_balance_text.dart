import 'package:flutter/material.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:misty_breez/cubit/cubit.dart';
import 'package:misty_breez/theme/theme.dart';

class AssetBalanceText extends StatelessWidget {
  final bool hiddenBalance;
  final AccountState accountState;
  final double offsetFactor;

  const AssetBalanceText({
    required this.hiddenBalance,
    required this.accountState,
    required this.offsetFactor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final WalletInfo? walletInfo = accountState.walletInfo;
    if (walletInfo == null || walletInfo.assetBalances.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<AssetBalance> displayAssets = walletInfo.assetBalances
        .where(
          (AssetBalance a) =>
              a.ticker != null &&
              a.ticker!.toUpperCase() != 'L-BTC' &&
              a.balance != null &&
              a.balance! > 0,
        )
        .toList();

    if (displayAssets.isEmpty) {
      return const SizedBox.shrink();
    }

    final double opacity = (1.00 - offsetFactor).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: displayAssets
            .map(
              (AssetBalance asset) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  hiddenBalance
                      ? '*** ${asset.ticker!}'
                      : '${_formatAssetBalance(asset.balance!)} ${asset.ticker!}',
                  style: balanceFiatConversionTextStyle.copyWith(
                    color: themeData.colorScheme.onSecondary
                        .withValues(alpha: opacity),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  String _formatAssetBalance(double balance) {
    if (balance == balance.truncateToDouble()) {
      return balance.toInt().toString();
    }
    return balance.toStringAsFixed(2);
  }
}
