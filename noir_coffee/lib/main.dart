import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  kS = (view.physicalSize.width / view.devicePixelRatio / 386)
      .clamp(0.8, 1.4)
      .toDouble();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF221F1E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const NoirApp());
}

// ================= SCALING =================
double kS = 1;
double s(double v) => v * kS;

// ================= DESIGN TOKENS =================
class C {
  static const bg = Color(0xFF221F1E);
  static const surface = Color(0xFF2D2C2A);
  static const surfaceHi = Color(0xFF3A3736);
  static const border = Color(0xFF393937);
  static const gold = Color(0xFF8D6D3D);
  static const goldLight = Color(0xFFB39463);
  static const cream = Color(0xFFFDFCE8);
  static const text = Color(0xFFF6F1EA);
  static const muted = Color(0xFF8E8A85);
  static const cardTop = Color(0xFF2B2018);
  static const cardBottom = Color(0xFF3A2C1E);
  static const cardBorder = Color(0xFF46372A);
  static const star = Color(0xFFE2B15F);
}

TextStyle serif(double size, {Color color = C.text, double height = 1.19}) =>
    GoogleFonts.playfairDisplay(
        fontSize: size * kS, color: color, height: height);

TextStyle sans(double size,
        {Color color = C.text,
        FontWeight weight = FontWeight.w400,
        double height = 1.25,
        double spacing = 0}) =>
    GoogleFonts.roboto(
        fontSize: size * kS,
        color: color,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing);

String money(double v) => '\$${v.toStringAsFixed(2)}';

// ================= DATA + CART STATE =================
class Drink {
  final String name, asset, heroUrl, desc;
  final double price, rating;
  const Drink(
      this.name, this.price, this.rating, this.asset, this.heroUrl, this.desc);
  String get title => name.replaceAll('\n', ' ');
}

const drinks = [
  Drink(
      'Smoked\nEspresso',
      2.00,
      4.6,
      'assets/images/espresso.jpg',
      'https://images.unsplash.com/photo-1510707577719-ae7c14805e3a?w=900',
      'A bold double shot, slow-roasted over oak embers for a deep, smoky finish with a thick golden crema.'),
  Drink(
      'Charcoal\nMocha',
      1.00,
      4.5,
      'assets/images/mocha.jpg',
      'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=900',
      'Dark chocolate and activated charcoal blended with espresso and steamed milk, topped with latte art.'),
  Drink(
      'Nocturne\nCold Brew',
      2.00,
      4.7,
      'assets/images/coldbrew.jpg',
      'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=900',
      'Steeped for 18 hours in the dark, poured over ice and finished with a swirl of cream.'),
];

const categories = ['Signature', 'Cold Brew', 'Slow Drip', 'Dark Roast'];
const chipFills = [
  Color(0xFF6E5640),
  Color(0xFF3C3027),
  Color(0xFF38321F),
  Color(0xFF352920),
];
const sizeExtra = {'S': 0.0, 'M': 0.5, 'L': 1.0};

class CartItem {
  final Drink drink;
  final String size;
  int qty;
  CartItem(this.drink, this.size, this.qty);
  double get unit => drink.price + sizeExtra[size]!;
  double get total => unit * qty;
}

class CartModel extends ChangeNotifier {
  final List<CartItem> items = [];
  int get count => items.fold(0, (s, e) => s + e.qty);
  double get total => items.fold(0.0, (s, e) => s + e.total);

  void add(Drink d, String size, int qty) {
    final i =
        items.indexWhere((e) => e.drink.name == d.name && e.size == size);
    if (i >= 0) {
      items[i].qty += qty;
    } else {
      items.add(CartItem(d, size, qty));
    }
    notifyListeners();
  }

  void changeQty(CartItem it, int delta) {
    it.qty += delta;
    if (it.qty <= 0) items.remove(it);
    notifyListeners();
  }

  void remove(CartItem it) {
    items.remove(it);
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }
}

final cart = CartModel();

// ================= APP =================
class NoirApp extends StatelessWidget {
  const NoirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noir Coffee',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: C.bg),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        kS = (mq.size.width / 386).clamp(0.8, 1.4).toDouble();
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.noScaling),
          child: KeyedSubtree(key: ValueKey(kS), child: child!),
        );
      },
      home: const HomeScreen(),
    );
  }
}

// ================= SHARED WIDGETS =================
class DrinkImage extends StatelessWidget {
  final Drink drink;
  final bool hero;
  const DrinkImage({super.key, required this.drink, this.hero = false});

