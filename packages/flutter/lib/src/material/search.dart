// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'app_bar.dart';
import 'app_bar_theme.dart';
import 'color_scheme.dart';
import 'colors.dart';
import 'debug.dart';
import 'input_border.dart';
import 'input_decorator.dart';
import 'material_localizations.dart';
import 'scaffold.dart';
import 'text_field.dart';
import 'theme.dart';

/// mostra uma página de pesquisa de tela cheia e retorna o resultado da pesquisa selecionado por
/// O usuário quando a página é fechada.
////
/// A página de pesquisa consiste em uma barra de aplicativos com um campo de pesquisa e um corpo que
/// pode mostrar consultas de pesquisa sugeridas ou os resultados da pesquisa.
////
/// A aparência da página de pesquisa é determinada pelo fornecido
/// `Delegado`.A string de consulta inicial é dada por "consulta", que padroniza
/// para a string vazia.Quando a "consulta" é definida como Null, "Delegate.Query"
/// ser usado como a consulta inicial.
////
/// Este método retorna o resultado de pesquisa selecionado, que pode ser definido no
/// [SearchDelegate.Close] Chamada.Se a página de pesquisa estiver fechada com o sistema
/// Botão Voltar, retorna null.
////
/// A dado [SearchDelegate] só pode ser associado a um ativo [showearch]
/// ligar.Ligue para [SearchDelegate.Close] antes de reutilizar a mesma instância de delegação
/// para outra chamada [showearch].
////
/// O argumento `UserOotNavigator` é usado para determinar se deve empurrar o
/// página de pesquisa para o [navegador] mais distante ou mais próximo do dado
/// `contexto`.Por padrão, o 'UserOotNavigator' é `False` e a página de pesquisa
/// rota criado por este método é empurrado para o navegador mais próximo para o
//// dado "contexto".Não pode ser `null`.
////
/// A transição para a página de pesquisa acionada por este método parece melhor se o
/// Screen Disponible A transição contém um [Appbar] na parte superior e
/// transição é chamado de um [IconButton] que faz parte de [Appbar.actions].
/// A animação fornecida por [SearchDelegate.TransitionAnimation] pode ser usada
/// para acionar animações adicionais na página subjacente enquanto a pesquisa
/// página se desvanece dentro ou fora.Isso é comumente usado para animar um [animatedicon] em
/// a posição [appbar.leading] e.Do menu de hambúrguer para a seta de trás
/// usado para sair da página de pesquisa.
////
/// ## lidar com emojis e outros personagens complexos
/// {@macro flutter.widgets.editabletext.onChanged}
////
/// Veja também:
////
/// * [SearchDelegate] para definir o conteúdo da página de pesquisa.
Future<T?> showSearch<T>({
  required BuildContext context,
  required SearchDelegate<T> delegate,
  String? query = '',
  bool useRootNavigator = false,
}) {
  assert(delegate != null);
  assert(context != null);
  assert(useRootNavigator != null);
  delegate.query = query ?? delegate.query;
  delegate._currentBody = _SearchBody.suggestions;
  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push(_SearchPageRoute<T>(
    delegate: delegate,
  ));
}

