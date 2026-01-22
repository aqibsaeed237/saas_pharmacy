import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_localizations.dart';
import '../bloc/sale_bloc.dart';
import 'tabs/ongoing_sales_tab.dart';
import 'tabs/completed_sales_tab.dart';
import 'tabs/cancelled_sales_tab.dart';

/// Sales history screen with tabs
class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(loc?.translate('salesHistory') ?? 'Sales History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: loc?.translate('ongoing') ?? 'Ongoing'),
            Tab(text: loc?.translate('completed') ?? 'Completed'),
            Tab(text: loc?.translate('cancelled') ?? 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OngoingSalesTab(),
          CompletedSalesTab(),
          CancelledSalesTab(),
        ],
      ),
    );
  }
}