  @override
  Widget build(BuildContext context) {
    final base = Image.asset(drink.asset,
        fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    if (!hero) return base;
    return Stack(
      fit: StackFit.expand,
      children: [
        base,
        ColorFiltered(
          colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.35), BlendMode.darken),
          child: Image.network(
            drink.heroUrl,
            fit: BoxFit.cover,
            loadingBuilder: (c, child, p) =>
                p == null ? child : const SizedBox.shrink(),
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const RoundIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.border),
        ),
        child: Icon(icon, size: 20, color: C.text),
      ),
    );
  }
}

class QtyStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus, onPlus;
  const QtyStepper(
      {super.key,
      required this.qty,
      required this.onMinus,
      required this.onPlus});

  Widget _btn(IconData i, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: C.surfaceHi,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: C.border),
          ),
          child: Icon(i, size: 16, color: C.goldLight),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn(Icons.remove, onMinus),
        SizedBox(
          width: 34,
          child: Text('$qty',
              textAlign: TextAlign.center,
              style: sans(15, weight: FontWeight.w600)),
        ),
        _btn(Icons.add, onPlus),
      ],
    );
  }
}

class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double? width, height;
  final double radius, fontSize;
  const GoldButton(
      {super.key,
      required this.label,
      required this.onTap,
      this.width,
      this.height,
      this.radius = 8,
      this.fontSize = 15});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: width == null ? 22 : 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF7C5A33), Color(0xFF9C7C49)],
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: const Color(0x55D9B87A)),
        ),
        child: Text(label,
            style: sans(fontSize, color: C.cream, weight: FontWeight.w500)),
      ),
    );
  }
}

void openCart(BuildContext context) => Navigator.push(
    context, MaterialPageRoute(builder: (_) => const CartPage()));