/// Delegar para [ShowSearch] para definir o conteúdo da página de pesquisa.
////
/// A página de pesquisa sempre mostra um [Appbar] no topo onde os usuários podem
/// Digite suas consultas de pesquisa.Os botões mostrados antes e depois da pesquisa
/// Query Text Field pode ser personalizado via [SearchDelegate.BuildLeading]
/// e [SearchDelegate.Buildações].Além disso, um widget pode ser colocado
/// na parte inferior do [Appbar] via [SearchDelegate.BuildBottom].
////
/// O corpo abaixo do [Appbar] pode mostrar consultas sugeridas (retornadas por
/// [SearchDelegate.Buildsuggestions]) ou - Quando o usuário envia uma pesquisa - o
/// Resultados da pesquisa conforme devolvido por [SearchDelegate.Buildresults].
////
/// [searchdelegate.query] sempre contém a consulta atual inserida pelo usuário
/// e deve ser usado para construir as sugestões e resultados.
////
/// Os resultados podem ser trazidos na tela chamando [SearchDelegate.Showresults]
// e você pode voltar a mostrar as sugestões chamando
/// [SearchDelegate.Show Sugestions].
////
/// Depois que o usuário selecionou um resultado de pesquisa, [SearchDelegate.Close] deve ser
/// Chamado para remover a página de pesquisa a partir do topo da pilha de navegação e
/// para notificar o chamador do [showearch] sobre o resultado de pesquisa selecionado.
////
/// A dado [SearchDelegate] só pode ser associado a um ativo [showearch]
/// ligar.Ligue para [SearchDelegate.Close] antes de reutilizar a mesma instância de delegação
/// para outra chamada [showearch].
////
/// ## lidar com emojis e outros personagens complexos
/// {@macro flutter.widgets.editabletext.onChanged}
abstract class SearchDelegate<T> {
  /// construtor a ser chamado por subclasses que podem especificar
  /// [Searchfieldlabel], seja [SearchfieldStyle] ou [SearchfieldDecoreTheme],
  /// [keyboardtype] e / ou [textinputaction].Apenas um dos [Searchfieldlabel]
  /// e [SearchfieldDecorationTheme] pode ser não-nulo.
  ////
  /// {@toolSnippet}
  /// `` dardo
  /// classe sementeparchhintdelegate estende SearchDelegate <string> {
  /// sementeparchhintdelegate ({
  /// String NictText Necessário,
  ///}): super (
  /// Searchfieldlabel: hinttext,
  /// keyboardtype: textinputtype.text,
  /// textinpution: textinputaction.search,
  ///);
  ////
  ///   @sobrepor
  /// Widget Buildleading (Contexto BuildContext) => Const Texto ('Líder');
  ////
  ///   @sobrepor
  /// PreferredsizeWidget BuildBottom (Contexto BuildContext) {
  /// Retorna Const preferirRedize (
  /// preferível: tamanho.Fromheight (56.0),
  /// criança: texto ('inferior'));
  ///}
  ////
  ///   @sobrepor
  /// widget buildsuggestions (Contexto BuildContext) => Const Texto ('Sugestões');
  ////
  ///   @sobrepor
  /// widget buildresults (Contexto BuildContext) => Const Texto ('Resultados');
  ////
  ///   @sobrepor
  /// lista <widget> buildactions (Contexto BuildContext) => <Widget> [];
  ///}
  /// `` ``
  /// {@ fim-ferramenta}
  SearchDelegate({
    this.searchFieldLabel,
    this.searchFieldStyle,
    this.searchFieldDecorationTheme,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
  }) : assert(searchFieldStyle == null || searchFieldDecorationTheme == null);

  /// sugestões mostradas no corpo da página de pesquisa enquanto o usuário digita um
  /// consulta no campo de pesquisa.
  ////
  /// O método delegado é chamado sempre que o conteúdo de [Query] altera.
  /// As sugestões devem ser baseadas na corrente [consulta].Se a consulta
  /// string está vazio, é uma boa prática mostrar consultas sugeridas com base em
  /// consultas passadas ou o contexto atual.
  ////
  /// geralmente, este método retornará um [ListView] com um [LISTIL] por
  /// sugestão.Quando [Listile.ontap] é chamado, [Query] deve ser atualizado
  /// Com a sugestão correspondente e a página de resultados devem ser mostradas
  /// chamando [showresults].
  Widget buildSuggestions(BuildContext context);

  /// Os resultados mostrados após o usuário envia uma pesquisa na página de pesquisa.
  ////
  /// O valor atual da [consulta] pode ser usado para determinar o que o usuário
  /// procurou por.
  ////
  /// Este método pode ser aplicado mais de uma vez para a mesma consulta.
  /// Se o seu método [BuildResults] é computacionalmente caro, você pode querer
  /// para armazenar em cache os resultados da pesquisa para uma ou mais consultas.
  ////
  /// Normalmente, este método retorna um [ListView] com os resultados da pesquisa.
  /// Quando o usuário bate em um resultado de pesquisa específico, [Fechar] deve ser chamado
  /// Com o resultado selecionado como argumento.Isso fechará a página de pesquisa e
  /// Comunique o resultado de volta ao chamador inicial de [showearch].
  Widget buildResults(BuildContext context);

