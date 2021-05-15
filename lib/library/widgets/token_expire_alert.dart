import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/library/providers/auth_provider.dart';

class TokenExpireAlert extends StatelessWidget {
  const TokenExpireAlert();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Token has expired',
            style: Theme.of(context).textTheme.headline5,
          ),
          SizedBox(
            height: 16,
          ),
          Text(
            'Please login or signup again.',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
