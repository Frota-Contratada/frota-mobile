import 'package:equatable/equatable.dart';
import 'notificacao.dart';

class ToqueNotificacao extends Equatable {
  final String? notificacaoId;
  final AcaoNotificacao? acao;

  const ToqueNotificacao({this.notificacaoId, this.acao});

  @override
  List<Object?> get props => [notificacaoId, acao];
}
