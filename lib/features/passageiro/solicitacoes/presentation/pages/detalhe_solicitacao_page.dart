import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../widgets/solicitacao_status.dart';

/// Página de detalhes de uma solicitação do passageiro.
/// Adapta o conteúdo com base no status: aprovada, pendente ou recusada.
/// Tela "Detalhes da corrida feita" quando a corrida já foi realizada.
class DetalheSolicitacaoPage extends StatelessWidget {
  final SolicitacaoStatus status;
  final String origem;
  final String destino;
  final String data;
  final String horarioPartida;
  final String? horarioChegada;
  final String? valor;
  final String? motivo;
  final String? motivoReprovacao;
  final String? motorista;
  final String? placa;
  final bool corridaRealizada;
  final MapPoint? origemPoint;
  final MapPoint? destinoPoint;

  const DetalheSolicitacaoPage({
    super.key,
    required this.status,
    required this.origem,
    required this.destino,
    required this.data,
    required this.horarioPartida,
    this.horarioChegada,
    this.valor,
    this.motivo,
    this.motivoReprovacao,
    this.motorista,
    this.placa,
    this.corridaRealizada = false,
    this.origemPoint,
    this.destinoPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mapa com a rota e os marcadores de origem/destino.
                    SizedBox(
                      height: 198,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: MapRoutePreview(
                          originAddress: origem,
                          destinationAddress: destino,
                          origin: origemPoint,
                          destination: destinoPoint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badge status (apenas para solicitações, não para corrida feita)
                          if (!corridaRealizada) ...[
                            _buildStatusBadge(),
                            const SizedBox(height: 16),
                          ],

                          // Motivo reprovação (se recusada)
                          if (status == SolicitacaoStatus.reprovada && motivoReprovacao != null) ...[
                            const Text(
                              'Motivo da reprovação',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              motivoReprovacao!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.darkBlue,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.borderGrey),
                            const SizedBox(height: 12),
                          ],

                          // Origem
                          _buildInfoRow(
                            iconWidget: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            label: 'Origem',
                            valor: origem,
                          ),
                          _buildLinhaConectora(),
                          // Destino
                          _buildInfoRow(
                            iconWidget: Image.asset(
                              AppAssets.iconDestino,
                              width: 12,
                              height: 15,
                              fit: BoxFit.contain,
                              color: AppColors.primaryBlue,
                            ),
                            label: 'Destino',
                            valor: destino,
                          ),
                          const SizedBox(height: 20),

                          // Data
                          _buildInfoRow(
                            iconWidget: Image.asset(
                              AppAssets.iconData,
                              width: 12,
                              height: 14,
                              fit: BoxFit.contain,
                              color: AppColors.primaryBlue,
                            ),
                            label: 'Data',
                            valor: data,
                          ),
                          const SizedBox(height: 20),

                          // Horário de partida
                          _buildInfoRow(
                            iconWidget: Image.asset(
                              AppAssets.iconHorario,
                              width: 12,
                              height: 12,
                              fit: BoxFit.contain,
                              color: AppColors.primaryBlue,
                            ),
                            label: 'Horário de partida',
                            valor: horarioPartida,
                          ),
                          const SizedBox(height: 20),

                          // Horário de chegada
                          if (horarioChegada != null) ...[
                            _buildInfoRow(
                              iconWidget: Image.asset(
                                AppAssets.iconHorario,
                                width: 12,
                                height: 12,
                                fit: BoxFit.contain,
                                color: AppColors.primaryBlue,
                              ),
                              label: _labelHorarioChegada(),
                              valor: horarioChegada!,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Valor
                          if (valor != null) ...[
                            _buildInfoRow(
                              iconWidget: Image.asset(
                                AppAssets.iconCusto,
                                width: 12,
                                height: 10,
                                fit: BoxFit.contain,
                                color: AppColors.primaryBlue,
                              ),
                              label: _labelValor(),
                              valor: valor!,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Motorista (apenas para corrida feita)
                          if (motorista != null) ...[
                            _buildInfoRow(
                              iconWidget: Image.asset(
                                AppAssets.iconFuncionario,
                                width: 12,
                                height: 13,
                                fit: BoxFit.contain,
                                color: AppColors.primaryBlue,
                              ),
                              label: 'Nome do motorista',
                              valor: motorista!,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Placa (apenas para corrida feita)
                          if (placa != null) ...[
                            _buildInfoRow(
                              iconWidget: Image.asset(
                                AppAssets.iconVeiculo,
                                width: 12,
                                height: 10,
                                fit: BoxFit.contain,
                                color: AppColors.primaryBlue,
                              ),
                              label: 'Placa do veículo',
                              valor: placa!,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Motivo
                          if (motivo != null) ...[
                            _buildInfoRow(
                              iconWidget: Image.asset(
                                AppAssets.iconMotivo,
                                width: 12,
                                height: 12,
                                fit: BoxFit.contain,
                                color: AppColors.primaryBlue,
                              ),
                              label: _labelMotivo(),
                              valor: motivo!,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Botão cancelar (apenas para pendente)
                          if (status == SolicitacaoStatus.pendente) ...[
                            const SizedBox(height: 20),
                            _buildCancelarButton(context),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Image.asset(
              AppAssets.iconVoltar,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            'Detalhes da corrida',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Row(
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            color: status.corIndicador,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          status.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required Widget iconWidget,
    required String label,
    required String valor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: iconWidget,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinhaConectora() {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Container(
        width: 2,
        height: 20,
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: AppColors.borderGrey,
      ),
    );
  }

  String _labelHorarioChegada() {
    if (corridaRealizada) return 'Horário de chegada';
    return 'Horário estimado de chegada';
  }

  String _labelValor() {
    if (corridaRealizada) return 'Valor da corrida';
    return 'Valor estimado da corrida';
  }

  String _labelMotivo() {
    if (corridaRealizada) return 'Motivo';
    return 'Motivo da viagem';
  }

  Widget _buildCancelarButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 245,
        height: 60,
        child: ElevatedButton(
          onPressed: () => _confirmarCancelamento(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Cancelar solicitação',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _confirmarCancelamento(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tem certeza de que deseja cancelar essa solicitação?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 37,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Não',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 37,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Sim',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
