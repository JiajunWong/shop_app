import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/library/apis/apis.dart';
import 'package:shop_app/library/models/auth_model.dart';
import 'package:shop_app/library/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

import 'auth_provider_test.mocks.dart';

@GenerateMocks([SharedPreferences, ShopApis])
main() {
  group('auth_provider_test', () {
    late AuthProvider authProvider;
    late SharedPreferences sharedPreferences;
    late ShopApis shopApis;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      sharedPreferences = MockSharedPreferences();
      shopApis = MockShopApis();
      authProvider =
          AuthProvider.testing(Future.value(sharedPreferences), shopApis);
    });

    test('tryAutoLogin should return true when preference has cache', () async {
      final AuthModel authModel = AuthModel('token', '100', 'userId');
      when(sharedPreferences.containsKey('auth')).thenReturn(true);
      when(sharedPreferences.getString('auth'))
          .thenReturn(json.encode(authModel.toJson()));

      expect(await authProvider.tryAutoLogin(), true);
    });

    test('tryAutoLogin should return false when preference has no cache',
        () async {
      when(sharedPreferences.containsKey('auth')).thenReturn(false);

      expect(await authProvider.tryAutoLogin(), false);
    });

    test('tryAutoLogin should return true when preference has cache', () async {
      final AuthModel authModel = AuthModel('token', '0', 'userId');
      when(sharedPreferences.containsKey('auth')).thenReturn(true);
      when(sharedPreferences.getString('auth'))
          .thenReturn(json.encode(authModel.toJson()));

      expect(await authProvider.tryAutoLogin(), false);
    });

    test('isAuth should return false by default', () {
      expect(authProvider.isAuth, false);
    });

    test('isAuth should return true when preference has cache', () async {
      final AuthModel authModel = AuthModel('token', '100', 'userId');
      when(sharedPreferences.containsKey('auth')).thenReturn(true);
      when(sharedPreferences.getString('auth'))
          .thenReturn(json.encode(authModel.toJson()));

      expect(await authProvider.tryAutoLogin(), true);
      expect(authProvider.isAuth, true);
      expect(authProvider.token, 'token');
      expect(authProvider.userId, 'userId');
    });

    test('auth should success when log in success', () async {
      final AuthModel authModel = AuthModel('token', '100', 'userId');
      final response = http.Response(json.encode(authModel.toJson()), 200);
      when(shopApis.login('', ''))
          .thenAnswer((_) async => Future.value(response));
      when(sharedPreferences.setString('auth', json.encode(authModel.toJson())))
          .thenAnswer((_) async => Future.value(true));

      await authProvider.auth('', '', true);

      verify(shopApis.login('', ''));
      verify(
          sharedPreferences.setString('auth', json.encode(authModel.toJson())));
    });

    test('auth should failed when log in failed', () async {
      final response = http.Response(json.encode({
        'error':{
          'message': 'error message',
        }
      }), 400);
      when(shopApis.login('', ''))
          .thenAnswer((_) async => Future.value(response));
      when(sharedPreferences.setString('auth', ''))
          .thenAnswer((_) async => Future.value(true));

      expect(authProvider.auth('', '', true), throwsException);

      verify(shopApis.login('', ''));
      verifyNever(sharedPreferences.setString('auth', ''));
    });
  });
}
