import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/localizacao_service.dart';

/// Tela que captura e exibe a posição atual do dispositivo.
/// Usa StatefulWidget porque a UI muda conforme o estado da busca:
/// carregando, sucesso ou erro.
class LocalizacaoScreen extends StatefulWidget {
  const LocalizacaoScreen({super.key});

  @override
  State<LocalizacaoScreen> createState() => _LocalizacaoScreenState();
}

class _LocalizacaoScreenState extends State<LocalizacaoScreen> {
  final LocalizacaoService _service = LocalizacaoService();

  Position? _posicao;
  String? _erro;
  bool _carregando = false;

  Future<void> _buscarLocalizacao() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final pos = await _service.obterPosicaoAtual();
      setState(() => _posicao = pos);
    } catch (e) {
      setState(() => _erro = e.toString());
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Localização')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(child: _construirConteudo()),
      ),
    );
  }

  /// Escolhe qual widget mostrar de acordo com o estado atual.
  Widget _construirConteudo() {
    if (_carregando) {
      return const CircularProgressIndicator();
    }
    if (_erro != null) {
      return _MensagemErro(mensagem: _erro!, onTentarNovamente: _buscarLocalizacao);
    }
    if (_posicao != null) {
      return _PosicaoCard(posicao: _posicao!, onAtualizar: _buscarLocalizacao);
    }
    return _EstadoInicial(onBuscar: _buscarLocalizacao);
  }
}

/// Estado inicial: ainda não buscamos nada.
class _EstadoInicial extends StatelessWidget {
  final VoidCallback onBuscar;
  const _EstadoInicial({required this.onBuscar});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.location_searching, size: 80),
        const SizedBox(height: 16),
        const Text('Toque no botão para capturar sua localização'),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.gps_fixed),
          label: const Text('Capturar posição'),
          onPressed: onBuscar,
        ),
      ],
    );
  }
}

/// Exibe latitude, longitude e precisão quando a captura deu certo.
class _PosicaoCard extends StatelessWidget {
  final Position posicao;
  final VoidCallback onAtualizar;
  const _PosicaoCard({required this.posicao, required this.onAtualizar});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        _linha('Latitude', posicao.latitude.toStringAsFixed(6)),
        _linha('Longitude', posicao.longitude.toStringAsFixed(6)),
        _linha('Precisão', '${posicao.accuracy.toStringAsFixed(1)} m'),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Atualizar'),
          onPressed: onAtualizar,
        ),
      ],
    );
  }

  Widget _linha(String rotulo, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '$rotulo: $valor',
          style: const TextStyle(fontSize: 18),
        ),
      );
}

/// Exibe mensagem de erro com botão para tentar novamente.
class _MensagemErro extends StatelessWidget {
  final String mensagem;
  final VoidCallback onTentarNovamente;
  const _MensagemErro({
    required this.mensagem,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        Text(mensagem, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('Tentar novamente'),
          onPressed: onTentarNovamente,
        ),
      ],
    );
  }
}
