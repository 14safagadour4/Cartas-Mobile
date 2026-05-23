import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import '../models/post_model.dart';
import '../providers/community_provider.dart';
import 'comment_section.dart';

class PostCard extends StatelessWidget {
  final CommunityPost post;

  const PostCard({super.key, required this.post});

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildOptionsSheet(context),
    );
  }

  Widget _buildOptionsSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.petalCream,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          // Top Action Row (Save, Remix, QR)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRoundAction(Icons.bookmark_border_rounded, 'Enregistrer'),
              _buildRoundAction(Icons.cached_rounded, 'Remixer'),
              _buildRoundAction(Icons.qr_code_scanner_rounded, 'Code QR'),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.petalCream),
          // List Options
          _buildListOption(Icons.star_border_rounded, 'Ajouter aux favoris'),
          _buildListOption(Icons.person_remove_outlined, 'Ne plus suivre'),
          _buildListOption(Icons.closed_caption_off_rounded, 'Sous-titres'),
          _buildListOption(Icons.info_outline_rounded, 'Pourquoi vous voyez cette publication'),
          _buildListOption(Icons.visibility_off_outlined, 'Masquer'),
          _buildListOption(Icons.account_circle_outlined, 'À propos de ce compte'),
          _buildListOption(Icons.report_gmailerrorred_rounded, 'Signaler', isDestructive: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRoundAction(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.petalCream),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.body(12, AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildListOption(IconData icon, String label, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.textPrimary),
      title: Text(
        label,
        style: AppTextStyles.body(14, isDestructive ? Colors.red : AppColors.textPrimary, weight: FontWeight.w500),
      ),
      onTap: () {},
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentSection(postId: post.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildContent(),
          if (post.images.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildImages(),
          ],
          const SizedBox(height: 20),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.roseDeep.withOpacity(0.1), width: 2),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(post.authorAvatar),
            onBackgroundImageError: (_, __) {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(post.authorName, style: AppTextStyles.title(16, AppColors.textPrimary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, color: Colors.blue, size: 14),
                ],
              ),
              Text(post.timeAgo, style: AppTextStyles.body(12, AppColors.textMuted)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
          onPressed: () => _showPostOptions(context),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      post.content,
      style: AppTextStyles.body(14, AppColors.textPrimary, height: 1.6),
    );
  }

  Widget _buildImageWidget(String path, {double? width, double? height, BoxFit fit = BoxFit.cover, BorderRadius? borderRadius}) {
    final Widget image = path.startsWith('http')
        ? Image.network(
            path,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.petalCream, 
              child: const Icon(Icons.broken_image, color: AppColors.textMuted)
            ),
          )
        : Image.asset(
            path,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.petalCream, 
              child: const Icon(Icons.broken_image, color: AppColors.textMuted)
            ),
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius, child: image);
    }
    return image;
  }

  Widget _buildImages() {
    if (post.images.length == 1) {
      return _buildImageWidget(
        post.images[0],
        width: double.infinity,
        height: 220,
        borderRadius: BorderRadius.circular(20),
      );
    } else if (post.images.length >= 5) {
      return SizedBox(
        height: 240,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildImageWidget(
                post.images[0],
                height: 240,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildImageWidget(post.images[1])),
                        const SizedBox(width: 4),
                        Expanded(child: _buildImageWidget(post.images[2], borderRadius: const BorderRadius.only(topRight: Radius.circular(20)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildImageWidget(post.images[3])),
                        const SizedBox(width: 4),
                        Expanded(child: _buildImageWidget(post.images[4], borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (post.images.length >= 3) {
      return SizedBox(
        height: 260,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildImageWidget(
                post.images[0],
                height: 260,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _buildImageWidget(
                      post.images[1],
                      width: double.infinity,
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(20)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: _buildImageWidget(
                      post.images[2],
                      width: double.infinity,
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return _buildImageWidget(
      post.images[0],
      height: 220,
      width: double.infinity,
      borderRadius: BorderRadius.circular(20),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildInteractionBtn(
              icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              count: post.likes.toString(),
              color: post.isLiked ? Colors.red : AppColors.textMuted,
              onTap: () => context.read<CommunityProvider>().toggleLike(post.id),
            ),
            const SizedBox(width: 20),
            _buildInteractionBtn(
              icon: Icons.chat_bubble_outline_rounded,
              count: post.comments.toString(),
              color: AppColors.textMuted,
              onTap: () => _showComments(context),
            ),
            const SizedBox(width: 20),
            _buildInteractionBtn(
              icon: Icons.group_outlined,
              count: post.shares.toString(),
              color: AppColors.textMuted,
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.textMuted),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildInteractionBtn({
    required IconData icon,
    required String count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 8),
          Text(count, style: AppTextStyles.body(14, color, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
