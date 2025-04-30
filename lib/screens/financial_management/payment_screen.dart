import 'package:flutter/material.dart';
import 'package:gomed_admin/widgets/topbar.dart';
import 'package:gomed_admin/widgets/custom_button.dart';
import 'package:gomed_admin/screens/dashboard_screen.dart';
import 'package:gomed_admin/widgets/bottomnavigation.dart';

class PaymentScreen extends StatefulWidget {
  final String username;
  final double amount;

  const PaymentScreen({
    Key? key,
    required this.username,
    required this.amount,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = ''; // Track selected payment method
  String? _selectedBank; // Track selected bank
  String? _selectedCard; // Track selected card

  final List<String> _banks = ['XYZ Bank', 'ABC Bank', 'DEF Bank'];
  final List<Map<String, String>> _cards = [
    {'name': 'John Doe', 'number': '************5678', 'expiry': '12/25'},
    {'name': 'Jane Doe', 'number': '************9876', 'expiry': '11/24'},
    {'name': 'Alice Smith', 'number': '************1234', 'expiry': '10/26'},
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              TopBar(
                title: 'Payment Details',
                onBackPressed: () {
                  Navigator.pop(context);
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text('Username: ${widget.username}',
                        style: const TextStyle(fontSize: 18)),
                    Text('Amount: \$${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 20),
                    const Text(
                      'Payment Type',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = 'Net Banking';
                              });
                            },
                            child: Card(
                              color: _selectedPaymentMethod == 'Net Banking'
                                  ? const Color(0xFF2A9D8F)
                                  : Colors.grey,
                              child: const Padding(
                                padding: EdgeInsets.all(30.0),
                                child: Center(
                                  child: Text(
                                    'Net Banking',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = 'Card';
                              });
                            },
                            child: Card(
                              color: _selectedPaymentMethod == 'Card'
                                  ? const Color(0xFF2A9D8F)
                                  : Colors.grey,
                              child: const Padding(
                                padding: EdgeInsets.all(30.0),
                                child: Center(
                                  child: Text(
                                    'Card',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _selectedPaymentMethod.isNotEmpty
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: _selectedPaymentMethod == 'Net Banking'
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Select Bank',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      DropdownButtonFormField<String>(
                                        decoration: InputDecoration(
                                          hintText: 'Choose a Bank',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0xFF2A9D8F),
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Color(0xFF2A9D8F),
                                                width: 1.0),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                        ),
                                        isExpanded: true,
                                        value: _selectedBank,
                                        hint: const Text('Choose a bank'),
                                        items: _banks.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedBank = newValue;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Select Card',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 10),
                                      Column(
                                        children: _cards.map((card) {
                                          return RadioListTile<String>(
                                            title: Text(
                                                '${card['name']} - ${card['number']}'),
                                            subtitle: Text(
                                                'Expiry: ${card['expiry']}'),
                                            value: card['number']!,
                                            groupValue: _selectedCard,
                                            onChanged: (String? value) {
                                              setState(() {
                                                _selectedCard = value;
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: 'Pay Now',
                      color: const Color(0xFF2A9D8F),
                      screenWidth: screenWidth,
                      onTap: () {
                        // Implement payment action here
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: CustomBottomNavigationBar(
        //   currentIndex: 2,
        //   onTap: (index) {
        //     // Handle navigation based on selected index
        //     Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(builder: (context) => DashboardScreen()),
        //     );
        //   },
        // ),
      ),
    );
  }
}
