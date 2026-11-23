import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/produto.dart';
import 'providers/carrinho_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CarrinhoProvider(),
      child: const CarrinhoApp(),
    ),
  );
}

class CarrinhoApp extends StatelessWidget {
  const CarrinhoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrinho com Provider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CatalogoScreen(),
    );
  }
}

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  final List<Produto> _produtos = const [
    Produto(id: '1', nome: 'Teclado Mecânico', preco: 250.00),
    Produto(id: '2', nome: 'Mouse Gamer', preco: 120.00),
    Produto(id: '3', nome: 'Monitor 24"', preco: 890.00),
    Produto(id: '4', nome: 'Headset Stereo', preco: 180.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Produtos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CarrinhoScreen(),
                    ),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Consumer<CarrinhoProvider>(
                  builder: (context, carrinho, child) {
                    return carrinho.quantidade == 0
                        ? const SizedBox()
                        : CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.red,
                            child: Text(
                              '${carrinho.quantidade}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _produtos.length,
        itemBuilder: (context, index) {
          final prod = _produtos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                prod.nome,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('R\$ ${prod.preco.toStringAsFixed(2)}'),
              trailing: Consumer<CarrinhoProvider>(
                builder: (context, carrinho, child) {
                  final qtd = carrinho.quantidadeDoProduto(prod);
                  if (qtd == 0) {
                    return IconButton(
                      tooltip: 'Adicionar ao carrinho',
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.teal,
                      ),
                      onPressed: () => carrinho.adicionar(prod),
                    );
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () => carrinho.decrementar(prod),
                      ),
                      Text(
                        '$qtd',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Colors.teal),
                        onPressed: () => carrinho.adicionar(prod),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class CarrinhoScreen extends StatefulWidget {
  const CarrinhoScreen({super.key});

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  final TextEditingController _cupomController =
      TextEditingController(text: 'SENAI10');

  @override
  void dispose() {
    _cupomController.dispose();
    super.dispose();
  }

  // Exercicio 03: Dialog de confirmacao antes de executar limpar()
  Future<void> _confirmarLimparCarrinho(
    BuildContext context,
    CarrinhoProvider carrinho, {
    bool isFinalizacao = false,
  }) async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(
            isFinalizacao ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: isFinalizacao ? Colors.teal : Colors.orange,
            size: 36,
          ),
          title: Text(
            isFinalizacao ? 'Confirmar Pedido' : 'Limpar Carrinho',
          ),
          content: Text(
            isFinalizacao
                ? 'Deseja finalizar o pedido no valor de R\$ ${carrinho.valorTotal.toStringAsFixed(2)} e esvaziar o carrinho?'
                : 'Tem certeza que deseja remover todos os ${carrinho.quantidade} itens do carrinho?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isFinalizacao ? Colors.teal : Colors.red,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(isFinalizacao ? 'Confirmar Compra' : 'Sim, limpar'),
            ),
          ],
        );
      },
    );

    if (confirmado == true) {
      carrinho.limpar();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFinalizacao
                ? 'Compra finalizada com sucesso!'
                : 'Carrinho esvaziado com sucesso!',
          ),
          backgroundColor: isFinalizacao ? Colors.teal : Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seu Carrinho'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          Consumer<CarrinhoProvider>(
            builder: (context, carrinho, _) {
              if (carrinho.quantidade == 0) return const SizedBox();
              return IconButton(
                tooltip: 'Esvaziar carrinho',
                icon: const Icon(Icons.delete_sweep),
                onPressed: () => _confirmarLimparCarrinho(context, carrinho),
              );
            },
          ),
        ],
      ),
      body: Consumer<CarrinhoProvider>(
        builder: (context, carrinho, child) {
          if (carrinho.quantidade == 0) {
            return const Center(
              child: Text(
                'Seu carrinho está vazio!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Column(
            children: [
              // Exercicio 01: Lista com controle de quantidade individual (+ / -)
              Expanded(
                child: ListView.builder(
                  itemCount: carrinho.itens.length,
                  itemBuilder: (context, index) {
                    final item = carrinho.itens[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      child: ListTile(
                        title: Text(
                          item.produto.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Unitário: R\$ ${item.produto.preco.toStringAsFixed(2)} | Subtotal: R\$ ${item.subtotal.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Diminuir quantidade',
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.orange,
                              ),
                              onPressed: () => carrinho.decrementar(item.produto),
                            ),
                            Text(
                              '${item.quantidade}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Aumentar quantidade',
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.teal,
                              ),
                              onPressed: () => carrinho.adicionar(item.produto),
                            ),
                            IconButton(
                              tooltip: 'Remover produto',
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => carrinho.remover(item.produto),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Exercicio 02: Campo de Cupom de Desconto (SENAI10 = 10%)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cupomController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Cupom de Desconto (ex: SENAI10)',
                          prefixIcon: const Icon(Icons.local_offer_outlined),
                          border: const OutlineInputBorder(),
                          suffixIcon: carrinho.cupomAplicado != null
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: carrinho.removerCupom,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final ok = carrinho.aplicarCupom(_cupomController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Cupom ${carrinho.cupomAplicado} aplicado (10% OFF)!'
                                  : 'Cupom inválido. Use SENAI10 ou DESC10.',
                            ),
                            backgroundColor: ok ? Colors.green : Colors.red,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                      ),
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
              ),

              // Resumo financeiro + Finalizar (Exercicio 03)
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.teal.shade50,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal:'),
                        Text('R\$ ${carrinho.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    if (carrinho.valorDesconto > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Desconto (${carrinho.cupomAplicado} - 10%):',
                            style: const TextStyle(color: Colors.green),
                          ),
                          Text(
                            '- R\$ ${carrinho.valorDesconto.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: R\$ ${carrinho.valorTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _confirmarLimparCarrinho(
                            context,
                            carrinho,
                            isFinalizacao: true,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Finalizar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
