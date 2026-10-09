import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frota_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:frota_mobile/features/auth/data/models/usuario_model.dart';
import 'package:frota_mobile/features/auth/domain/entities/auth_token.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('logout removes user, access/refresh and temporary tokens', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final local = AuthLocalDatasourceImpl(sharedPreferences: preferences);
    const user = UsuarioModel(nome: 'Teste', email: 'teste@example.com');
    await local.salvarUsuario(user);
    await local.salvarUsuarioPendente(user);
    await local.salvarAuthToken(
      AuthToken(
        accessToken: 'access-test',
        refreshToken: 'refresh-test',
        expirationDate: DateTime.utc(2030),
      ),
    );
    await local.salvarSignUpToken('sign-up-test');
    await local.salvarRedefinirSenhaToken('reset-test');
    await preferences.setString('trip_tracking_positions_42', 'position-test');

    await local.removerSessao();

    expect(preferences.getString('usuario_logado'), isNull);
    expect(await local.getUsuarioPendente(), isNull);
    expect(await local.getAuthToken(), isNull);
    expect(await local.getSignUpToken(), isNull);
    expect(await local.getRedefinirSenhaToken(), isNull);
    expect(preferences.getString('trip_tracking_positions_42'), isNull);
  });
}
