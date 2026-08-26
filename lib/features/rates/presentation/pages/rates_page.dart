import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/rates_list_bloc.dart';
import '../widgets/rate_card.dart';
import '../widgets/rates_header.dart';
import '../widgets/rates_message_view.dart';
import '../widgets/rates_skeleton.dart';

/// Screen 1 — live exchange rates for the tracked currencies against EGP.
class RatesPage extends StatelessWidget {
  const RatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange Rates'),
        actions: [
          // Explicit refresh in addition to pull-to-refresh.
          _RefreshAction(),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<RatesListBloc, RatesListState>(
        // Surface a refresh failure without discarding the cached rates.
        listenWhen: (prev, curr) =>
            curr.status == RatesListStatus.failure && curr.hasData,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Couldn’t refresh rates.'),
              ),
            );
        },
        builder: (context, state) {
          final isInitialLoading =
              state.status == RatesListStatus.initial ||
              (!state.hasData && state.status == RatesListStatus.loading);
          if (isInitialLoading) {
            return const RatesSkeleton();
          }

          if (!state.hasData && state.status == RatesListStatus.failure) {
            return RatesMessageView(
              icon: Icons.cloud_off_rounded,
              title: 'Couldn’t load rates',
              message: state.errorMessage,
              actionLabel: 'Try again',
              onAction: () =>
                  context.read<RatesListBloc>().add(const RatesListRequested()),
            );
          }

          if (!state.hasData) {
            return const RatesMessageView(
              icon: Icons.currency_exchange_rounded,
              title: 'No rates to show',
              message: 'We couldn’t find any currency data right now.',
            );
          }

          return _RatesList(state: state);
        },
      ),
    );
  }
}

class _RefreshAction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Rebuilds only on status change — cheap and localized.
    final isLoading = context.select<RatesListBloc, bool>(
      (b) => b.state.status == RatesListStatus.loading,
    );
    return IconButton(
      tooltip: 'Refresh',
      onPressed: isLoading
          ? null
          : () => context.read<RatesListBloc>().add(const RatesListRefreshed()),
      icon: const Icon(Icons.refresh_rounded),
    );
  }
}

class _RatesList extends StatelessWidget {
  const _RatesList({required this.state});

  final RatesListState state;

  @override
  Widget build(BuildContext context) {
    final snapshot = state.snapshot!;
    final rates = snapshot.rates;

    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<RatesListBloc>()
          ..add(const RatesListRefreshed());
        // Keep the spinner up until the in-flight refresh settles. The timeout
        // is a safety net so the indicator can never hang indefinitely.
        await bloc.stream
            .firstWhere((s) => s.status != RatesListStatus.loading)
            .timeout(const Duration(seconds: 20), onTimeout: () => bloc.state);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        // +1 for the header row.
        itemCount: rates.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return RatesHeader(lastUpdated: snapshot.lastUpdated);
          }
          return RateCard(rate: rates[index - 1]);
        },
      ),
    );
  }
}
