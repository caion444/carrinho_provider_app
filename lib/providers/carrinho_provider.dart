import 'package:flutter/foundation.dart';
import '../models/produto.dart';

class CarrinhoProvider extends ChangeNotifier {
  final List<ItemCarrinho> _itens = [];
  String? _cupomAplicado;
  double _percentualDesconto = 0.0;

  List<ItemCarrinho> get itens => List.unmodifiable(_itens);

  // Exercicio 01: Soma das quantidades individuais de todos os itens
  int get quantidade =>
      _itens.fold(0, (total, item) => total + item.quantidade);

  double get subtotal {
    return _itens.fold(0.0, (total, item) => total + item.subtotal);
  }

  double get valorDesconto => subtotal * _percentualDesconto;

  // Exercicio 02: Valor total ja considerando o cupom de desconto
  double get valorTotal => subtotal - valorDesconto;

  String? get cupomAplicado => _cupomAplicado;
  double get percentualDesconto => _percentualDesconto;

  int quantidadeDoProduto(Produto produto) {
    final index = _itens.indexWhere((i) => i.produto.id == produto.id);
    return index == -1 ? 0 : _itens[index].quantidade;
  }

  void adicionar(Produto produto) {
    final index = _itens.indexWhere((i) => i.produto.id == produto.id);
    if (index != -1) {
      _itens[index].quantidade++;
    } else {
      _itens.add(ItemCarrinho(produto: produto, quantidade: 1));
    }
    notifyListeners();
  }

  // Exercicio 01: Diminui 1 unidade ou remove o item se chegar a 0
  void decrementar(Produto produto) {
    final index = _itens.indexWhere((i) => i.produto.id == produto.id);
    if (index != -1) {
      if (_itens[index].quantidade > 1) {
        _itens[index].quantidade--;
      } else {
        _itens.removeAt(index);
      }
      if (_itens.isEmpty) {
        _cupomAplicado = null;
        _percentualDesconto = 0.0;
      }
      notifyListeners();
    }
  }

  void remover(Produto produto) {
    _itens.removeWhere((i) => i.produto.id == produto.id);
    if (_itens.isEmpty) {
      _cupomAplicado = null;
      _percentualDesconto = 0.0;
    }
    notifyListeners();
  }

  // Exercicio 02: Aplica cupom de 10% de desconto (SENAI10 ou DESC10)
  bool aplicarCupom(String codigo) {
    final normalizado = codigo.trim().toUpperCase();
    if (normalizado == 'SENAI10' || normalizado == 'DESC10') {
      _cupomAplicado = normalizado;
      _percentualDesconto = 0.10;
      notifyListeners();
      return true;
    }
    return false;
  }

  void removerCupom() {
    _cupomAplicado = null;
    _percentualDesconto = 0.0;
    notifyListeners();
  }

  void limpar() {
    _itens.clear();
    _cupomAplicado = null;
    _percentualDesconto = 0.0;
    notifyListeners();
  }
}
