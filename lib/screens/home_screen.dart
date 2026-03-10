
import 'package:banglascan_pro/screens/history_screen.dart';
import 'package:banglascan_pro/screens/result_screen.dart';
import 'package:banglascan_pro/services/image_processing_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageProcessingService _imageProcessingService = ImageProcessingService();

  Future<void> _handlePermission(ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      _pickAndCropImage(source);
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text('Please enable camera/gallery permissions in settings to use this feature.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => openAppSettings(), child: const Text('Open Settings')),
        ],
      ),
    );
  }

  void _pickAndCropImage(ImageSource source) async {
    final imagePath = await _imageProcessingService.pickAndCropImage(source, context);
    if (imagePath != null) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(imagePath: imagePath)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('BanglaScan Pro', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00796B), Color(0xFF00BFA5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 0.2,
                    child: Icon(Icons.document_scanner_outlined, size: 120, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Instant OCR', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Scan documents and get meanings in seconds.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 32),
                  _buildActionCard(
                    title: 'Smart Camera',
                    subtitle: 'Scan and recognize text instantly',
                    icon: Icons.camera_rounded,
                    color: const Color(0xFF00796B),
                    onTap: () => _handlePermission(ImageSource.camera),
                  ),
                  const SizedBox(height: 20),
                  _buildActionCard(
                    title: 'Gallery Import',
                    subtitle: 'Pick image from your storage',
                    icon: Icons.photo_library_rounded,
                    color: Colors.orange[700]!,
                    onTap: () => _handlePermission(ImageSource.gallery),
                  ),
                  const SizedBox(height: 40),
                  _buildSectionHeader('Premium Features'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureIcon(Icons.translate_rounded, 'Dictionary'),
                      _buildFeatureIcon(Icons.picture_as_pdf_rounded, 'PDF Save'),
                      _buildFeatureIcon(Icons.history_rounded, 'History'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF00796B)),
            accountName: const Text('BanglaScan Pro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail: const Text('v1.0.0 Stable'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.psychology_outlined, size: 40, color: Color(0xFF00796B)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('Scan History'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About App'),
            onTap: () => _showAboutDialog(),
          ),
          const Spacer(),
          const Divider(),
          const ListTile(
            title: Text('Developed with ❤️ in Bangladesh', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'BanglaScan Pro',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.document_scanner, size: 50, color: Color(0xFF00796B)),
      children: [
        const Text('The most advanced Bengali OCR tool with built-in dictionary and TTS support.'),
      ],
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: () {}, child: const Text('View All')),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Icon(icon, color: const Color(0xFF00796B)),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}
