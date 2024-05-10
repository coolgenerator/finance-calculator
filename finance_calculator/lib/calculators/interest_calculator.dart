import 'package:finance_calculator/widgets/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InterestCalculator extends StatefulWidget {
  const InterestCalculator({super.key});
  @override
  _InterestCalculatorState createState() => _InterestCalculatorState();
}

class _InterestCalculatorState extends State<InterestCalculator> {
  String selectedCalculation = 'EAR';
  String apr = '';
  String ear = '';
  String n = '';
  dynamic result = '';

  void handleCalculationChange(String newValue) {
    setState(() {
      selectedCalculation = newValue;
      result = '';
      apr = '';
      ear = '';
      n = '';
    });
  }

  Future<void> handleCalculate() async {
    Map<String, String> params = {};
    if (selectedCalculation == 'EAR') {
      params = {'apr': apr, 'n': n};
    } else if (selectedCalculation == 'APR') {
      params = {'ear': ear, 'n': n};
    }

    try {
      final uri = Uri.http('localhost:8080', '/calculate$selectedCalculation', params);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          result = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        result = {'error': 'Failed to fetch data'};
      });
    }
  }

  Widget renderResult() {
    return Column(
      children: result.keys.map<Widget>((key) => Text('$key: ${result[key]}%')).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Interest Rate Calculator')),
      drawer: const MyDrawer(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: selectedCalculation,
              onChanged: (String? newValue) {
                if (newValue != null) handleCalculationChange(newValue);
              },
              items: <String>['EAR', 'APR']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value + ' Calculator'),
                );
              }).toList(),
            ),
            if (selectedCalculation == 'EAR') ...[
              TextField(
                decoration: InputDecoration(labelText: 'Annual Interest Rate (APR)'),
                onChanged: (value) => setState(() => apr = value),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Number of Compounding Periods (NPER)'),
                onChanged: (value) => setState(() => n = value),
                keyboardType: TextInputType.number,
              ),
            ],
            if (selectedCalculation == 'APR') ...[
              TextField(
                decoration: InputDecoration(labelText: 'Effective Annual Rate (EAR)'),
                onChanged: (value) => setState(() => ear = value),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Number of Compounding Periods (NPER)'),
                onChanged: (value) => setState(() => n = value),
                keyboardType: TextInputType.number,
              ),
            ],
            ElevatedButton(
              onPressed: handleCalculate,
              child: Text('Calculate'),
            ),
            if (result != '') ...[
              Text('Result:'),
              renderResult(),
            ],
          ],
        ),
      ),
    );
  }
}
