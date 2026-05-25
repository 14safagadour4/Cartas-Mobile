import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../provider/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Mon Panier', style: AppTextStyles.title(20, AppColors.roseDeep)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
            onPressed: () {
              context.read<CartProvider>().clear();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: AppColors.roseMid.withOpacity(0.5)),
                  const SizedBox(height: 20),
                  Text('Votre panier est vide', style: AppTextStyles.title(18, AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Text('Découvrez nos produits botaniques.', style: AppTextStyles.body(14, AppColors.textMuted)),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.roseDeep,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text('Continuer mes achats', style: AppTextStyles.body(14, Colors.white, weight: FontWeight.w600)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final cartItem = cart.items.values.toList()[index];
                    return _buildCartItem(context, cartItem, cart);
                  },
                ),
              ),
              _buildCheckoutBar(context, cart.totalAmount),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem cartItem, CartProvider cart) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.petalCream.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(cartItem.product.imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.name,
                  style: AppTextStyles.title(16, AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${cartItem.product.price.toStringAsFixed(2)} DT',
                  style: AppTextStyles.body(14, AppColors.goldDeep, weight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                // Quantity Controls
                Row(
                  children: [
                    _buildQtyBtn(
                      icon: Icons.remove,
                      onTap: () {
                        cart.updateQuantity(cartItem.product.id, cartItem.quantity - 1);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${cartItem.quantity}', style: AppTextStyles.title(14, AppColors.textPrimary)),
                    ),
                    _buildQtyBtn(
                      icon: Icons.add,
                      onTap: cartItem.quantity < cartItem.product.maxQuantity 
                          ? () { cart.updateQuantity(cartItem.product.id, cartItem.quantity + 1); }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn({required IconData icon, VoidCallback? onTap}) {
    final bool isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.petalCream : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: isEnabled ? AppColors.textPrimary : Colors.grey),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.body(16, AppColors.textMuted)),
                Text('${total.toStringAsFixed(2)} DT', style: AppTextStyles.title(24, AppColors.roseDeep)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Commande validée !', style: AppTextStyles.body(14, Colors.white)),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.read<CartProvider>().clear();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.roseDeep,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Passer à la caisse', style: AppTextStyles.title(16, Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
