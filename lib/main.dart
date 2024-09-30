import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const TemperatureConverter(),
    );
  }
}

class TemperatureConverter extends StatefulWidget {
  const TemperatureConverter({super.key});

  @override
  _TemperatureConverterState createState() => _TemperatureConverterState();
}

class _TemperatureConverterState extends State<TemperatureConverter> with SingleTickerProviderStateMixin {
  String _conversionType = 'FtoC';
  final TextEditingController _inputController = TextEditingController();
  String _convertedTemp = '';
  final List<String> _history = [];
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Section to convert the temperature based on the selected conversion type
  void _convert() {
    if (_inputController.text.isEmpty) {
      _showErrorDialog('Enter temperature.');
      return;
    }

    double? inputTemp = double.tryParse(_inputController.text);
    if (inputTemp == null) {
      _showErrorDialog('Invalid input. Please enter a valid number.');
      return;
    }

    double result;
    String operation;

    if (_conversionType == 'FtoC') {
      result = (inputTemp - 32) * 5 / 9;
      operation = 'F to C';
    } else {
      result = inputTemp * 9 / 5 + 32;
      operation = 'C to F';
    }

    setState(() {
      _convertedTemp = result.toStringAsFixed(2);
      _history.insert(0, '$operation: ${_inputController.text}° => $_convertedTemp°');
    });

    _animationController.forward(from: 0);
  }

  // Shows an error dialog with the given message
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Section for the radio buttons for conversion type selection
  Widget _buildConversionTypeSelector() {
    return Row(
      children: <Widget>[
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Fahrenheit to Celsius'),
            value: 'FtoC',
            groupValue: _conversionType,
            onChanged: (value) {
              setState(() {
                _conversionType = value!;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Celsius to Fahrenheit'),
            value: 'CtoF',
            groupValue: _conversionType,
            onChanged: (value) {
              setState(() {
                _conversionType = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  // Section for the input field for temperature
  Widget _buildTemperatureInput() {
    return TextField(
      controller: _inputController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: 'Enter temperature',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // Section for the convert button
  Widget _buildConvertButton() {
    return ElevatedButton(
      onPressed: _convert,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text('Convert'),
    );
  }

  // Section for the result display
  Widget _buildResultDisplay() {
    return ScaleTransition(
      scale: _animation,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Converted Temperature: $_convertedTemp°',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // Section for the conversion history list
  Widget _buildConversionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conversion History:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView.builder(
            itemCount: _history.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_history[index]),
                leading: const Icon(Icons.history),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Converter'),
        backgroundColor: Colors.yellow,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildConversionTypeSelector(),
                  const SizedBox(height: 16),
                  _buildTemperatureInput(),
                  const SizedBox(height: 16),
                  _buildConvertButton(),
                  const SizedBox(height: 16),
                  _buildResultDisplay(),
                  const SizedBox(height: 16),
                  _buildConversionHistory(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}