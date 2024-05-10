import 'package:flutter/material.dart';
import 'package:finance_calculator/widgets/my_drawer.dart';
import 'package:http/http.dart' as http;
// import 'package:expressions/expressions.dart';
import 'dart:convert';

class TimeValueCalculator extends StatefulWidget {
  const TimeValueCalculator({super.key});
  @override
  _TimeValueCalculatorState createState() => _TimeValueCalculatorState();
}

class _TimeValueCalculatorState extends State<TimeValueCalculator> {
  String calcType = 'PV';
  final TextEditingController rateController = TextEditingController();
  final TextEditingController nperController = TextEditingController();
  final TextEditingController pmtController = TextEditingController();
  final TextEditingController pvController = TextEditingController();
  final TextEditingController fvController = TextEditingController();
  String type = '0'; // '0' for end, '1' for beginning
  String result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Time Value of Money Calculator")),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            DropdownButton<String>(
              value: calcType,
              onChanged: (String? newValue) {
                setState(() {
                  calcType = newValue!;
                });
              },
              items: <String>['PV', 'FV', 'PMT', 'NPER', 'RATE']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (['PV', 'FV', 'PMT', 'NPER', 'RATE'].contains(calcType))
              TextFormField(
                controller: rateController,
                decoration: InputDecoration(labelText: "Interest Rate (% per period)"),
              ),
            if (['PV', 'FV', 'PMT', 'RATE'].contains(calcType))
              TextFormField(
                controller: nperController,
                decoration: InputDecoration(labelText: "Total Number of Periods"),
              ),
            if (['PV', 'FV', 'NPER', 'RATE'].contains(calcType))
              TextFormField(
                controller: pmtController,
                decoration: InputDecoration(labelText: "Payment Amount per Period"),
              ),
            if (['PMT', 'FV', 'NPER', 'RATE'].contains(calcType))
              TextFormField(
                controller: pvController,
                decoration: InputDecoration(labelText: "Present Value"),
              ),
            if (['PV', 'PMT', 'NPER', 'RATE'].contains(calcType))
              TextFormField(
                controller: fvController,
                decoration: InputDecoration(labelText: "Future Value"),
              ),
            DropdownButton<String>(
              value: type,
              onChanged: (String? newValue) {
                setState(() {
                  type = newValue!;
                });
              },
              items: <String>['0', '1']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == '0' ? "End of Each Period" : "Beginning of Each Period"),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: calculate,
              child: Text('Calculate'),
            ),
            Text('Result: $result'),
          ],
        ),
      ),
    );
  }

  void dispose() {
    rateController.dispose();
    nperController.dispose();
    pmtController.dispose();
    pvController.dispose();
    fvController.dispose();
    super.dispose();
  }
  Future<void> calculate() async {
//TODO: Handle input formulas
    var safeData = <String, dynamic>{
      'calcType': calcType,
      'rate': double.parse(rateController.text),
      'nper': double.parse(nperController.text),
      'pmt': double.parse(pmtController.text),
      'pv': double.parse(pvController.text),
      'fv': double.parse(fvController.text),
      'type': int.parse(type),
    };

    try {
      var response = await http.post(
        Uri.parse('http://localhost:8080/calculateTimeValue'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(safeData),
      );
      var data = jsonDecode(response.body);
      setState(() {
        result = data['result'].toString();
      });
    } catch (e) {
      print("Error calculating $calcType: $e");
      setState(() {
        result = "Failed to calculate $calcType";
      });
    }
  }
}