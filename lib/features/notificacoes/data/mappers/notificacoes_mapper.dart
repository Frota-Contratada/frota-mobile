import '../../domain/entities/notificacao.dart';
import '../dtos/response/notificacao_response_dto.dart';

class NotificacoesMapper {
  static Notificacao toEntity(NotificacaoResponseDto dto) {
    return Notificacao(
      id: dto.id,
      tipo: TipoNotificacao.aPartirDoCodigo(dto.tipo),
      titulo: dto.titulo,
      mensagem: dto.mensagem,
      dados: dto.dados,
      acao: dto.acao == null
          ? null
          : AcaoNotificacao(
              rota: dto.acao!.rota,
              parametros: dto.acao!.parametros,
            ),
      criadaEm: _paraLocal(dto.criadaEm),
      expiraEm: _paraLocal(dto.expiraEm),
      lidaEm: dto.lidaEm == null ? null : _paraLocal(dto.lidaEm!),
    );
  }

  static DateTime _paraLocal(String iso) => DateTime.parse(iso).toLocal();
}
