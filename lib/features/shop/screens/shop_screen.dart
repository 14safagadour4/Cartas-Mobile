import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../models/shop_product.dart';
import '../models/shop_category.dart';
import '../provider/cart_provider.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedCategoryId = 'all';

  final List<ShopCategory> _categories = [
    const ShopCategory(id: 'all', name: 'Tous', icon: Icons.grid_view_rounded),
    const ShopCategory(id: 'huiles', name: 'Huiles', icon: Icons.opacity),
    const ShopCategory(id: 'tisanes', name: 'Tisanes', icon: Icons.emoji_food_beverage_outlined),
    const ShopCategory(id: 'packs', name: 'Packs', icon: Icons.card_giftcard),
    const ShopCategory(id: 'accessoires', name: 'Accessoires', icon: Icons.auto_awesome),
  ];

  final List<ShopProduct> _products = [
    const ShopProduct(
      id: '1',
      name: 'Coffret Botanique',
      brand: 'Clean 90 Triode Huddy',
      description: 'Assortiment premium de plantes séchées et fleurs. Parfait pour les soins quotidiens et la relaxation.',
      composition: 'Fleurs de camomille bio, pétales de rose, lavande séchée, feuilles de menthe poivrée.',
      benefits: ['Détente', 'Sommeil', 'Digestion'],
      price: 55.0,
      imagePath: 'assets/images/boutique/coffret_botanique.jpg',
      detailImages: [
        'assets/images/detailles de les produit/32.png',
        'assets/images/detailles de les produit/33.png',
    
      ],
      speedozaUri: 'https://speedoza.com/product/pack-eclat',
      categoryId: 'packs',
      maxQuantity: 3,
    ),
    const ShopProduct(
      id: '2',
      name: 'Box Cartago',
      brand: 'Édition Spéciale',
      description: 'Coffret éducatif premium sur les plantes médicinales. Contient des graines, des guides et des outils.',
      composition: 'Graines de thym, romarin, sauge, poterie artisanale, terreau enrichi.',
      benefits: ['Éducatif', 'Culture', 'Cuisine'],
      price: 65.0,
      imagePath: 'assets/images/boutique/box_cartago.jpg',
      detailImages: [
        'assets/images/detailles de les produit/35.png',
        'assets/images/detailles de les produit/36.png',
        'assets/images/detailles de les produit/38.png',
        'assets/images/detailles de les produit/39.png',
        'assets/images/detailles de les produit/40.png',
        'assets/images/detailles de les produit/37.png',
      ],
      speedozaUri: 'https://speedoza.com/product/box-cartago',
      categoryId: 'packs',
      maxQuantity: 2,
    ),
    const ShopProduct(
      id: '3',
      name: 'Soupes Artisanales',
      description: 'Préparations naturelles pour soupes avec des herbes.',
      composition: 'Mélange d\'herbes aromatiques, légumes déshydratés bio, sel marin.',
      price: 15.0,
      imagePath: 'assets/images/boutique/soupes_artisanales.jpg',
      detailImages: [
        'assets/images/detailles de les produit/11.png',
        'assets/images/detailles de les produit/12.png',
        'assets/images/detailles de les produit/13.png',
        'assets/images/detailles de les produit/14.png',
      ],
      speedozaUri: 'https://speedoza.com/product/soupes',
      categoryId: 'tisanes',
    ),
    const ShopProduct(
      id: '4',
      name: 'Maquillage Bio',
      description: 'Maquillage certifié bio, respectueux de la peau.',
      composition: 'Pigments minéraux naturels, huile de jojoba, cire d\'abeille.',
      price: 35.0,
      imagePath: 'assets/images/boutique/maquillage_bio.jpg',
      detailImages: [
        'assets/images/detailles de les produit/5.png',
        'assets/images/detailles de les produit/6.png',
        'assets/images/detailles de les produit/7.png',
        'assets/images/detailles de les produit/8.png',
        'assets/images/detailles de les produit/9.png',
        'assets/images/detailles de les produit/10.png',
      ],
      speedozaUri: 'https://speedoza.com/product/maquillage',
      categoryId: 'accessoires',
    ),
    const ShopProduct(
      id: '5',
      name: 'Infusions Florales',
      description: 'Collection de fleurs et herbes séchées avec soin.',
      composition: 'Fleurs d\'hibiscus, pétales de souci, feuilles de framboisier.',
      price: 12.0,
      imagePath: 'assets/images/boutique/infusions_florales.jpg',
      detailImages: [
        'assets/images/detailles de les produit/1.png',
        'assets/images/detailles de les produit/2.png',
        'assets/images/detailles de les produit/3.png',
        'assets/images/detailles de les produit/4.png',

      ],
      speedozaUri: 'https://speedoza.com/product/infusions',
      categoryId: 'tisanes',
    ),
    const ShopProduct(
      id: '6',
      name: 'Sérum Éclat Botanique',
      description: 'Sérum naturel aux agrumes et fleurs.',
      composition: 'Huile essentielle de néroli, extrait de citron, huile d\'argan.',
      price: 45.0,
      imagePath: 'assets/images/boutique/serum_botanique.jpg',
      detailImages: [
        'assets/images/detailles de les produit/24.png',
        'assets/images/detailles de les produit/25.png',
        'assets/images/detailles de les produit/26.png',
      ],
      speedozaUri: 'https://speedoza.com/product/serum',
      categoryId: 'huiles',
    ),
    const ShopProduct(
      id: '7',
      name: 'Soins Botaniques',
      description: 'Routine complète avec crèmes et masques purifiants.',
      composition: 'Argile verte, extrait d\'aloé vera, eau florale de rose.',
      price: 55.0,
      imagePath: 'assets/images/boutique/soins_botaniques.jpg',
      detailImages: [
        'assets/images/detailles de les produit/15.png',
        'assets/images/detailles de les produit/16.png',
        'assets/images/detailles de les produit/17.png',
        'assets/images/detailles de les produit/18.png',
        'assets/images/detailles de les produit/19.png',
        
      ],
      speedozaUri: 'https://speedoza.com/product/soins',
      categoryId: 'packs',
    ),
    const ShopProduct(
      id: '8',
      name: 'Baume à Sourcils',
      description: 'Baume naturel aux herbes pour nourrir vos sourcils.',
      composition: 'Huile de ricin, beurre de karité, extrait de romarin.',
      price: 22.0,
      imagePath: 'assets/images/boutique/baume_botanique.jpg',
      detailImages: [
        'assets/images/detailles de les produit/19.png',
        'assets/images/detailles de les produit/20.png',
        'assets/images/detailles de les produit/21.png',
        'assets/images/detailles de les produit/22.png',
        'assets/images/detailles de les produit/23.png',
        
      ],
      speedozaUri: 'https://speedoza.com/product/baume',
      categoryId: 'accessoires',
    ),
    const ShopProduct(
      id: '9',
      name: 'Atelier d\'Apothicaire',
      description: 'Kit de formulation avec mortier et plantes.',
      composition: 'Mortier en céramique, assortiment de 5 herbes de base, flacons en verre.',
      price: 120.0,
      imagePath: 'assets/images/boutique/atelier_apothicaire.jpg',
      detailImages: [
        'assets/images/detailles de les produit/42.png',
        'assets/images/detailles de les produit/43.png',
        'assets/images/detailles de les produit/44.png',
        'assets/images/detailles de les produit/45.png',
        
      ],
      speedozaUri: 'https://speedoza.com/product/atelier',
      categoryId: 'packs',
    ),
    const ShopProduct(
      id: '10',
      name: 'Savons Botaniques',
      description: 'Savons artisanaux décorés de fleurs séchées.',
      composition: 'Huile d\'olive saponifiée, beurre de coco, fleurs de calendula.',
      price: 8.0,
      imagePath: 'assets/images/boutique/savons_artisanaux.jpg',
      detailImages: [
        'assets/images/detailles de les produit/27.png',
        'assets/images/detailles de les produit/28.png',
        'assets/images/detailles de les produit/29.png',
        'assets/images/detailles de les produit/30.png',
        
      ],
      speedozaUri: 'https://speedoza.com/product/savons',
      categoryId: 'accessoires',
    ),
  ];

  List<ShopProduct> get _filteredProducts {
    if (_selectedCategoryId == 'all') return _products;
    return _products.where((p) => p.categoryId == _selectedCategoryId).toList();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.petalCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildBanner(),
            _buildCategorySelector(),
            Expanded(
              child: _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
            ),
          ),
          Column(
            children: [
              Text('Boutique', style: AppTextStyles.title(24, AppColors.roseDeep)),
              Text('Vitrine Botanique', style: AppTextStyles.body(12, AppColors.textMuted)),
            ],
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                        ],
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary, size: 20),
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${cart.itemCount}',
                            style: AppTextStyles.body(10, Colors.white, weight: FontWeight.w700),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.roseGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.roseVif.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Découvrez nos\nNouveautés',
                  style: AppTextStyles.title(20, Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '100% Naturel & Bio',
                  style: AppTextStyles.body(12, Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const Icon(Icons.eco, color: Colors.white, size: 50).animate().shake(delay: 1.seconds, duration: 1.seconds),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategoryId == cat.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.roseDeep : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected ? AppColors.roseShadow : [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  Icon(cat.icon, 
                    size: 18, 
                    color: isSelected ? Colors.white : AppColors.textMuted
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat.name,
                    style: AppTextStyles.body(13, isSelected ? Colors.white : AppColors.textPrimary, 
                      weight: isSelected ? FontWeight.w700 : FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final filtered = _filteredProducts;
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 60, color: AppColors.textDim),
            const SizedBox(height: 16),
            Text('Aucun produit trouvé', style: AppTextStyles.body(16, AppColors.textMuted)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.48,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailsScreen(product: product),
              ),
            );
          },
        ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
