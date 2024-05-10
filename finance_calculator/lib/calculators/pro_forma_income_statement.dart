import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:finance_calculator/widgets/my_drawer.dart';

class ProFormaIncomeStatement {
  double revenue;
  double cogs;
  double opExpenses;
  double otherExpenses;
  double taxRate;

  ProFormaIncomeStatement({
    required this.revenue,
    required this.cogs,
    required this.opExpenses,
    required this.otherExpenses,
    required this.taxRate,
  });

  double get grossProfit => revenue - cogs;
  double get operatingIncome => grossProfit - opExpenses;
  double get preTaxIncome => operatingIncome - otherExpenses;
  double get tax => preTaxIncome * taxRate;
  double get netIncome => preTaxIncome - tax;
}

class ProFormaIncomeStatementPage extends StatefulWidget {
  @override
  _ProFormaIncomeStatementPageState createState() => _ProFormaIncomeStatementPageState();
}

class _ProFormaIncomeStatementPageState extends State<ProFormaIncomeStatementPage> {
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController cogsController = TextEditingController();
  final TextEditingController opExpensesController = TextEditingController();
  final TextEditingController otherExpensesController = TextEditingController();
  final TextEditingController taxRateController = TextEditingController();

  String result = '';

  Future<void> calculateIncomeStatement() async {
    double revenue = double.tryParse(revenueController.text) ?? 0;
    double cogs = double.tryParse(cogsController.text) ?? 0;
    double opExpenses = double.tryParse(opExpensesController.text) ?? 0;
    double otherExpenses = double.tryParse(otherExpensesController.text) ?? 0;
    double taxRate = double.tryParse(taxRateController.text) ?? 0;

    final incomeStatement = ProFormaIncomeStatement(
      revenue: revenue,
      cogs: cogs,
      opExpenses: opExpenses,
      otherExpenses: otherExpenses,
      taxRate: taxRate / 100, // Convert percentage to decimal
    );

    try {
      var response = await http.post(
        Uri.parse('http://localhost:8080/ProFormaStatement'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'revenue': incomeStatement.revenue,
          'cogs': incomeStatement.cogs,
          'opExpenses': incomeStatement.opExpenses,
          'otherExpenses': incomeStatement.otherExpenses,
          'taxRate': incomeStatement.taxRate,
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          result = 'Net Income: ${data['netIncome'].toString()}';
        });
      } else {
        throw Exception('Failed to load data with status code ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        result = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pro Forma Income Statement Calculator'),
      ),
      drawer: MyDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              buildTextField(revenueController, 'Total Revenue'),
              buildTextField(cogsController, 'Cost of Goods Sold'),
              buildTextField(opExpensesController, 'Operating Expenses'),
              buildTextField(otherExpensesController, 'Other Expenses'),
              buildTextField(taxRateController, 'Tax Rate (%)'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: calculateIncomeStatement,
                child: Text('Calculate'),
              ),
              SizedBox(height: 20),
              Text(result, style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
    );
  }

  @override
  void dispose() {
    revenueController.dispose();
    cogsController.dispose();
    opExpensesController.dispose();
    otherExpensesController.dispose();
    taxRateController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(home: ProFormaIncomeStatementPage()));
}