  /// Um widget para exibir antes da consulta atual no [Appbar].
  ////
  /// tipicamente um [iconbutton] configurado com um [BackButtonicon] que sai
  /// a pesquisa com [Fechar].Pode-se também usar um [animatedicon] acionado por
  /// [transiçãoanimação], que anima de e.Um menu de hambúrguer para o
  /// Botão Voltar à medida que a sobreposição de pesquisa desaparece.
  ////
  /// retorna null se nenhum widget deve ser mostrado.
  ////
  /// Veja também:
  ////
  /// * [Appbar.leading], o uso pretendido para o valor de retorno desse método.
  Widget? buildLeading(BuildContext context);

  /// widgets para exibir após a consulta de pesquisa no [Appbar].
  ////
  /// se o [Query] não estiver vazio, isso deve conter um botão para
  /// Limpe a consulta e mostre as sugestões novamente (via [showsugugestions]) se
  /// Os resultados são atualmente mostrados.
  ////
  /// retorna null se nenhum widget deve ser mostrado.
  ////
  /// Veja também:
  ////
  /// * [Appbar.actions], o uso pretendido para o valor de retorno deste método.
  List<Widget>? buildActions(BuildContext context);

  /// widget para exibir através da parte inferior do [Appbar].
  ////
  /// retorna nulo por padrão, isto é, um widget inferior não está incluído.
  ////
  /// Veja também:
  ////
  /// * [Appbar.bottom], o uso pretendido para o valor de retorno desse método.
  ////
  PreferredSizeWidget? buildBottom(BuildContext context) => null;

