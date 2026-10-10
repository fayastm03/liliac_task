import 'package:flutter/material.dart';

import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/transactions/screens/history_screen.dart';
import '../../features/transactions/screens/transaction_form_screen.dart';
import '../../features/credit/screens/credit_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

class AppBottomNavigation extends StatefulWidget {
  const AppBottomNavigation({super.key});

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  int _selectedIndex = 0;

  static const double _navigationHeight = 80;
  static const double _addButtonSize = 84;
  static const Color _teal = Color(0xFF00877F);

  void _goToDashboard() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  Future<void> _openTransactionForm() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const TransactionFormScreen()),
    );

    if (!mounted) return;

    setState(() {
      _selectedIndex = 0;
    });
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(onSeeAll: () => _selectPage(1)),
      HistoryScreen(onBack: _goToDashboard),
      CreditScreen(onBack: _goToDashboard),
      ProfileScreen(onBack: _goToDashboard),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: SizedBox(
        height: _navigationHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/bottom_navigation.png',
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: _teal);
                },
              ),
            ),

            // Home tap area
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.sizeOf(context).width * 0.20,
              child: _navigationTapArea(index: 0, tooltip: 'Home'),
            ),

            // History tap area
            Positioned(
              left: MediaQuery.sizeOf(context).width * 0.20,
              top: 0,
              bottom: 0,
              width: MediaQuery.sizeOf(context).width * 0.20,
              child: _navigationTapArea(index: 1, tooltip: 'History'),
            ),

            // Credit tap area
            Positioned(
              left: MediaQuery.sizeOf(context).width * 0.60,
              top: 0,
              bottom: 0,
              width: MediaQuery.sizeOf(context).width * 0.20,
              child: _navigationTapArea(index: 2, tooltip: 'Credit'),
            ),

            // Profile tap area
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: MediaQuery.sizeOf(context).width * 0.20,
              child: _navigationTapArea(index: 3, tooltip: 'Profile'),
            ),

            // Raised circular add button
            Positioned(
              top: -(_addButtonSize - _navigationHeight) / 2,
              child: SizedBox(
                width: _addButtonSize,
                height: _addButtonSize,
                child: IconButton(
                  tooltip: 'Add transaction',
                  onPressed: _openTransactionForm,
                  style: IconButton.styleFrom(
                    backgroundColor: _teal,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(
                      side: BorderSide(color: Colors.white, width: 5),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navigationTapArea({required int index, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectPage(index),
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
        ),
      ),
    );
  }
}
