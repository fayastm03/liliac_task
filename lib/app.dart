import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/transactions/providers/transaction_provider.dart';
import 'features/transactions/repositories/transaction_repository.dart';

class ExpenziaApp extends StatelessWidget {
  const ExpenziaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          TransactionProvider(repository: TransactionRepository())
            ..loadTransactions(),
      child: MaterialApp(
        title: 'Expenzia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