  /// O tema usado para configurar a página de pesquisa.
  ////
  /// o devolvido [temedata] será usado para envolver toda a página de pesquisa,
  /// para que possa ser usado para configurar qualquer um de seus componentes com o apropriado
  /// propriedades do tema.
  ////
  /// A menos que seja substituído, o tema padrão configurará o Appbar contendo
  /// o campo de texto de entrada de pesquisa com um fundo branco e texto preto na luz
  /// temas.Para temas escuros, o padrão é um fundo cinza escuro com luz
  /// Texto de cor.
  ////
  /// Veja também:
  ////
  /// * [Appbartheme], que configura a aparência da Appbar.
  /// * [inputdecationtheme], que configura a aparência da pesquisa
  ///    campo de texto.
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    assert(theme != null);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        brightness: colorScheme.brightness,
        backgroundColor: colorScheme.brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        iconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
        textTheme: theme.textTheme,
      ),
      inputDecorationTheme: searchFieldDecorationTheme ??
          InputDecorationTheme(
            hintStyle: searchFieldStyle ?? theme.inputDecorationTheme.hintStyle,
            border: InputBorder.none,
          ),
    );
  }

  /// A cadeia de consulta atual mostrada no [Appbar].
  ////
  /// O usuário manipula essa string através do teclado.
  ////
  /// Se o usuário torna uma sugestão fornecida por [BuildSuggestions]
  /// string deve ser atualizado para essa sugestão através do setter.
  String get query => _queryTextController.text;

  /// altera a seqüência de consulta atual.
  ////
  /// Definindo a seqüência de consulta movimenta programaticamente o cursor para o final do campo de texto.
  set query(String value) {
    assert(query != null);
    _queryTextController.text = value;
    _queryTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: _queryTextController.text.length));
  }

  /// transição das sugestões retornadas por [buildsuggestions] para o
  /// [Query] Resultados retornados por [BuildResults].
  ////
  /// se o usuário torna uma sugestão fornecida por [BuildSuggestions]
  /// tela deve tipicamente transição para a página mostrando a pesquisa
  /// resultados para a consulta sugerida.Esta transição pode ser acionada
  /// chamando este método.
  ////
  /// Veja também:
  ////
  /// * [showsugugestions] para mostrar as sugestões de pesquisa novamente.
  void showResults(BuildContext context) {
    _focusNode?.unfocus();
    _currentBody = _SearchBody.results;
  }

  /// transição de mostrar os resultados retornados por [BuildResults] para mostrar
  /// As sugestões retornadas por [buildsuggestions].
  ////
  /// chamando este método também colocará o foco de entrada de volta na pesquisa
  /// campo do [Appbar].
  ////
  /// Se os resultados são mostrados atualmente, este método pode ser usado para voltar para voltar
  /// para mostrar as sugestões de pesquisa.uisa.
  ////
  /// Veja também:
  ////
  /// * [ShowResults] para mostrar os resultados da pesquisa.
  void showSuggestions(BuildContext context) {
    assert(_focusNode != null,
        '_focusNode must be set by route before showSuggestions is called.');
    _focusNode!.requestFocus();
    _currentBody = _SearchBody.suggestions;
  }

  /// fecha a página de pesquisa e retorna à rota subjacente.
  ////
  /// O valor fornecido para o `resultado é usado como o valor de retorno da chamada
  /// para [showearch] que lançou a pesquisa inicialmente.
  void close(BuildContext context, T result) {
    _currentBody = null;
    _focusNode?.unfocus();
    Navigator.of(context)
      ..popUntil((Route<dynamic> route) => route == _route)
      ..pop(result);
  }

  /// O texto da dica que é mostrado no campo de pesquisa quando está vazio.
  ////
  /// Se este valor estiver definido como NULL, o valor de
  /// `materiallocalizações.of (contexto) .Searchfieldlabel` será usado em vez disso.
  final String? searchFieldLabel;

  /// O estilo do [Searchfieldlabel].
  ////
  /// Se este valor for definido como NULL, o valor do ambiente [tema] 's
  /// [inputdecationtheme.hintstyle] será usado em vez disso.
  ////
  /// Apenas um dos [SearchfieldStyle] ou [SearchfieldDecoreTheme] pode
  /// seja não-nulo.
  final TextStyle? searchFieldStyle;

  /// O [INPUTDECORTETHEME] usado para configurar os visuais do campo de pesquisa.
  ////
  /// Apenas um dos [SearchfieldStyle] ou [SearchfieldDecoreTheme] pode
  /// seja não-nulo.
  final InputDecorationTheme? searchFieldDecorationTheme;

  /// O tipo de botão de ação para usar para o teclado.
  ////
  /// é padronizado para o valor padrão especificado em [TextField].
  final TextInputType? keyboardType;

  /// a ação de entrada de texto Configurando o teclado macio para uma ação específica
  /// botão.
  ////
  /// é padronizado para [textinputaction.search].
  final TextInputAction textInputAction;

  /// [animação] acionado quando as páginas de pesquisa se desvanecem dentro ou para fora.
  ////
  /// Esta animação é comumente usada para animar [animatedicon] s de
  /// [IconButton] S devolvido por [Buildleading] ou [Buildactions].Também pode ser
  /// usado para animar [iconbutton] s contido na rota abaixo da pesquisa
  /// página.
  Animation<double> get transitionAnimation => _proxyAnimation;

  // The focus node to use for manipulating focus on the search page. This is
  // managed, owned, and set by the _SearchPageRoute using this delegate.
  FocusNode? _focusNode;

  final TextEditingController _queryTextController = TextEditingController();

  final ProxyAnimation _proxyAnimation =
      ProxyAnimation(kAlwaysDismissedAnimation);

  final ValueNotifier<_SearchBody?> _currentBodyNotifier =
      ValueNotifier<_SearchBody?>(null);

  _SearchBody? get _currentBody => _currentBodyNotifier.value;
  set _currentBody(_SearchBody? value) {
    _currentBodyNotifier.value = value;
  }

  _SearchPageRoute<T>? _route;
}

/// descreve o corpo atualmente mostrado sob o [Appbar] no
/// página de pesquisa.
enum _SearchBody {
  /// perguntas sugeridas são mostradas no corpo.
  ////
  /// As consultas sugeridas são geradas por [SearchDelegate.Buildsuggestions].
  suggestions,

  /// Os resultados da pesquisa são mostrados atualmente no corpo.
  ////
  /// Os resultados da pesquisa são gerados por [SearchDelegate.Buildresults].
  results,
}

class _SearchPageRoute<T> extends PageRoute<T> {
  _SearchPageRoute({
    required this.delegate,
  }) : assert(delegate != null) {
    assert(
      delegate._route == null,
      'The ${delegate.runtimeType} instance is currently used by another active '
      'search. Please close that search by calling close() on the SearchDelegate '
      'before opening another search with the same delegate instance.',
    );
    delegate._route = this;
  }

