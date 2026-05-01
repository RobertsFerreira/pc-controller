// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Control Hub';

  @override
  String get navigationCategories => 'Categorias';

  @override
  String get navHome => 'Inicio';

  @override
  String get navAudio => 'Mesa de audio';

  @override
  String get homeTitle => 'Painel inicial';

  @override
  String get homeDescription =>
      'Escolha um modulo no menu lateral para navegar entre as areas do app.';

  @override
  String get homePlaceholder => 'Selecione uma area para comecar';

  @override
  String get audioPageEyebrow => 'Painel ao vivo';

  @override
  String get audioPageTitle => 'Audio em tempo real';

  @override
  String get audioPageDescription =>
      'Escolha uma saida e acompanhe, em uma unica tela, quais aplicativos estao usando esse audio agora.';

  @override
  String get audioHeroBadge => 'Estudio rapido';

  @override
  String get audioHeroTitle => 'Controle o som sem adivinhacao';

  @override
  String get audioHeroDescription =>
      'Veja a saida ativa, os aplicativos em reproducao e o volume de cada sessao em uma mesa de controle mais clara.';

  @override
  String get audioHeroDevicesMetric => 'Saidas prontas';

  @override
  String get audioHeroAppsMetric => 'Apps monitorados';

  @override
  String get audioHeroMutedMetric => 'Silenciados';

  @override
  String get audioSelectorTitle => 'Destino do som';

  @override
  String get audioSelectorDescription =>
      'Escolha onde voce quer inspecionar o audio deste computador.';

  @override
  String get audioSelectorFieldLabel => 'Saida de audio';

  @override
  String get audioSelectorFieldHint => 'Selecione uma saida';

  @override
  String audioSelectorDevicesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saidas disponiveis',
      one: '1 saida disponivel',
    );
    return '$_temp0';
  }

  @override
  String get audioSelectorRefresh => 'Atualizar saidas';

  @override
  String get audioSelectorReloadSessions => 'Atualizar apps';

  @override
  String get audioSelectorDeviceFallback => 'Saida sem nome';

  @override
  String get audioOverviewTitle => 'Leitura rapida';

  @override
  String get audioOverviewEmpty =>
      'Selecione uma saida para ver um resumo ao vivo dos aplicativos e do status geral.';

  @override
  String get audioOverviewDeviceId => 'Identificador';

  @override
  String audioOverviewAppsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aplicativos',
      one: '1 aplicativo',
    );
    return '$_temp0';
  }

  @override
  String get audioOverviewMuted => 'Ha apps silenciados';

  @override
  String get audioOverviewLive => 'Conexao ativa';

  @override
  String get audioSessionsTitle => 'Aplicativos com som';

  @override
  String get audioSessionsDescription =>
      'Cada card mostra volume, atividade atual e silenciamento da sessao.';

  @override
  String get audioSessionsLiveChip => 'Atualizacao ao vivo';

  @override
  String get audioSessionsEmptyName => 'Aplicativo sem nome';

  @override
  String audioSessionsIdLabel(String id) {
    return 'ID $id';
  }

  @override
  String get audioLoadingDevicesTitle => 'Carregando saidas';

  @override
  String get audioLoadingDevicesMessage =>
      'Buscando os destinos de audio disponiveis no computador.';

  @override
  String get audioDevicesErrorTitle => 'Nao foi possivel carregar as saidas';

  @override
  String get audioDevicesErrorMessage => 'Tente novamente em alguns instantes.';

  @override
  String get audioDevicesEmptyTitle => 'Nenhuma saida encontrada';

  @override
  String get audioDevicesEmptyMessage =>
      'Conecte um dispositivo de audio e atualize a lista para continuar.';

  @override
  String get audioSelectPromptTitle => 'Escolha uma saida para continuar';

  @override
  String get audioSelectPromptMessage =>
      'Assim que voce selecionar a saida, os aplicativos com som aparecerao aqui.';

  @override
  String get audioSessionsLoadingTitle => 'Atualizando aplicativos';

  @override
  String get audioSessionsLoadingMessage =>
      'Buscando as sessoes de audio da saida selecionada.';

  @override
  String get audioSessionsErrorTitle =>
      'Nao foi possivel carregar os aplicativos';

  @override
  String get audioSessionsErrorMessage =>
      'Tente novamente com outra saida ou atualize a lista.';

  @override
  String get audioSessionsEmptyTitle => 'Nenhum aplicativo com audio visivel';

  @override
  String get audioSessionsEmptyMessage =>
      'Quando algum app reproduzir som nessa saida, ele aparecera neste painel.';

  @override
  String get audioSessionActive => 'Em reproducao';

  @override
  String get audioSessionInactive => 'Sem atividade';

  @override
  String get audioSessionExpired => 'Encerrado';

  @override
  String get audioSessionMuted => 'Silenciado';

  @override
  String get audioSessionUnmuted => 'Audio ativo';
}
