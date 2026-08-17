import 'package:flutter/material.dart';
import '../../domain/entities/status_solicitacao.dart';

enum SolicitacaoStatus {
  aprovada,
  pendente,
  reprovada,
  cancelada;

  static SolicitacaoStatus deDominio(StatusSolicitacao status) {
    return switch (status) {
      StatusSolicitacao.aprovada => SolicitacaoStatus.aprovada,
      StatusSolicitacao.pendente => SolicitacaoStatus.pendente,
      StatusSolicitacao.reprovada => SolicitacaoStatus.reprovada,
      StatusSolicitacao.cancelada => SolicitacaoStatus.cancelada,
    };
  }

  String get label {
    switch (this) {
      case SolicitacaoStatus.aprovada:
        return 'Solicitação aprovada';
      case SolicitacaoStatus.pendente:
        return 'Pendente aprovação';
      case SolicitacaoStatus.reprovada:
        return 'Solicitação reprovada';
      case SolicitacaoStatus.cancelada:
        return 'Solicitação cancelada';
    }
  }

  String get labelGrupo {
    switch (this) {
      case SolicitacaoStatus.aprovada:
        return 'Solicitações aprovadas';
      case SolicitacaoStatus.pendente:
        return 'Solicitações pendentes';
      case SolicitacaoStatus.reprovada:
        return 'Solicitações reprovadas';
      case SolicitacaoStatus.cancelada:
        return 'Solicitações canceladas';
    }
  }

  Color get cor {
    switch (this) {
      case SolicitacaoStatus.aprovada:
        return const Color(0xFF91D700);
      case SolicitacaoStatus.pendente:
        return const Color(0xFFF5A623);
      case SolicitacaoStatus.reprovada:
        return const Color(0xFFE74C3C);
      case SolicitacaoStatus.cancelada:
        return const Color(0xFF8A94A6);
    }
  }

  Color get corIndicador => cor;
}
