import 'package:flutter/material.dart';

/// Status possíveis de uma solicitação de corrida.
enum SolicitacaoStatus {
  aprovada,
  pendente,
  reprovada;

  String get label {
    switch (this) {
      case SolicitacaoStatus.aprovada:
        return 'Solicitação aprovada';
      case SolicitacaoStatus.pendente:
        return 'Pendente aprovação';
      case SolicitacaoStatus.reprovada:
        return 'Solicitação reprovada';
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
    }
  }

  Color get corIndicador {
    switch (this) {
      case SolicitacaoStatus.aprovada:
        return const Color(0xFF91D700);
      case SolicitacaoStatus.pendente:
        return const Color(0xFFF5A623);
      case SolicitacaoStatus.reprovada:
        return const Color(0xFFE74C3C);
    }
  }
}
