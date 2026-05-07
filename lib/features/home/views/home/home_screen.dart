import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── Sample data ──────────────────────────────────────────────────────────
  final List<Map<String, String>> _events = [
    {'title': 'Arts Club Inauguration', 'date': '12-Apr'},
    {'title': 'Arts Club Inauguration', 'date': '12-Apr'},
    {'title': 'Arts Club Inauguration', 'date': '12-Apr'},
  ];

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBanner(),
                const SizedBox(height: 24),
                _buildTopStudents(),
                const SizedBox(height: 24),
                _buildEvents(),
                const SizedBox(height: 24),
                _buildPhotoGrid(),
                const SizedBox(height: 24),
                _buildAboutSection(),
                const SizedBox(height: 24),
                _buildContactRow(),
                const SizedBox(height: 24),
                _buildSocialIcons(),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Sticky login button ─────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildLoginButton(),
          ),
        ],
      ),
    );
  }

  // ── Hero / Header ─────────────────────────────────────────────────────────
  Widget _buildHeroBanner() {
    return Column(
      children: [
        // Status-bar safe area
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 16,
            right: 16,
            bottom: 12,
          ),
          child: Row(
            children: [
              // Logo placeholder
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MET PUBLIC SCHOOL',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'PAYYANAD',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A237E),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Hero image collage placeholder
        SizedBox(
          height: 200,
          child: Row(
            children: [
              // Left tall image
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.only(right: 2),
                  color: Colors.grey.shade400,
                  child: const Center(
                    child: Icon(Icons.image, size: 40, color: Colors.white54),
                  ),
                ),
              ),
              // Right 2x2 grid
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _greyImageBox(margin: const EdgeInsets.only(bottom: 2, right: 2)),
                          _greyImageBox(margin: const EdgeInsets.only(bottom: 2)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _greyImageBox(margin: const EdgeInsets.only(right: 2)),
                          _greyImageBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _greyImageBox({EdgeInsets margin = EdgeInsets.zero}) {
    return Expanded(
      child: Container(
        margin: margin,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image, size: 24, color: Colors.white54),
        ),
      ),
    );
  }

  // ── Top Students ──────────────────────────────────────────────────────────
  Widget _buildTopStudents() {
    return Column(
      children: [
        // Trophy icon
        const Text('🏆', style: TextStyle(fontSize: 32)),
        const SizedBox(height: 6),
        const Text(
          'Top Students',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Horizontal avatar list
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _buildStudentAvatar(),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentAvatar() {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFFFB300),
          width: 3,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        color: Colors.grey.shade300,
      ),
      child: const Center(
        child: Icon(Icons.person, size: 36, color: Colors.grey),
      ),
    );
  }

  // ── Events ────────────────────────────────────────────────────────────────
  Widget _buildEvents() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_events.length, (i) => _buildEventTile(_events[i])),
        ],
      ),
    );
  }

  Widget _buildEventTile(Map<String, String> event) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Event icon placeholder
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event['date']!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }

  // ── Photo Grid ────────────────────────────────────────────────────────────
  Widget _buildPhotoGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Row 1 – two wide cards
          Row(
            children: [
              _photoCard(flex: 1, height: 130),
              const SizedBox(width: 8),
              _photoCard(flex: 1, height: 130),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2 – three equal cards
          Row(
            children: [
              _photoCard(flex: 1, height: 100),
              const SizedBox(width: 8),
              _photoCard(flex: 1, height: 100),
              const SizedBox(width: 8),
              _photoCard(flex: 1, height: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _photoCard({required int flex, required double height}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 32, color: Colors.white54),
        ),
      ),
    );
  }

  // ── About Section ─────────────────────────────────────────────────────────
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Our School',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Lorem ipsum dolor sit amet consectetur. At et viverra orci senectus velit '
                'tristique odio sem. Tempus ipsum massa est a eu nibh urna aenean quis. Odio '
                'nibh pharetra sapien in feugiat. Et porttitor eu elementum non eget amet. '
                'Porta in ut nibh integer turpis aliquam feugiat. Proin neque tellus orci '
                'velit eget placerat ut viverra facilisis. Id amet ac in est non. Et eget '
                'pellentesque pharetra pretium auctor tempor eros.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Read More',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Contact Row ───────────────────────────────────────────────────────────
  Widget _buildContactRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          children: [
            const Icon(Icons.phone_outlined, size: 22, color: Colors.black87),
            const SizedBox(width: 8),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Social Icons ──────────────────────────────────────────────────────────
  Widget _buildSocialIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIcon(Icons.camera_alt_outlined, Colors.pink),
        const SizedBox(width: 24),
        _socialIcon(Icons.facebook, const Color(0xFF1877F2)),
        const SizedBox(width: 24),
        _socialIcon(Icons.play_circle_fill, Colors.red),
      ],
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Icon(icon, size: 30, color: color),
    );
  }

  // ── Login Button ──────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF9C27B0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}