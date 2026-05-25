import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final String subjectTitle;
  final String imagePath;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.subjectTitle,
    required this.imagePath,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [
    {'name': 'Mahdi', 'avatar': 'mahdi', 'text': 'Super conseils ! Merci pour le partage, je vais tester ça dès demain.'},
    {'name': 'Sara', 'avatar': 'olivia', 'text': 'Le compost maison change vraiment tout, je confirme !'},
  ];
  String _userName = 'Moi';
  bool _isLiked = false;
  bool _isSaved = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _likeCount = 128 + (widget.post['likes'] as int? ?? 0);
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        final firstName = prefs.getString('firstName') ?? 'Utilisateur';
        final lastName = prefs.getString('lastName') ?? '';
        _userName = '$firstName $lastName';
      });
    }
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add({
          'name': _userName,
          'avatar': '62d42fb5d9b7d594b95f9797c2bb5f27',
          'text': _commentController.text,
        });
        _commentController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commentaire ajouté !'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partager la publication', style: AppTextStyles.title(18, AppColors.textPrimary)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(Icons.facebook, 'Facebook', Colors.blue),
                _buildShareOption(Icons.wechat, 'WhatsApp', Colors.green),
                _buildShareOption(Icons.messenger_outline, 'Messenger', Colors.blueAccent),
                _buildShareOption(Icons.email_outlined, 'Email', Colors.orange),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.petalCream, shape: BoxShape.circle),
                child: const Icon(Icons.link_rounded, color: AppColors.roseDeep),
              ),
              title: const Text('Copier le lien'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lien copié !'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.body(10, AppColors.textMuted, weight: FontWeight.bold)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F5),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorInfo(),
                  const SizedBox(height: 24),
                  Text(widget.post['title'], style: AppTextStyles.title(24, AppColors.roseDeep)),
                  const SizedBox(height: 16),
                  _buildTags(),
                  const SizedBox(height: 24),
                  _buildContent(),
                  const SizedBox(height: 32),
                  _buildPostImage(),
                  const SizedBox(height: 32),
                  _buildInteractions(),
                  const SizedBox(height: 40),
                  _buildCommentSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomInput(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.roseDeep),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border_rounded, color: _isLiked ? Colors.red : AppColors.roseDeep), 
          onPressed: _toggleLike
        ),
        IconButton(
          icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border_rounded, color: AppColors.roseDeep), 
          onPressed: () => setState(() => _isSaved = !_isSaved)
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.subjectTitle, style: AppTextStyles.title(16, AppColors.roseDeep)),
        centerTitle: true,
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Row(
      children: [
        CircleAvatar(radius: 24, backgroundImage: AssetImage('assets/images/forom cumm/${widget.post['avatar']}.jpg')),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.post['author'], style: AppTextStyles.title(16, AppColors.textPrimary)),
                  const SizedBox(width: 6),
                  const Icon(Icons.verified_rounded, color: Colors.blue, size: 16),
                ],
              ),
              Text(widget.post['time'], style: AppTextStyles.body(12, AppColors.textMuted)),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            side: const BorderSide(color: AppColors.roseDeep),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: Text('Suivre', style: AppTextStyles.body(12, AppColors.roseDeep, weight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.roseDeep.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text('#${widget.post['tag']}', style: AppTextStyles.body(12, AppColors.roseDeep, weight: FontWeight.bold)),
    );
  }

  Widget _buildContent() {
    return Text(
      'Bonjour à tous les passionnés de jardinage ! \n\n'
      'Aujourd\'hui, je partage avec vous mes secrets pour réussir vos cultures. Le plus important est de bien préparer votre sol avec un compost de qualité. \n\n'
      'N\'oubliez pas non plus l\'importance d\'un arrosage régulier mais modéré, surtout tôt le matin pour éviter l\'évaporation excessive. \n\n'
      'Qu\'en pensez-vous ? Avez-vous d\'autres astuces à partager ? Laissez un commentaire ci-dessous ! 👇',
      style: AppTextStyles.body(15, AppColors.textPrimary.withOpacity(0.8), height: 1.6),
    );
  }

  Widget _buildPostImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(widget.imagePath, fit: BoxFit.cover, width: double.infinity),
    );
  }

  Widget _buildInteractions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInteractionItem(
          _isLiked ? Icons.favorite : Icons.favorite_border_rounded, 
          '$_likeCount J\'aime', 
          onTap: _toggleLike,
          color: _isLiked ? Colors.red : AppColors.textMuted
        ),
        _buildInteractionItem(
          Icons.chat_bubble_outline_rounded, 
          '${_comments.length} Commentaires',
          onTap: () {} // Focus input
        ),
        _buildInteractionItem(
          Icons.share_outlined, 
          'Partager',
          onTap: _showShareSheet
        ),
      ],
    );
  }

  Widget _buildInteractionItem(IconData icon, String label, {VoidCallback? onTap, Color color = AppColors.textMuted}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.body(12, color)),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Commentaires', style: AppTextStyles.title(18, AppColors.textPrimary)),
        const SizedBox(height: 24),
        ..._comments.map((comment) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCommentItem(comment['name']!, comment['avatar']!, comment['text']!),
        )).toList(),
      ],
    );
  }

  Widget _buildCommentItem(String name, String avatar, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/images/forom cumm/$avatar.jpg')),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.title(14, AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(text, style: AppTextStyles.body(13, AppColors.textPrimary.withOpacity(0.7))),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Répondre', style: AppTextStyles.body(11, AppColors.roseDeep, weight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  Text('Il y a 2h', style: AppTextStyles.body(11, AppColors.textMuted)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFFFDF8F5), borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Ajouter un commentaire...',
                  hintStyle: AppTextStyles.body(14, AppColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: AppColors.roseDeep,
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20), 
              onPressed: _addComment,
            ),
          ),
        ],
      ),
    );
  }
}
