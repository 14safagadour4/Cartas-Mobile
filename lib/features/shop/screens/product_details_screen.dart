import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../models/shop_product.dart';
import '../provider/cart_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ShopProduct product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.detailImages.isNotEmpty 
        ? widget.product.detailImages 
        : [widget.product.imagePath];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageGallery(images),
                    const SizedBox(height: 24),
                    _buildBadges(),
                    const SizedBox(height: 24),
                    _buildProductHeader(),
                    const SizedBox(height: 24),
                    _buildDescription(),
                    const SizedBox(height: 24),
                    _buildComposition(),
                    const SizedBox(height: 24),
                    _buildBenefits(),
                    const SizedBox(height: 100), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircleButton(
            icon: Icons.chevron_left,
            onTap: () => Navigator.pop(context),
          ),
          _buildCircleButton(
            icon: Icons.share_outlined,
            isGradient: true,
            onTap: () {
              // Share logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isGradient = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isGradient ? null : AppColors.petalCream.withOpacity(0.5),
          gradient: isGradient ? AppColors.roseGradient : null,
          shape: BoxShape.circle,
          boxShadow: isGradient ? [
            BoxShadow(
              color: AppColors.roseVif.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Icon(icon, color: isGradient ? Colors.white : AppColors.textPrimary, size: 24),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return SizedBox(
      height: 350,
      child: Row(
        children: [
          // Thumbnails
          SizedBox(
            width: 70,
            child: ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedImageIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.petalCream,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.roseVif : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: AppColors.roseVif.withOpacity(0.2),
                          blurRadius: 8,
                        )
                      ] : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(images[index], fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 20),
          // Main Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.petalCream.withOpacity(0.3),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Hero(
                  tag: 'product_${widget.product.id}',
                  child: Image.asset(
                    images[_selectedImageIndex],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildBadge(Icons.eco_outlined, '100% Naturel'),
          const SizedBox(width: 12),
          _buildBadge(Icons.spa_outlined, 'Fait Main'),
          const SizedBox(width: 12),
          _buildBadge(Icons.water_drop_outlined, 'Sans Additifs'),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.petalCream.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.roseMid.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.roseDeep),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.body(12, AppColors.textPrimary, weight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: AppTextStyles.title(24, AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.brand,
                style: AppTextStyles.body(14, AppColors.textMuted),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    widget.product.inStock ? Icons.check_circle_outline : Icons.error_outline,
                    size: 16,
                    color: widget.product.inStock ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.product.inStock ? 'Available In Stock' : 'Out of Stock',
                    style: AppTextStyles.body(12, AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Quantity Selector
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.petalCream.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildQtyBtn(Icons.remove, () {
                    if (_quantity > 1) setState(() => _quantity--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('$_quantity', style: AppTextStyles.title(16, AppColors.textPrimary)),
                  ),
                  _buildQtyBtn(Icons.add, () {
                    if (_quantity < widget.product.maxQuantity) {
                      setState(() => _quantity++);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Maximum ${widget.product.maxQuantity} articles autorisés', style: AppTextStyles.body(14, Colors.white))),
                      );
                    }
                  }, isPrimary: true, isEnabled: _quantity < widget.product.maxQuantity),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('Max ${widget.product.maxQuantity} unités', style: AppTextStyles.body(10, AppColors.textMuted)),
          ],
        ),
      ],
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, {bool isPrimary = false, bool isEnabled = true}) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary ? (isEnabled ? null : Colors.grey) : Colors.white,
          gradient: (isPrimary && isEnabled) ? AppColors.roseGradient : null,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isPrimary ? Colors.white : AppColors.textPrimary, size: 18),
      ),
    );
  }

  Widget _buildComposition() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.science_outlined, color: AppColors.roseDeep, size: 20),
            const SizedBox(width: 8),
            Text('Composition', style: AppTextStyles.title(18, AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.petalCream.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.roseMid.withOpacity(0.2)),
          ),
          child: Text(
            widget.product.composition,
            style: AppTextStyles.body(14, AppColors.textMuted, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    if (widget.product.benefits.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome_outlined, color: AppColors.roseDeep, size: 20),
            const SizedBox(width: 8),
            Text('Aham il 5ase2is', style: AppTextStyles.title(18, AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: widget.product.benefits.map((benefit) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.goldDeep),
                  const SizedBox(width: 8),
                  Text(benefit, style: AppTextStyles.body(13, AppColors.textPrimary, weight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: AppTextStyles.title(18, AppColors.textPrimary)),
        const SizedBox(height: 12),
        Text(
          widget.product.description,
          style: AppTextStyles.body(14, AppColors.textMuted, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${(widget.product.price * _quantity).toStringAsFixed(2)} DT',
              style: AppTextStyles.title(22, AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                context.read<CartProvider>().addItem(widget.product, _quantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.product.name} ajouté au panier !', style: AppTextStyles.body(14, Colors.white)),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  gradient: AppColors.roseGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.roseVif.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Ajouter',
                      style: AppTextStyles.title(16, Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
