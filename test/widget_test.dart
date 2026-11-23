import 'package:flutter_test/flutter_test.dart';
import 'package:carrinho_provider_app/models/produto.dart';
import 'package:carrinho_provider_app/providers/carrinho_provider.dart';

void main() {
  test('Valida quantidade individual, cupom de 10% e limpar() no CarrinhoProvider', () {
    final provider = CarrinhoProvider();
    const p1 = Produto(id: '1', nome: 'Teclado Mecânico', preco: 200.0);

    provider.adicionar(p1);
    provider.adicionar(p1);
    expect(provider.quantidade, 2);
    expect(provider.subtotal, 400.0);

    expect(provider.aplicarCupom('SENAI10'), true);
    expect(provider.valorTotal, 360.0);

    provider.decrementar(p1);
    expect(provider.quantidade, 1);

    provider.limpar();
    expect(provider.quantidade, 0);
  });
}
