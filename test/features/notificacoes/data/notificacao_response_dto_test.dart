import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/notificacoes/domain/entities/notificacao.dart';
import 'package:frota_mobile/features/notificacoes/data/dtos/response/notificacao_response_dto.dart';
import 'package:frota_mobile/features/notificacoes/data/dtos/response/quantidade_notificacoes_response_dto.dart';
import 'package:frota_mobile/features/notificacoes/data/mappers/notificacoes_mapper.dart';

void main() {
  test('interpreta item completo, ação, dados e datas ISO', () {
    final criadaEm = '2026-09-02T10:30:00.000Z';
    final expiraEm = '2026-10-02T10:30:00.000Z';
    final dto = NotificacaoResponseDto.fromJson({
      'id': 'notification-1',
      'tipo': 'LEMBRETE_VIAGEM',
      'titulo': 'Lembrete de viagem',
      'mensagem': 'Sua viagem está agendada.',
      'dados': {'solicitacaoId': 123},
      'acao': {
        'rota': '/solicitacoes',
        'parametros': {'solicitacaoId': '123'},
      },
      'criadaEm': criadaEm,
      'expiraEm': expiraEm,
      'lidaEm': null,
    });
    final entity = NotificacoesMapper.toEntity(dto);

    expect(entity.id, 'notification-1');
    expect(entity.naoLida, isTrue);
    expect(entity.dados['solicitacaoId'], 123);
    expect(entity.acao?.parametros['solicitacaoId'], '123');
    expect(entity.criadaEm, DateTime.parse(criadaEm).toLocal());
    expect(entity.expiraEm, DateTime.parse(expiraEm).toLocal());
  });

  test('aceita campos opcionais ausentes e lê o contador do envelope', () {
    final dto = NotificacaoResponseDto.fromJson({
      'id': 'notification-2',
      'tipo': 'LEMBRETE_VIAGEM',
      'titulo': 'Título',
      'mensagem': 'Mensagem',
      'criadaEm': '2026-09-02T10:30:00Z',
      'expiraEm': '2026-10-02T10:30:00Z',
    });
    final quantidade = QuantidadeNotificacoesResponseDto.fromJson({
      'response': {'quantidade': 4},
    });

    expect(dto.dados, isEmpty);
    expect(dto.acao, isNull);
    expect(dto.lidaEm, isNull);
    expect(quantidade.quantidade, 4);
  });

  test('reconhece todos os tipos publicados pelo backend', () {
    final tipos = {
      'LEMBRETE_VIAGEM': TipoNotificacao.lembreteViagem,
      'SOLICITACAO_CRIADA': TipoNotificacao.solicitacaoCriada,
      'SOLICITACAO_AGUARDANDO_FORNECEDOR':
          TipoNotificacao.solicitacaoAguardandoFornecedor,
      'SOLICITACAO_VIROU_CORRIDA': TipoNotificacao.solicitacaoVirouCorrida,
      'SOLICITACAO_REPROVADA': TipoNotificacao.solicitacaoReprovada,
      'SOLICITACAO_RECUSADA_FORNECEDOR':
          TipoNotificacao.solicitacaoRecusadaFornecedor,
      'SOLICITACAO_CANCELADA': TipoNotificacao.solicitacaoCancelada,
      'CORRIDA_CANCELADA': TipoNotificacao.corridaCancelada,
    };

    for (final entry in tipos.entries) {
      expect(TipoNotificacao.aPartirDoCodigo(entry.key), entry.value);
      expect(entry.value.codigo, entry.key);
    }
  });
}
