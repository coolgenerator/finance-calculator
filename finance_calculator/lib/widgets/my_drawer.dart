import 'package:flutter/material.dart';
import 'package:finance_calculator/calculators/interest_calculator.dart';
import 'package:finance_calculator/calculators/time_value_calculator.dart';
import 'package:finance_calculator/calculators/pro_forma_income_statement.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: const Text('Interest Rate Calculator'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InterestCalculator()),
                );
              },
            ),
            ListTile(
              title: const Text('Time Value Calculator'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimeValueCalculator()),
                );
              },
            ),
            ListTile(
              title: const Text('Pro Forma Income Statement'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProFormaIncomeStatementPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Interest Rate Calculator'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InterestCalculator()),
                );
              },
            ),
          ],
        ),
      );
  }
}