import 'package:app/locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_sdk/stripe_sdk.dart';

import 'add_payment_method.dart';

class PaymentMethodsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    final paymentMethods = Provider.of<PaymentMethods>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment methods"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddPaymentMethod()));
//              if (added == true) await paymentMethods.refresh();
            },
          )
        ],
      ),
      body: ChangeNotifierProvider(
        create: (_) => PaymentMethods(),
        child: PaymentMethodsList(),
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String last4;
  final String brand;

  PaymentMethod(this.id, this.last4, this.brand);
}

class PaymentMethods extends ChangeNotifier {
  List<PaymentMethod> paymentMethods = List();
  Future<List<PaymentMethod>> paymentMethodsFuture;

  PaymentMethods() {
    refresh();
  }

  Future<void> refresh() {
    final session = locator.get<CustomerSession>();
    final paymentMethodFuture = session.listPaymentMethods();

//    final paymentMethodFuture = listPaymentMethods();

    return paymentMethodFuture.then((value) {
      final List listData = value['data'] ?? List<PaymentMethod>();
      if (listData.isEmpty) {
        paymentMethods = List();
      } else {
        paymentMethods =
            listData.map((item) => PaymentMethod(item['id'], item['card']['last4'], item['card']['brand'])).toList();
      }
      notifyListeners();
    });
  }
}

class PaymentMethodsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final paymentMethods = Provider.of<PaymentMethods>(context);
    final listData = paymentMethods.paymentMethods;
//    final defaultPaymentMethod = Provider.of<DefaultPaymentMethod>(context);
    if (listData == null) {
      return Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: () => paymentMethods.refresh(),
      child: buildListView(listData, paymentMethods, context),
    );
  }

  Widget buildListView(List<PaymentMethod> listData, PaymentMethods paymentMethods, BuildContext rootContext) {
    if (listData.isEmpty) {
      return ListView();
    } else {
      return ListView.builder(
          itemCount: listData.length,
          itemBuilder: (BuildContext context, int index) {
            final card = listData[index];
            return ListTile(
              onLongPress: () async {
                await showDialog(
                    context: rootContext,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Delete card"),
                        content: Text("Do you want to delete this card?"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("No"),
                            onPressed: () => Navigator.pop(rootContext),
                          ),
                          FlatButton(
                            child: Text("Yes"),
//                              onPressed: () async {
//                                Navigator.pop(rootContext);
//                                showDialog(
//                                    context: rootContext,
//                                    barrierDismissible: false,
//                                    builder: (context) => Center(child: CircularProgressIndicator()));
//                                final result = await stripeSession.detachPaymentMethod(card.id);
//                                Navigator.pop(rootContext);
//                                if (result != null) {
//                                  await paymentMethods.refresh();
//                                  Scaffold.of(rootContext).showSnackBar(SnackBar(
//                                    content: Text('Payment method successfully deleted.'),
//                                  ));
//                                }
//                              }
                          )
                        ],
                      );
                    });
              },
//              onTap: () => defaultPaymentMethod.set(card.id),
              subtitle: Text(card.last4),
              title: Text(card.brand),
              leading: Icon(Icons.credit_card),
//              trailing: card.id == defaultPaymentMethod.paymentMethodId ? Icon(Icons.check_circle) : null,
            );
          });
    }
  }
}