// ================= HOME =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;

  @override
  Widget build(BuildContext context) {
    final pad = s(18);
    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            width: s(160),
            height: s(214),
            child: IgnorePointer(
              child: Image.asset('assets/images/ring.png', fit: BoxFit.fill),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: EdgeInsets.only(top: s(14), bottom: s(24)),
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: _header()),
                SizedBox(height: s(26)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Text('Select Your\nMidnight Brew',
                      style: serif(35.3,
                          color: const Color(0xFFFBFBF5), height: 1.19)),
                ),
                SizedBox(height: s(18)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: _searchRow()),
                SizedBox(height: s(23)),
                _drinkList(pad),
                SizedBox(height: s(22)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Text('Categories',
                      style: serif(23.4,
                          color: const Color(0xFFFEFEFD), height: 1.2)),
                ),
                SizedBox(height: s(11)),
                _categoryChips(pad),
                SizedBox(height: s(24)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: pad),
                    child: _dailyRitual()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- header ----------
  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NOIR',
                style: GoogleFonts.playfairDisplay(
                    fontSize: s(30),
                    letterSpacing: s(2),
                    color: const Color(0xFF9C8460),
                    height: 1.05)),
            SizedBox(height: s(2)),
            Text('COFFEE',
                style: sans(10.5,
                    color: const Color(0xFF8F8372),
                    spacing: s(4),
                    height: 1.1)),
          ],
        ),
        const Spacer(),
        _profileButton(),
        SizedBox(width: s(10)),
        _cartButton(),
      ],
    );
  }

  Widget _profileButton() => Container(
        width: s(48),
        height: s(46),
        decoration: BoxDecoration(
          color: C.surfaceHi,
          borderRadius: BorderRadius.circular(s(10)),
          border: Border.all(color: const Color(0xFF4A4644)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline,
                size: s(21), color: const Color(0xFFC7C0B4)),
            Text('Profile',
                style:
                    sans(11.5, color: const Color(0xFFC7C0B4), height: 1.1)),
          ],
        ),
      );

  Widget _cartButton() => GestureDetector(
        onTap: () => openCart(context),
        child: ListenableBuilder(
          listenable: cart,
          builder: (_, __) => Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: s(46),
                height: s(46),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF9C7945), Color(0xFF65492B)],
                  ),
                  borderRadius: BorderRadius.circular(s(10)),
                  border: Border.all(color: const Color(0x55D9B87A)),
                ),
                child: Icon(Icons.shopping_cart_outlined,
                    size: s(24), color: const Color(0xFFECE4CF)),
              ),
              if (cart.count > 0)
                Positioned(
                  right: -s(5),
                  top: -s(5),
                  child: CircleAvatar(
                    radius: s(9),
                    backgroundColor: C.text,
                    child: Text('${cart.count}',
                        style: sans(10,
                            color: C.bg, weight: FontWeight.w600, height: 1)),
                  ),
                ),
            ],
          ),
        ),
      );

  // ---------- search ----------
  Widget _searchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: s(44),
            padding: EdgeInsets.symmetric(horizontal: s(13)),
            decoration: BoxDecoration(
              color: C.surface,
              borderRadius: BorderRadius.circular(s(10)),
              border: Border.all(color: C.border),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: s(21), color: const Color(0xFF9A958F)),
                SizedBox(width: s(10)),
                Text('Search for your craving...',
                    style: sans(15.5, color: const Color(0xFF8E8A85))),
              ],
            ),
          ),
        ),
        SizedBox(width: s(11)),
        Container(
          width: s(44),
          height: s(44),
          decoration: BoxDecoration(
            color: C.surface,
            borderRadius: BorderRadius.circular(s(10)),
            border: Border.all(color: C.border),
          ),
          child: Icon(Icons.tune, size: s(21), color: const Color(0xFFC9B28F)),
        ),
      ],
    );
  }

  // ---------- drink cards ----------
  Widget _drinkList(double pad) {
    return SizedBox(
      height: s(275),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        itemCount: drinks.length,
        separatorBuilder: (_, __) => SizedBox(width: s(13)),
        itemBuilder: (_, i) => _drinkCard(drinks[i]),
      ),
    );
  }

  Widget _drinkCard(Drink d) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => DetailPage(drink: d))),
      child: Container(
        width: s(130),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [C.cardTop, C.cardBottom],
          ),
          borderRadius: BorderRadius.circular(s(11)),
          border: Border.all(color: C.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(s(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: s(133),
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(tag: 'drink-${d.name}', child: DrinkImage(drink: d)),
                    Positioned(
                      top: s(6),
                      right: s(5),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: s(6), vertical: s(3)),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.42),
                          borderRadius: BorderRadius.circular(s(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: s(11), color: C.star),
                            SizedBox(width: s(3)),
                            Text('${d.rating}',
                                style: sans(11.5,
                                    color: const Color(0xFFEDE4DA),
                                    height: 1.1)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(s(8), s(9), s(7), s(7)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: sans(15.5,
                            color: const Color(0xFFFCFBF7),
                            weight: FontWeight.w500,
                            height: 1.25),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: s(4)),
                            child: Text(money(d.price),
                                style: sans(15.5,
                                    color: C.goldLight,
                                    weight: FontWeight.w500,
                                    height: 1)),
                          ),
                          GestureDetector(
                            onTap: () {
                              cart.add(d, 'M', 1);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(SnackBar(
                                  backgroundColor: C.surfaceHi,
                                  duration: const Duration(seconds: 1),
                                  content: Text('${d.title} added to cart',
                                      style: sans(13)),
                                ));
                            },
                            child: Container(
                              width: s(28),
                              height: s(28),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF9A7948),
                                    Color(0xFF6E532F)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(s(7)),
                                border:
                                    Border.all(color: const Color(0x55D9B87A)),
                              ),
                              child: Icon(Icons.add,
                                  size: s(20), color: const Color(0xFFF3EDD8)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- category chips ----------
  Widget _categoryChips(double pad) {
    return SizedBox(
      height: s(34),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: s(10)),
        itemBuilder: (_, i) {
          final selected = i == selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = i),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: s(12)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? chipFills[0] : chipFills[i],
                borderRadius: BorderRadius.circular(s(17)),
                border: Border.all(
                    color: selected
                        ? const Color(0xFF8D7050)
                        : const Color(0xFF5C4C36)),
              ),
              child: Text(categories[i],
                  style: sans(14.5,
                      color: const Color(0xFFEAE5DB), height: 1.1)),
            ),
          );
        },
      ),
    );
  }

  // ---------- Daily Ritual banner ----------
  Widget _dailyRitual() {
    return Container(
      height: s(193.5),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF14110E),
        borderRadius: BorderRadius.circular(s(14)),
        border: Border.all(color: const Color(0xFF3A2F24)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/ritual.jpg', fit: BoxFit.fill),
          Positioned(
            left: s(18.5),
            top: s(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Ritual',
                    style: serif(27.7,
                        color: const Color(0xFFFBFBF5), height: 1.2)),
                SizedBox(height: s(7)),
                Text('A velvety\nespresso over Ice',
                    style: serif(21,
                        color: const Color(0xFFF5F5F2), height: 1.19)),
              ],
            ),
          ),
          Positioned(
            left: s(18.5),
            bottom: s(27),
            child: GoldButton(
              label: 'Order Now',
              width: s(112),
              height: s(35.5),
              radius: s(7),
              fontSize: 15 * kS,
              onTap: () {
                cart.add(drinks[2], 'M', 1);
                openCart(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= DRINK DETAIL =================
class DetailPage extends StatefulWidget {
  final Drink drink;
  const DetailPage({super.key, required this.drink});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  String size = 'M';
  int qty = 1;

  double get unit => widget.drink.price + sizeExtra[size]!;

  @override
  Widget build(BuildContext context) {
    final d = widget.drink;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: C.bg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 340,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                            tag: 'drink-${d.name}',
                            child: DrinkImage(drink: d, hero: true)),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.4),
                                Colors.transparent,
                                C.bg,
                              ],
                              stops: const [0, 0.45, 1],
                            ),
                          ),
                        ),
                        Positioned(
                          top: top + 8,
                          left: 20,
                          child: RoundIconButton(
                              icon: Icons.arrow_back,
                              onTap: () => Navigator.pop(context)),
                        ),
                        Positioned(
                          top: top + 8,
                          right: 20,
                          child: RoundIconButton(
                              icon: Icons.shopping_cart_outlined,
                              onTap: () => openCart(context)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(d.title, style: serif(30))),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 16, color: C.star),
                                  const SizedBox(width: 4),
                                  Text('${d.rating}',
                                      style:
                                          sans(14, weight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(d.desc,
                            style: sans(14, color: C.muted, height: 1.55)),
                        const SizedBox(height: 28),
                        Text('Size', style: serif(20)),
                        const SizedBox(height: 12),
                        Row(
                          children: sizeExtra.keys.map((sz) {
                            final sel = sz == size;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                onTap: () => setState(() => size = sz),
                                child: Container(
                                  width: 64,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: sel ? chipFills[0] : chipFills[1],
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                        color: sel
                                            ? const Color(0xFF8D7050)
                                            : const Color(0xFF5C4C36)),
                                  ),
                                  child: Text(sz,
                                      style: sans(14,
                                          color: const Color(0xFFEAE5DB),
                                          weight: FontWeight.w600)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Quantity', style: serif(20)),
                            QtyStepper(
                              qty: qty,
                              onMinus: () =>
                                  setState(() => qty = qty > 1 ? qty - 1 : 1),
                              onPlus: () => setState(() => qty++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                22, 14, 22, 14 + MediaQuery.of(context).padding.bottom),
            decoration: const BoxDecoration(
              color: C.surface,
              border: Border(top: BorderSide(color: C.border)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total', style: sans(12, color: C.muted)),
                    const SizedBox(height: 2),
                    Text(money(unit * qty),
                        style: serif(24, color: C.goldLight)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: GoldButton(
                    label: 'Add to Cart',
                    height: 52,
                    radius: 12,
                    onTap: () {
                      cart.add(d, size, qty);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                          backgroundColor: C.surfaceHi,
                          duration: const Duration(seconds: 1),
                          content: Text('${d.title} added to cart',
                              style: sans(13)),
                        ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CART =================
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      RoundIconButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 16),
                      Text('Your Cart', style: serif(26)),
                    ],
                  ),
                ),
                Expanded(
                  child: cart.items.isEmpty
                      ? _empty(context)
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: cart.items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _row(cart.items[i]),
                        ),
                ),
                if (cart.items.isNotEmpty) _summary(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.coffee_outlined, size: 56, color: C.goldLight),
            const SizedBox(height: 16),
            Text('Your cart is empty', style: serif(22)),
            const SizedBox(height: 6),
            Text('Add a drink to start your order.',
                style: sans(13, color: C.muted)),
            const SizedBox(height: 20),
            GoldButton(
                label: 'Browse drinks',
                height: 46,
                onTap: () => Navigator.pop(context)),
          ],
        ),
      );

  Widget _row(CartItem it) {
    return Dismissible(
      key: ValueKey('${it.drink.name}-${it.size}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.remove(it),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF5A2A24),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: C.text),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [C.cardTop, C.cardBottom],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.cardBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                  width: 68, height: 68, child: DrinkImage(drink: it.drink)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.drink.title,
                      style: sans(15, weight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text('Size ${it.size}', style: sans(12, color: C.muted)),
                  const SizedBox(height: 8),
                  Text(money(it.total),
                      style: sans(15,
                          color: C.goldLight, weight: FontWeight.w500)),
                ],
              ),
            ),
            QtyStepper(
              qty: it.qty,
              onMinus: () => cart.changeQty(it, -1),
              onPlus: () => cart.changeQty(it, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      decoration: const BoxDecoration(
        color: C.surface,
        border: Border(top: BorderSide(color: C.border)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${cart.count} items', style: sans(13, color: C.muted)),
              Text(money(cart.total), style: sans(13, color: C.muted)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: serif(22)),
              Text(money(cart.total), style: serif(24, color: C.goldLight)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GoldButton(
              label: 'Place order',
              height: 52,
              radius: 12,
              onTap: () {
                cart.clear();
                Navigator.popUntil(context, (r) => r.isFirst);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: C.surfaceHi,
                  content: Text('Order placed. Your brew is on its way.',
                      style: sans(13)),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}