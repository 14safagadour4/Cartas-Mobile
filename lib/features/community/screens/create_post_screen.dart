import 'package:flutter/material.dart';
import 'package:cartas/core/theme/app_colors.dart';
import 'package:cartas/core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostScreen extends StatefulWidget {
  final String subjectTitle;

  const CreatePostScreen({super.key, required this.subjectTitle});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  String _firstName = '';
  String _lastName = '';
  bool _isLoadingUser = true;

  // Selection states
  String _visibility = 'Public';
  String _selectedLocation = '';
  String _selectedMood = '';
  List<String> _selectedPeople = [];
  String? _selectedGif;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _firstName = prefs.getString('firstName') ?? 'Utilisateur';
        _lastName = prefs.getString('lastName') ?? '';
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.roseDeep)));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Nouvelle publication', style: AppTextStyles.title(18, AppColors.textPrimary)),
        centerTitle: true,
        actions: [
          const Icon(Icons.more_horiz_rounded, color: AppColors.textPrimary),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(),
                  const SizedBox(height: 20),
                  _buildCategoryChips(),
                  if (_selectedLocation.isNotEmpty || _selectedMood.isNotEmpty || _selectedPeople.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          if (_selectedLocation.isNotEmpty) _buildSelectionChip(_selectedLocation, Icons.location_on, Colors.red, () => setState(() => _selectedLocation = '')),
                          if (_selectedMood.isNotEmpty) _buildSelectionChip(_selectedMood, Icons.emoji_emotions, Colors.orange, () => setState(() => _selectedMood = '')),
                          if (_selectedPeople.isNotEmpty) _buildSelectionChip('${_selectedPeople.length} personnes', Icons.people, Colors.blue, () => setState(() => _selectedPeople = [])),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Quoi de neuf ?',
                      hintStyle: AppTextStyles.body(18, AppColors.textMuted.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                    style: AppTextStyles.body(18, AppColors.textPrimary),
                    onChanged: (val) => setState(() {}),
                  ),
                  if (_selectedGif != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(_selectedGif!, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedGif = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.gold,
          backgroundImage: const AssetImage('assets/images/forom cumm/62d42fb5d9b7d594b95f9797c2bb5f27.jpg'),
          child: _firstName.isEmpty 
            ? const Icon(Icons.person, color: Colors.white)
            : Text(_firstName[0].toUpperCase(), style: AppTextStyles.title(20, Colors.white)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_firstName $_lastName', style: AppTextStyles.title(16, AppColors.textPrimary)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _showVisibilityPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.petalCream.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(_visibility == 'Public' ? Icons.public_rounded : Icons.lock_rounded, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(_visibility, style: AppTextStyles.body(10, AppColors.textMuted, weight: FontWeight.bold)),
                    const Icon(Icons.arrow_drop_down_rounded, size: 16, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionChip(Icons.people_alt_rounded, 'Personnes', Colors.blue, _showPeoplePicker),
          _buildActionChip(Icons.location_on_rounded, 'Lieu', Colors.red, _showLocationPicker),
          _buildActionChip(Icons.emoji_emotions_rounded, 'Humeur / activité', Colors.orange, _showMoodPicker),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.petalCream.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.body(12, AppColors.textPrimary, weight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionChip(String label, IconData icon, Color color, VoidCallback onRemove) {
    return Chip(
      avatar: Icon(icon, size: 14, color: color),
      label: Text(label, style: AppTextStyles.body(10, AppColors.textPrimary)),
      backgroundColor: AppColors.petalCream.withOpacity(0.3),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.petalCream.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          _buildBottomActionIcon(Icons.image_rounded, 'Galerie', Colors.green, _showImageSourcePicker),
          const SizedBox(width: 20),
          _buildBottomActionIcon(Icons.gif_box_rounded, 'GIF', Colors.cyan, _showGifPicker),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty || _selectedGif != null) {
                final newPost = {
                  'author': '$_firstName $_lastName',
                  'avatar': '62d42fb5d9b7d594b95f9797c2bb5f27',
                  'title': _controller.text,
                  'image': _selectedGif, 
                  'time': 'À l\'instant',
                  'tag': 'Plantes', 
                  'location': _selectedLocation,
                  'mood': _selectedMood,
                  'people': _selectedPeople,
                };
                Navigator.pop(context, newPost);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (_controller.text.isEmpty && _selectedGif == null) ? Colors.grey[200] : AppColors.roseDeep,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Publier',
              style: AppTextStyles.body(14, (_controller.text.isEmpty && _selectedGif == null) ? Colors.grey : Colors.white, weight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.body(10, AppColors.textPrimary, weight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Pickers ---

  void _showVisibilityPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.public_rounded, color: Colors.blue),
            title: const Text('Public'),
            subtitle: const Text('Tout le monde peut voir cette publication'),
            onTap: () { setState(() => _visibility = 'Public'); Navigator.pop(context); },
          ),
          ListTile(
            leading: const Icon(Icons.lock_rounded, color: Colors.grey),
            title: const Text('Unique'),
            subtitle: const Text('Seulement moi'),
            onTap: () { setState(() => _visibility = 'Unique'); Navigator.pop(context); },
          ),
        ],
      ),
    );
  }

  void _showPeoplePicker() {
    final List<Map<String, String>> friends = [
      {'name': 'Rim', 'avatar': 'yasmine'},
      {'name': 'Ahmed', 'avatar': 'mahdi'},
      {'name': 'Sara', 'avatar': 'olivia'},
      {'name': 'Ala', 'avatar': 'ala'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Identifier des amis', style: AppTextStyles.title(18, AppColors.textPrimary)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) => CheckboxListTile(
                  value: _selectedPeople.contains(friends[index]['name']),
                  title: Row(
                    children: [
                      CircleAvatar(radius: 16, backgroundImage: AssetImage('assets/images/forom cumm/${friends[index]['avatar']}.jpg')),
                      const SizedBox(width: 12),
                      Text(friends[index]['name']!),
                    ],
                  ),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedPeople.add(friends[index]['name']!);
                      } else {
                        _selectedPeople.remove(friends[index]['name']!);
                      }
                    });
                    Navigator.pop(context);
                    _showPeoplePicker(); // Refresh bottom sheet
                  },
                ),
              ),
            ),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Terminer')),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker() {
    final List<String> locations = ['Tunisie', 'Tunis', 'Sousse', 'Sfax', 'Bizerte'];
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 500,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Où êtes-vous ?', prefixIcon: Icon(Icons.search_rounded)),
                onChanged: (val) => setModalState(() => query = val),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: locations.where((l) => l.toLowerCase().contains(query.toLowerCase())).map((loc) => ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(loc),
                    onTap: () {
                      setState(() => _selectedLocation = loc);
                      Navigator.pop(context);
                    },
                  )).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoodPicker() {
    final List<String> moods = ['😊 Heureux', '🪴 Motivé', '🧘 Zen', '🤔 Pensif', '🥳 En fête', '😴 Fatigué'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2),
        itemCount: moods.length,
        itemBuilder: (context, index) => ActionChip(
          label: Text(moods[index]),
          onPressed: () {
            setState(() => _selectedMood = moods[index]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_rounded, color: Colors.blue),
            title: const Text('Caméra'),
            onTap: () { Navigator.pop(context); /* Trigger Camera */ },
          ),
          ListTile(
            leading: const Icon(Icons.image_rounded, color: Colors.green),
            title: const Text('Galerie'),
            onTap: () { Navigator.pop(context); /* Trigger Gallery */ },
          ),
        ],
      ),
    );
  }

  void _showGifPicker() {
    final List<String> gifs = [
      'assets/images/gif/forum_theme_animation.gif',
      'assets/images/gif/tenor (1).gif',
      'assets/images/gif/tenor (2).gif',
      'assets/images/gif/tenor (3).gif',
      'assets/images/gif/tenor.gif',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        height: 500,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text('Rechercher un GIF', style: AppTextStyles.title(16, AppColors.textPrimary)),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
                itemCount: gifs.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedGif = gifs[index]);
                    Navigator.pop(context);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(gifs[index], fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
