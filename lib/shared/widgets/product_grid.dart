import 'package:flutter/material.dart';
import '../../core/utils/responsive.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductCard> products;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ProductGrid({
    super.key,
    required this.products,
    this.padding = const EdgeInsets.all(16),
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.gridColumns(context);

    final double cardRatio;

    if (columns == 2) {
      cardRatio = 0.55;
    } else if (columns == 3) {
      cardRatio = 0.61;
    } else if (columns == 4) {
      cardRatio = 0.64;
    } else {
      cardRatio = 0.66;
    }

    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No products available'),
        ),
      );
    }

    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
        childAspectRatio: cardRatio,
      ),
      itemBuilder: (context, index) {
        return products[index];
      },
    );
  }
}