  final SearchDelegate<T> delegate;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => false;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  Animation<double> createAnimation() {
    final Animation<double> animation = super.createAnimation();
    delegate._proxyAnimation.parent = animation;
    return animation;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _SearchPage<T>(
      delegate: delegate,
      animation: animation,
    );
  }

  @override
  void didComplete(T? result) {
    super.didComplete(result);
    assert(delegate._route == this);
    delegate._route = null;
    delegate._currentBody = null;
  }
}

class _SearchPage<T> extends StatefulWidget {
  const _SearchPage({
    required this.delegate,
    required this.animation,
  });

  final SearchDelegate<T> delegate;
  final Animation<double> animation;

  @override
  State<StatefulWidget> createState() => _SearchPageState<T>();
}

class _SearchPageState<T> extends State<_SearchPage<T>> {
  // This node is owned, but not hosted by, the search page. Hosting is done by
  // the text field.
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.delegate._queryTextController.addListener(_onQueryChanged);
    widget.animation.addStatusListener(_onAnimationStatusChanged);
    widget.delegate._currentBodyNotifier.addListener(_onSearchBodyChanged);
    focusNode.addListener(_onFocusChanged);
    widget.delegate._focusNode = focusNode;
  }

  @override
  void dispose() {
    super.dispose();
    widget.delegate._queryTextController.removeListener(_onQueryChanged);
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    widget.delegate._currentBodyNotifier.removeListener(_onSearchBodyChanged);
    widget.delegate._focusNode = null;
    focusNode.dispose();
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    widget.animation.removeStatusListener(_onAnimationStatusChanged);
    if (widget.delegate._currentBody == _SearchBody.suggestions) {
      focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(_SearchPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      oldWidget.delegate._queryTextController.removeListener(_onQueryChanged);
      widget.delegate._queryTextController.addListener(_onQueryChanged);
      oldWidget.delegate._currentBodyNotifier
          .removeListener(_onSearchBodyChanged);
      widget.delegate._currentBodyNotifier.addListener(_onSearchBodyChanged);
      oldWidget.delegate._focusNode = null;
      widget.delegate._focusNode = focusNode;
    }
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus &&
        widget.delegate._currentBody != _SearchBody.suggestions) {
      widget.delegate.showSuggestions(context);
    }
  }

  void _onQueryChanged() {
    setState(() {
      // rebuild ourselves because query changed.
    });
  }

  void _onSearchBodyChanged() {
    setState(() {
      // rebuild ourselves because search body changed.
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final ThemeData theme = widget.delegate.appBarTheme(context);
    final String searchFieldLabel = widget.delegate.searchFieldLabel ??
        MaterialLocalizations.of(context).searchFieldLabel;
    Widget? body;
    switch (widget.delegate._currentBody) {
      case _SearchBody.suggestions:
        body = KeyedSubtree(
          key: const ValueKey<_SearchBody>(_SearchBody.suggestions),
          child: widget.delegate.buildSuggestions(context),
        );
        break;
      case _SearchBody.results:
        body = KeyedSubtree(
          key: const ValueKey<_SearchBody>(_SearchBody.results),
          child: widget.delegate.buildResults(context),
        );
        break;
      case null:
        break;
    }

    late final String routeName;
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        routeName = '';
        break;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        routeName = searchFieldLabel;
    }

    return Semantics(
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: true,
      label: routeName,
      child: Theme(
        data: theme,
        child: Scaffold(
          appBar: AppBar(
            leading: widget.delegate.buildLeading(context),
            title: TextField(
              controller: widget.delegate._queryTextController,
              focusNode: focusNode,
              style: theme.textTheme.headline6,
              textInputAction: widget.delegate.textInputAction,
              keyboardType: TextInputType.text,
              onSubmitted: (String _) {
                widget.delegate.showResults(context);
              },
              decoration: InputDecoration(hintText: searchFieldLabel),
            ),
            actions: widget.delegate.buildActions(context),
            bottom: widget.delegate.buildBottom(context),
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: body,
          ),
        ),
      ),
    );
  }
}
