// return_screen.dart
import 'package:flutter/material.dart';
import 'package:one_smart_shop/providers/returns_provider.dart';
import 'package:one_smart_shop/screens/returns/return_form.dart';
import 'package:one_smart_shop/widgets/return_item_card.dart';
import 'package:provider/provider.dart';

class ReturnScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Returns'),
      ),
      body: FutureBuilder(
        // Initialize data on screen load
        future:
            Provider.of<ReturnsProvider>(context, listen: false).fetchReturns(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return Consumer<ReturnsProvider>(
            builder: (context, returnsProvider, _) {
              if (returnsProvider.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  Expanded(
                    child: returnsProvider.returns.isEmpty
                        ? Center(child: Text('No returns yet'))
                        : ListView.builder(
                            itemCount: returnsProvider.returns.length,
                            itemBuilder: (ctx, i) =>
                                ReturnItemCard(returnsProvider.returns[i]),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReturnForm(),
                          ),
                        );
                      },
                      child: Text('Add New Return'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
