import 'package:flutter/material.dart';

void main() => runApp(const NoirApp());

// ---------- Design tokens ----------
class C {
  static const bg = Color(0xFF14110F);
  static const surface = Color(0xFF1F1B18);
  static const surfaceHi = Color(0xFF2A2420);
  static const border = Color(0xFF3A322C);
  static const gold = Color(0xFFA8804F);
  static const goldLight = Color(0xFFC9A26B);
  static const text = Color(0xFFF2EBE3);
  static const muted = Color(0xFF9A8F85);
}

const serif = 'serif'; // swap for a Google Font, e.g. GoogleFonts.playfairDisplay

class NoirApp extends StatelessWidget {
  const NoirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noir Coffee',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: C.bg),
      home: const HomeScreen(),
    );
  }
}

// ---------- Data ----------
class Drink {
  final String name, price, image;
  final double rating;
  const Drink(this.name, this.price, this.rating, this.image);
}

const drinks = [
  Drink('Smoked\nEspresso', '\$2.00', 4.6,
      'https://images.unsplash.com/photo-1510707577719-ae7c14805e3a?w=400'),
  Drink('Charcoal\nMocha', '\$1.00', 4.5,
      'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=400'),
  Drink('Nocturne\nCold Brew', '\$2.00', 4.7,
      'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=400'),
];

const categories = ['Signature', 'Cold Brew', 'Slow Drip', 'Dark Roast'];

// ---------- Screen ----------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;
  int cartCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 0, 24),
          children: [
            _header(),
            const SizedBox(height: 28),
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                'Select Your\nMidnight Brew',
                style: TextStyle(
                  fontFamily: serif,
                  fontSize: 32,
                  height: 1.15,
                  color: C.text,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _searchRow(),
            const SizedBox(height: 20),
            _drinkList(),
            const SizedBox(height: 28),
            const Text('Categories',
                style: TextStyle(
                    fontFamily: serif, fontSize: 22, color: C.text)),
            const SizedBox(height: 12),
            _categoryChips(),
            const SizedBox(height: 24),
            _dailyRitual(),
          ],
        ),
      ),
    );
  }

  // Logo + profile + cart
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('NOIR',
                  style: TextStyle(
                      fontFamily: serif,
                      fontSize: 28,
                      letterSpacing: 1,
                      color: C.muted)),
              Text('COFFEE',
                  style: TextStyle(
                      fontSize: 10, letterSpacing: 4, color: C.muted)),
            ],
          ),
          const Spacer(),
          _profileButton(),
          const SizedBox(width: 10),
          _cartButton(),
        ],
      ),
    );
  }

  Widget _profileButton() => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: C.surfaceHi,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person_outline, size: 18, color: C.muted),
            Text('Profile', style: TextStyle(fontSize: 9, color: C.muted)),
          ],
        ),
      );

  Widget _cartButton() => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: C.gold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: Color(0xFF2B1F12)),
          ),
          if (cartCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: C.text,
                child: Text('$cartCount',
                    style: const TextStyle(fontSize: 10, color: C.bg)),
              ),
            ),
        ],
      );

  // Search bar + filter button
  Widget _searchRow() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: C.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: C.border),
              ),
              child: Row(
                children: const [
                  Icon(Icons.search, size: 18, color: C.muted),
                  SizedBox(width: 10),
                  Text('Search for your craving...',
                      style: TextStyle(color: C.muted, fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: C.border),
            ),
            child: const Icon(Icons.tune, size: 18, color: C.muted),
          ),
        ],
      ),
    );
  }

  // Horizontal drink cards
  Widget _drinkList() {
    return SizedBox(
      height: 232,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        itemCount: drinks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _drinkCard(drinks[i]),
      ),
    );
  }

  Widget _drinkCard(Drink d) {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  d.image,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 110,
                    color: C.surfaceHi,
                    child: const Icon(Icons.coffee, color: C.gold, size: 36),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 9, color: C.goldLight),
                    const SizedBox(width: 2),
                    Text('${d.rating}',
                        style: const TextStyle(fontSize: 10, color: C.text)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Text(d.name,
                style: const TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                    color: C.text)),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 8, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d.price,
                    style: const TextStyle(color: C.goldLight, fontSize: 13)),
                GestureDetector(
                  onTap: () => setState(() => cartCount++),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: C.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        const Icon(Icons.add, size: 18, color: Color(0xFF2B1F12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Category pills
  Widget _categoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final selected = i == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF6B5337) : C.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? C.gold : C.border),
              ),
              child: Text(categories[i],
                  style: TextStyle(
                      fontSize: 13,
                      color: selected ? C.text : C.muted)),
            ),
          );
        },
      ),
    );
  }

  // Promo banner
  Widget _dailyRitual() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Container(
        height: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.border.withOpacity(0.6)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 170,
              child: ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.black],
                  stops: [0, 0.4],
                ).createShader(r),
                blendMode: BlendMode.dstIn,
                child: Image.network(
                  'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=500',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: C.surfaceHi),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Ritual',
                      style: TextStyle(
                          fontFamily: serif, fontSize: 24, color: C.text)),
                  const SizedBox(height: 6),
                  const Text('A velvety\nespresso over ice',
                      style: TextStyle(
                          fontFamily: serif,
                          fontSize: 15,
                          height: 1.3,
                          color: C.muted)),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: C.gold,
                      foregroundColor: const Color(0xFF2B1F12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Order Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}