import '../components/custom_elevated_button.dart';
import 'package:flutter/material.dart';

// TODO: make card design better
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final List<String> items = [
    'free',
    'Premium',
    'Pro',
  ];

  final List<String> itemsDesc = [
    ' 1 post / heure \n impossible a modifier \n portée de 300 m',
    ' 3 posts / heure \n modification des posts \n suppression des posts \n portée ajustable jusqu\'à 1 km ',
    ' posts ilimités \n modification des posts \n suppression des posts \n disponible sur tout le territoire \n ',
  ];

  final List<String> itemsPrice = [
    'free',
    '9,99',
    '39,99',
  ];

  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Carousel - Payment'),
      ),
      body: Center(
        child: SizedBox(
          // width: 300,
          height: 500,
          child: PageView.builder(
            controller: _pageController,
            itemCount: items.length,
            itemBuilder: (context, index) {
              int itemIndex = index;
              return _buildItem(items[itemIndex], itemsDesc[itemIndex],
                  itemsPrice[itemIndex]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String item, String desc, String price) {
    return Container(
      width: 300,
      height: 200,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(117, 66, 13, 1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Column(
        children: [
          Text(
            item,
            style: const TextStyle(color: Colors.white, fontSize: 40),
          ),
          const SizedBox(height: 100.0),
          Center(
            child: Text(
              desc,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(height: 100.0),
          Center(
            child: Text(
              price,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const SizedBox(height: 10.0),
          if (item != 'free')
            CustomElevatedButton(
                onPressed: () {
                  // TODO: add apple pay or google pay interaction
                },
                text: "payer")
        ],
      ),
    );
  }
}
