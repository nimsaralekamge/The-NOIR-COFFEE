import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
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
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]);
  await store.load();
  await cart.load();
  runApp(const NoirApp());
}

// ================= SCALING =================
// Sizes were measured on a 386-wide design and scale to the real screen width.
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
  static const danger = Color(0xFFB4574B);
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

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

String fmtDate(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour >= 12 ? 'PM' : 'AM';
  return '${d.day} ${_months[d.month - 1]} ${d.year}, $h:$m $ap';
}

// ================= MENU DATA =================
class Drink {
  final String id, name, desc, asset;
  final String? url; // optional online photo (falls back to [asset])
  final double price, baseRating;
  final int baseCount;
  final List<String> cats;
  const Drink({
    required this.id,
    required this.name,
    required this.desc,
    required this.asset,
    required this.price,
    required this.baseRating,
    required this.baseCount,
    required this.cats,
    this.url,
  });
  String get title => name.replaceAll('\n', ' ');
}

const _u = 'https://images.unsplash.com/';
const _espresso = 'assets/images/espresso.jpg';
const _mocha = 'assets/images/mocha.jpg';
const _cold = 'assets/images/coldbrew.jpg';
const _ritual = 'assets/images/ritual.jpg';

const categories = ['Signature', 'Cold Brew', 'Slow Drip', 'Dark Roast'];

const menu = <Drink>[
  // ---- Signature ----
  Drink(
      id: 'smoked-espresso',
      name: 'Smoked\nEspresso',
      price: 2.00,
      baseRating: 4.6,
      baseCount: 128,
      cats: ['Signature'],
      asset: _espresso,
      desc:
          'A bold double shot, slow-roasted over oak embers for a deep, smoky finish with a thick golden crema.'),
  Drink(
      id: 'charcoal-mocha',
      name: 'Charcoal\nMocha',
      price: 1.00,
      baseRating: 4.5,
      baseCount: 96,
      cats: ['Signature'],
      asset: _mocha,
      desc:
          'Dark chocolate and activated charcoal blended with espresso and steamed milk, topped with latte art.'),
  Drink(
      id: 'nocturne-cold-brew',
      name: 'Nocturne\nCold Brew',
      price: 2.00,
      baseRating: 4.7,
      baseCount: 142,
      cats: ['Signature', 'Cold Brew'],
      asset: _cold,
      desc:
          'Steeped for 18 hours in the dark, poured over ice and finished with a swirl of cream.'),
  Drink(
      id: 'velvet-iced',
      name: 'Velvet Iced\nEspresso',
      price: 3.00,
      baseRating: 4.8,
      baseCount: 210,
      cats: ['Signature', 'Cold Brew'],
      asset: _ritual,
      desc:
          'Our Daily Ritual: a velvety espresso poured over ice with a ribbon of cold milk.'),
  Drink(
      id: 'honey-flat-white',
      name: 'Honey Oat\nFlat White',
      price: 3.50,
      baseRating: 4.4,
      baseCount: 64,
      cats: ['Signature'],
      asset: _espresso,
      url: '${_u}photo-1514432324607-a09d9b4aefdd?w=800',
      desc:
          'Silky oat milk, a drizzle of wild honey and a double ristretto for a smooth, mellow cup.'),
  // ---- Cold Brew ----
  Drink(
      id: 'vanilla-cold-foam',
      name: 'Vanilla\nCold Foam',
      price: 3.25,
      baseRating: 4.5,
      baseCount: 88,
      cats: ['Cold Brew'],
      asset: _cold,
      url: '${_u}photo-1559496417-e7f25cb247f3?w=800',
      desc:
          'Slow cold brew crowned with a cloud of vanilla cold foam. Sweet, cool and clean.'),
  Drink(
      id: 'tonic-cold-brew',
      name: 'Tonic\nCold Brew',
      price: 3.00,
      baseRating: 4.3,
      baseCount: 52,
      cats: ['Cold Brew'],
      asset: _cold,
      desc:
          'Cold brew over sparkling tonic and a twist of orange. Bright, bitter and refreshing.'),
  Drink(
      id: 'salted-caramel-cold-brew',
      name: 'Salted Caramel\nCold Brew',
      price: 3.50,
      baseRating: 4.6,
      baseCount: 101,
      cats: ['Cold Brew'],
      asset: _cold,
      desc:
          'Dark caramel, a pinch of sea salt and our smoothest cold brew, served over large ice.'),
  // ---- Slow Drip ----
  Drink(
      id: 'ethiopian-v60',
      name: 'Ethiopian\nV60',
      price: 4.00,
      baseRating: 4.7,
      baseCount: 73,
      cats: ['Slow Drip'],
      asset: _espresso,
      url: '${_u}photo-1541167760496-1628856ab772?w=800',
      desc:
          'Hand-poured single origin with floral, berry-bright notes. Brewed slowly to order.'),
  Drink(
      id: 'kyoto-slow-drip',
      name: 'Kyoto Slow\nDrip',
      price: 4.50,
      baseRating: 4.8,
      baseCount: 59,
      cats: ['Slow Drip'],
      asset: _espresso,
      url: '${_u}photo-1495474472287-4d71bcdd2085?w=800',
      desc:
          'Cold water dripped drop by drop for eight hours. Smooth, sweet and remarkably low in acidity.'),
  Drink(
      id: 'chemex-reserve',
      name: 'Chemex\nReserve',
      price: 4.25,
      baseRating: 4.5,
      baseCount: 47,
      cats: ['Slow Drip'],
      asset: _mocha,
      url: '${_u}photo-1447933601403-0c6688de566e?w=800',
      desc:
          'A clean, tea-like pour-over from our reserve beans, brewed in a classic Chemex.'),
  // ---- Dark Roast ----
  Drink(
      id: 'french-roast',
      name: 'French\nRoast',
      price: 2.50,
      baseRating: 4.4,
      baseCount: 110,
      cats: ['Dark Roast'],
      asset: _mocha,
      url: '${_u}photo-1509042239860-f550ce710b93?w=800',
      desc:
          'Roasted to the edge of black: smoky, bittersweet and bold with a heavy body.'),
  Drink(
      id: 'sumatra-dark',
      name: 'Sumatra\nDark',
      price: 2.75,
      baseRating: 4.5,
      baseCount: 84,
      cats: ['Dark Roast'],
      asset: _espresso,
      url: '${_u}photo-1442512595331-e89e73853f31?w=800',
      desc:
          'Earthy and full-bodied with notes of cedar, cocoa and dark spice.'),
  Drink(
      id: 'italian-roast',
      name: 'Italian\nEspresso',
      price: 2.75,
      baseRating: 4.3,
      baseCount: 69,
      cats: ['Dark Roast'],
      asset: _mocha,
      url: '${_u}photo-1511920170033-f8396924c348?w=800',
      desc:
          'The classic dark espresso roast: deep, syrupy and finished with a hint of burnt sugar.'),
  Drink(
      id: 'charred-colombian',
      name: 'Charred\nColombian',
      price: 3.00,
      baseRating: 4.6,
      baseCount: 57,
      cats: ['Dark Roast'],
      asset: _espresso,
      url: '${_u}photo-1497935586351-b67a49e012bf?w=800',
      desc:
          'Colombian beans fire-roasted dark for toasted nut, caramel and a long smoky finish.'),
];

Drink? findDrink(String id) {
  for (final d in menu) {
    if (d.id == id) return d;
  }
  return null;
}

// ================= USER DATA (saved on the phone) =================
class Profile {
  String name, email, phone, address;
  Profile(
      {this.name = 'Guest',
      this.email = '',
      this.phone = '',
      this.address = ''});

  bool get isGuest => name.trim().isEmpty || name.trim() == 'Guest';

  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Map<String, dynamic> toJson() =>
      {'n': name, 'e': email, 'p': phone, 'a': address};

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
      name: (j['n'] ?? 'Guest') as String,
      email: (j['e'] ?? '') as String,
      phone: (j['p'] ?? '') as String,
      address: (j['a'] ?? '') as String);
}

class Review {
  int stars;
  String comment;
  DateTime at;
  Review(this.stars, this.comment, this.at);

  Map<String, dynamic> toJson() =>
      {'s': stars, 'c': comment, 't': at.toIso8601String()};

  factory Review.fromJson(Map<String, dynamic> j) => Review(
      j['s'] as int, (j['c'] ?? '') as String, DateTime.parse(j['t'] as String));
}

class OrderLine {
  final String drinkId, size;
  final int qty;
  final double unit;
  const OrderLine(this.drinkId, this.size, this.qty, this.unit);

  Map<String, dynamic> toJson() =>
      {'d': drinkId, 's': size, 'q': qty, 'u': unit};

  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
      j['d'] as String,
      j['s'] as String,
      j['q'] as int,
      (j['u'] as num).toDouble());
}

class Order {
  final String id;
  final DateTime at;
  final List<OrderLine> lines;
  final double total;
  const Order(this.id, this.at, this.lines, this.total);

  Map<String, dynamic> toJson() => {
        'id': id,
        't': at.toIso8601String(),
        'l': lines.map((e) => e.toJson()).toList(),
        'total': total
      };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
      j['id'] as String,
      DateTime.parse(j['t'] as String),
      (j['l'] as List)
          .map((e) => OrderLine.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      (j['total'] as num).toDouble());
}

class Store extends ChangeNotifier {
  SharedPreferences? _p;
  Profile profile = Profile();
  Map<String, Review> reviews = {};
  Set<String> favs = {};
  List<Order> orders = [];

  Future<void> load() async {
    try {
      _p = await SharedPreferences.getInstance();
      final pj = _p!.getString('profile');
      if (pj != null) {
        profile = Profile.fromJson(
            Map<String, dynamic>.from(jsonDecode(pj) as Map));
      }
      final rj = _p!.getString('reviews');
      if (rj != null) {
        final m = Map<String, dynamic>.from(jsonDecode(rj) as Map);
        reviews = m.map((k, v) => MapEntry(
            k, Review.fromJson(Map<String, dynamic>.from(v as Map))));
      }
      favs = (_p!.getStringList('favs') ?? <String>[]).toSet();
      final oj = _p!.getString('orders');
      if (oj != null) {
        orders = (jsonDecode(oj) as List)
            .map((e) => Order.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {
      // corrupted or unavailable storage: start fresh
    }
  }

  void _save() {
    final p = _p;
    if (p == null) return;
    p.setString('profile', jsonEncode(profile.toJson()));
    p.setString(
        'reviews', jsonEncode(reviews.map((k, v) => MapEntry(k, v.toJson()))));
    p.setStringList('favs', favs.toList());
    p.setString('orders', jsonEncode(orders.map((e) => e.toJson()).toList()));
  }

  // ----- ratings -----
  double ratingOf(Drink d) {
    final r = reviews[d.id];
    if (r == null) return d.baseRating;
    return (d.baseRating * d.baseCount + r.stars) / (d.baseCount + 1);
  }

  int countOf(Drink d) => d.baseCount + (reviews.containsKey(d.id) ? 1 : 0);

  void rate(Drink d, int stars, String comment) {
    reviews[d.id] = Review(stars, comment.trim(), DateTime.now());
    _save();
    notifyListeners();
  }

  void removeReview(Drink d) {
    reviews.remove(d.id);
    _save();
    notifyListeners();
  }

  // ----- favourites -----
  bool isFav(Drink d) => favs.contains(d.id);

  void toggleFav(Drink d) {
    if (!favs.remove(d.id)) favs.add(d.id);
    _save();
    notifyListeners();
  }

  // ----- profile -----
  void updateProfile(Profile p) {
    profile = p;
    _save();
    notifyListeners();
  }

  void clearAll() {
    profile = Profile();
    reviews = {};
    favs = {};
    orders = [];
    _save();
    notifyListeners();
  }

  // ----- orders -----
  Order placeOrder(List<CartItem> items) {
    final lines =
        items.map((e) => OrderLine(e.drink.id, e.size, e.qty, e.unit)).toList();
    final total = items.fold(0.0, (a, e) => a + e.total);
    final o = Order('NC-${1001 + orders.length}', DateTime.now(), lines, total);
    orders.insert(0, o);
    _save();
    notifyListeners();
    return o;
  }
}

final store = Store();

// ================= CART =================
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
  SharedPreferences? _p;

  Future<void> load() async {
    try {
      _p = await SharedPreferences.getInstance();
      final raw = _p!.getString('cart');
      if (raw == null) return;
      for (final e in jsonDecode(raw) as List) {
        final m = Map<String, dynamic>.from(e as Map);
        final d = findDrink(m['d'] as String);
        if (d != null) items.add(CartItem(d, m['s'] as String, m['q'] as int));
      }
    } catch (_) {
      // ignore unreadable saved cart
    }
  }

  void _persist() {
    _p?.setString(
        'cart',
        jsonEncode(items
            .map((e) => {'d': e.drink.id, 's': e.size, 'q': e.qty})
            .toList()));
  }

  int get count => items.fold(0, (a, e) => a + e.qty);
  double get total => items.fold(0.0, (a, e) => a + e.total);

  void add(Drink d, String size, int qty) {
    final i = items.indexWhere((e) => e.drink.id == d.id && e.size == size);
    if (i >= 0) {
      items[i].qty += qty;
    } else {
      items.add(CartItem(d, size, qty));
    }
    _persist();
    notifyListeners();
  }

  void changeQty(CartItem it, int delta) {
    it.qty += delta;
    if (it.qty <= 0) items.remove(it);
    _persist();
    notifyListeners();
  }

  void remove(CartItem it) {
    items.remove(it);
    _persist();
    notifyListeners();
  }

  void clear() {
    items.clear();
    _persist();
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
  const DrinkImage({super.key, required this.drink});

  @override
  Widget build(BuildContext context) {
    final local = Image.asset(drink.asset,
        fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    if (drink.url == null) return local;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFF2A211B)),
        ColorFiltered(
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
          child: Image.network(
            drink.url!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            frameBuilder: (context, child, frame, wasSync) {
              if (wasSync) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: child,
              );
            },
            errorBuilder: (_, __, ___) => local,
          ),
        ),
      ],
    );
  }
}

/// Wraps any widget with a subtle press-scale and optional haptic tick.
class Tap extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double scale;
  final bool haptic;
  const Tap(
      {super.key,
      required this.onTap,
      required this.child,
      this.scale = 0.96,
      this.haptic = false});

  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: on ? (_) => _set(true) : null,
      onTapUp: on ? (_) => _set(false) : null,
      onTapCancel: on ? () => _set(false) : null,
      onTap: on
          ? () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const RoundIconButton(
      {super.key, required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.border),
        ),
        child: Icon(icon, size: 20, color: color ?? C.text),
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

  Widget _btn(IconData i, VoidCallback f) => Tap(
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
  final VoidCallback? onTap; // null = disabled
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
    final on = onTap != null;
    return Tap(
      haptic: true,
      onTap: onTap,
      child: Opacity(
        opacity: on ? 1 : 0.45,
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
      ),
    );
  }
}

/// Pill used for categories, sizes and filters (gradient fill, golden outline).
class NoirChip extends StatelessWidget {
  final String label;
  final bool selected;
  final int variant;
  final VoidCallback onTap;
  final double height, fontSize, hPad;
  const NoirChip(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap,
      this.variant = 0,
      this.height = 34,
      this.fontSize = 14.5,
      this.hPad = 13});

  static const _grad = [
    [Color(0xFF3E352C), Color(0xFF2D2722)],
    [Color(0xFF3B3626), Color(0xFF2B281C)],
    [Color(0xFF3A2E25), Color(0xFF2A221C)],
  ];
  static const _border = [Color(0xFF6A5538), Color(0xFF5F5A36), Color(0xFF674F38)];

  @override
  Widget build(BuildContext context) {
    final v = variant % 3;
    return Tap(
      haptic: true,
      onTap: onTap,
      child: Container(
        height: s(height),
        padding: EdgeInsets.symmetric(horizontal: s(hPad)),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? const [Color(0xFF7D6650), Color(0xFF5C4837)]
                : _grad[v],
          ),
          borderRadius: BorderRadius.circular(s(height / 2)),
          border: Border.all(
              color: selected ? const Color(0xFF9A7F66) : _border[v],
              width: 1.2),
        ),
        child: Text(label,
            style: sans(fontSize,
                color: const Color(0xFFEFE9DF), height: 1.1)),
      ),
    );
  }
}

/// Sliders icon with hollow knobs, as in the reference.
class TuneIcon extends StatelessWidget {
  final double size;
  final Color color;
  const TuneIcon({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _TunePainter(color));
}

class _TunePainter extends CustomPainter {
  final Color color;
  _TunePainter(this.color);

  @override
  void paint(Canvas canvas, Size sz) {
    final w = sz.width;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.085
      ..strokeCap = StrokeCap.round;
    final r = w * 0.15;
    final y1 = w * 0.30, y2 = w * 0.70;
    final k1 = w * 0.33, k2 = w * 0.67;
    canvas.drawLine(Offset(w * 0.04, y1), Offset(k1 - r, y1), p);
    canvas.drawLine(Offset(k1 + r, y1), Offset(w * 0.96, y1), p);
    canvas.drawCircle(Offset(k1, y1), r, p);
    canvas.drawLine(Offset(w * 0.04, y2), Offset(k2 - r, y2), p);
    canvas.drawLine(Offset(k2 + r, y2), Offset(w * 0.96, y2), p);
    canvas.drawCircle(Offset(k2, y2), r, p);
  }

  @override
  bool shouldRepaint(covariant _TunePainter old) => old.color != color;
}

class StarRating extends StatelessWidget {
  final double value;
  final double size;
  final ValueChanged<int>? onChanged;
  const StarRating(
      {super.key, required this.value, this.size = 18, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = value >= i + 1;
        final half = !filled && value >= i + 0.5;
        final icon = filled
            ? Icons.star_rounded
            : (half ? Icons.star_half_rounded : Icons.star_outline_rounded);
        final w = Icon(icon, size: size, color: C.star);
        if (onChanged == null) return w;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged!(i + 1),
          child: Padding(padding: const EdgeInsets.all(3), child: w),
        );
      }),
    );
  }
}

BoxDecoration cardDeco({double radius = 16}) => BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [C.cardTop, C.cardBottom],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: C.cardBorder),
    );

Widget noirField(TextEditingController c, String label,
    {TextInputType? type, int maxLines = 1, String? hint}) {
  OutlineInputBorder b(Color col) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: col));
  return TextField(
    controller: c,
    keyboardType: type,
    maxLines: maxLines,
    cursorColor: C.goldLight,
    style: sans(15),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: sans(13, color: C.muted),
      floatingLabelStyle: sans(13, color: C.goldLight),
      hintStyle: sans(14, color: C.muted),
      filled: true,
      fillColor: C.surface,
      enabledBorder: b(C.border),
      focusedBorder: b(C.goldLight),
    ),
  );
}

void openCart(BuildContext context) => Navigator.push(
    context, MaterialPageRoute(builder: (_) => const CartPage()));

void openDetail(BuildContext context, Drink d) => Navigator.push(
    context, MaterialPageRoute(builder: (_) => DetailPage(drink: d)));

void toast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      backgroundColor: C.surfaceHi,
      duration: const Duration(milliseconds: 1400),
      content: Text(msg, style: sans(13)),
    ));
}

// ================= HOME =================
enum SortMode { recommended, rating, priceLow, priceHigh }

const sortLabels = {
  SortMode.recommended: 'Recommended',
  SortMode.rating: 'Top rated',
  SortMode.priceLow: 'Price: low to high',
  SortMode.priceHigh: 'Price: high to low',
};

class FilterResult {
  final SortMode sort;
  final double minRating;
  const FilterResult(this.sort, this.minRating);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedCategory = 0;
  String query = '';
  SortMode sort = SortMode.recommended;
  double minRating = 0;
  final searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  bool get filtersActive => sort != SortMode.recommended || minRating > 0;

  List<Drink> get visible {
    final q = query.trim().toLowerCase();
    Iterable<Drink> list;
    if (q.isEmpty) {
      list = menu.where((d) => d.cats.contains(categories[selectedCategory]));
    } else {
      list = menu.where((d) =>
          d.title.toLowerCase().contains(q) ||
          d.desc.toLowerCase().contains(q) ||
          d.cats.any((c) => c.toLowerCase().contains(q)));
    }
    final out = list.where((d) => store.ratingOf(d) >= minRating).toList();
    switch (sort) {
      case SortMode.recommended:
        break;
      case SortMode.rating:
        out.sort((a, b) => store.ratingOf(b).compareTo(store.ratingOf(a)));
        break;
      case SortMode.priceLow:
        out.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortMode.priceHigh:
        out.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
    return out;
  }

  Future<void> _openFilters() async {
    FocusScope.of(context).unfocus();
    final res = await showModalBottomSheet<FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => _FilterSheet(sort: sort, minRating: minRating),
    );
    if (res != null) {
      setState(() {
        sort = res.sort;
        minRating = res.minRating;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = s(18);
    return Scaffold(
      backgroundColor: C.bg,
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) => Stack(
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
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
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

  Widget _profileButton() => Tap(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ProfilePage())),
        child: Container(
          width: s(48),
          height: s(46),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3E3B3A), Color(0xFF353231)],
            ),
            borderRadius: BorderRadius.circular(s(10)),
            border: Border.all(color: const Color(0xFF4A4644)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline,
                  size: s(21), color: const Color(0xFFC7C0B4)),
              Text('Profile',
                  style: sans(11.5,
                      color: const Color(0xFFC7C0B4), height: 1.1)),
            ],
          ),
        ),
      );

  Widget _cartButton() => Tap(
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

  // ---------- search + filter ----------
  Widget _searchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: s(44),
            padding: EdgeInsets.symmetric(horizontal: s(13)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF302F2D), Color(0xFF2A2928)],
              ),
              borderRadius: BorderRadius.circular(s(10)),
              border: Border.all(color: C.border),
            ),
            child: Row(
              children: [
                Icon(Icons.search,
                    size: s(21), color: const Color(0xFF9A958F)),
                SizedBox(width: s(10)),
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: (v) => setState(() => query = v),
                    textInputAction: TextInputAction.search,
                    cursorColor: C.goldLight,
                    style: sans(15.5, color: C.text),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Search for your craving...',
                      hintStyle:
                          sans(15.5, color: const Color(0xFF8E8A85)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (query.isNotEmpty)
                  Tap(
                    onTap: () => setState(() {
                      query = '';
                      searchCtrl.clear();
                    }),
                    child: Icon(Icons.close,
                        size: s(19), color: const Color(0xFF9A958F)),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: s(11)),
        Tap(
          onTap: _openFilters,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: s(44),
                height: s(44),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF353432), Color(0xFF282725)],
                  ),
                  borderRadius: BorderRadius.circular(s(11)),
                  border: Border.all(color: const Color(0xFF45423F)),
                ),
                child: TuneIcon(size: s(22), color: const Color(0xFFD6BC92)),
              ),
              if (filtersActive)
                Positioned(
                  top: -s(3),
                  right: -s(3),
                  child: Container(
                    width: s(11),
                    height: s(11),
                    decoration: BoxDecoration(
                      color: C.star,
                      shape: BoxShape.circle,
                      border: Border.all(color: C.bg, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- drink cards ----------
  Widget _drinkList(double pad) {
    final list = visible;
    final Widget content;
    if (list.isEmpty) {
      content = Container(
        key: const ValueKey('empty'),
        height: s(222),
        margin: EdgeInsets.symmetric(horizontal: pad),
        alignment: Alignment.center,
        decoration: cardDeco(radius: s(11)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.coffee_outlined, size: s(40), color: C.goldLight),
            SizedBox(height: s(10)),
            Text('No drinks found', style: serif(20)),
            SizedBox(height: s(4)),
            Text('Try another search or clear the filters.',
                style: sans(13, color: C.muted)),
          ],
        ),
      );
    } else {
      content = SizedBox(
        key: ValueKey(
            '$selectedCategory|$sort|$minRating|${query.trim().isEmpty}'),
        height: s(222),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: pad),
          itemCount: list.length,
          separatorBuilder: (_, __) => SizedBox(width: s(13)),
          itemBuilder: (_, i) => _drinkCard(list[i]),
        ),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: content,
    );
  }

  Widget _drinkCard(Drink d) {
    return Tap(
      scale: 0.97,
      onTap: () => openDetail(context, d),
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
                    Hero(tag: 'drink-${d.id}', child: DrinkImage(drink: d)),
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
                            Text(store.ratingOf(d).toStringAsFixed(1),
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
                      Text(d.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: sans(15.5,
                              color: const Color(0xFFFCFBF7),
                              weight: FontWeight.w500,
                              height: 1.25)),
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
                          Tap(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              cart.add(d, 'M', 1);
                              toast(context, '${d.title} added to cart');
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
                                border: Border.all(
                                    color: const Color(0x55D9B87A)),
                              ),
                              child: Icon(Icons.add,
                                  size: s(20),
                                  color: const Color(0xFFF3EDD8)),
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
        itemBuilder: (_, i) => NoirChip(
          label: categories[i],
          variant: i,
          selected: query.trim().isEmpty && i == selectedCategory,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              selectedCategory = i;
              query = '';
              searchCtrl.clear();
            });
          },
        ),
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
        borderRadius: BorderRadius.circular(s(16)),
        border: Border.all(color: const Color(0xFF3B3530)),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/ritual.jpg', fit: BoxFit.fill),
          // soft top highlight along the edge
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: s(26),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
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
                cart.add(findDrink('velvet-iced')!, 'M', 1);
                openCart(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- filter bottom sheet ----------
class _FilterSheet extends StatefulWidget {
  final SortMode sort;
  final double minRating;
  const _FilterSheet({required this.sort, required this.minRating});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late SortMode sort = widget.sort;
  late double minRating = widget.minRating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          22, 14, 22, 22 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: C.border, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Text('Filter & sort', style: serif(24)),
          const SizedBox(height: 18),
          Text('Sort by', style: sans(13, color: C.muted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: SortMode.values
                .map((m) => NoirChip(
                      label: sortLabels[m]!,
                      selected: sort == m,
                      height: 36,
                      fontSize: 14,
                      onTap: () => setState(() => sort = m),
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
          Text('Minimum rating', style: sans(13, color: C.muted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final v in const [0.0, 4.0, 4.5])
                NoirChip(
                  label: v == 0 ? 'Any' : '${v.toStringAsFixed(1)}+  ★',
                  selected: minRating == v,
                  height: 36,
                  fontSize: 14,
                  onTap: () => setState(() => minRating = v),
                ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Tap(
                  onTap: () => setState(() {
                    sort = SortMode.recommended;
                    minRating = 0;
                  }),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: C.border),
                    ),
                    child: Text('Reset', style: sans(15, color: C.muted)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GoldButton(
                  label: 'Apply',
                  height: 50,
                  radius: 12,
                  onTap: () =>
                      Navigator.pop(context, FilterResult(sort, minRating)),
                ),
              ),
            ],
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
  int draftStars = 0;
  final commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = store.reviews[widget.drink.id];
    if (r != null) {
      draftStars = r.stars;
      commentCtrl.text = r.comment;
    }
  }

  @override
  void dispose() {
    commentCtrl.dispose();
    super.dispose();
  }

  double get unit => widget.drink.price + sizeExtra[size]!;

  @override
  Widget build(BuildContext context) {
    final d = widget.drink;
    final top = MediaQuery.of(context).padding.top;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final saved = store.reviews[d.id];
        return Scaffold(
          backgroundColor: C.bg,
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                                tag: 'drink-${d.id}',
                                child: DrinkImage(drink: d)),
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
                              child: Row(
                                children: [
                                  RoundIconButton(
                                    icon: store.isFav(d)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: store.isFav(d)
                                        ? const Color(0xFFE0735F)
                                        : C.text,
                                    onTap: () {
                                      store.toggleFav(d);
                                      toast(
                                          context,
                                          store.isFav(d)
                                              ? 'Added to favorites'
                                              : 'Removed from favorites');
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  RoundIconButton(
                                      icon: Icons.shopping_cart_outlined,
                                      onTap: () => openCart(context)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.title, style: serif(30)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                StarRating(
                                    value: store.ratingOf(d), size: 18),
                                const SizedBox(width: 8),
                                Text(store.ratingOf(d).toStringAsFixed(1),
                                    style: sans(14,
                                        weight: FontWeight.w600)),
                                const SizedBox(width: 6),
                                Text('(${store.countOf(d)} ratings)',
                                    style: sans(12.5, color: C.muted)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: d.cats
                                  .map((c) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: const Color(0xFF5C4C36)),
                                        ),
                                        child: Text(c,
                                            style: sans(11.5,
                                                color: C.goldLight)),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 14),
                            Text(d.desc,
                                style:
                                    sans(14, color: C.muted, height: 1.55)),
                            const SizedBox(height: 26),
                            Text('Size', style: serif(20)),
                            const SizedBox(height: 12),
                            Row(
                              children: sizeExtra.keys.map((sz) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: NoirChip(
                                    label: sz,
                                    selected: sz == size,
                                    height: 42,
                                    fontSize: 15,
                                    hPad: 24,
                                    onTap: () => setState(() => size = sz),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 26),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Quantity', style: serif(20)),
                                QtyStepper(
                                  qty: qty,
                                  onMinus: () => setState(
                                      () => qty = qty > 1 ? qty - 1 : 1),
                                  onPlus: () => setState(() => qty++),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // ----- rating & review -----
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: cardDeco(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      saved == null
                                          ? 'Rate this drink'
                                          : 'Your rating',
                                      style: serif(20)),
                                  const SizedBox(height: 8),
                                  StarRating(
                                    value: draftStars.toDouble(),
                                    size: 32,
                                    onChanged: (v) =>
                                        setState(() => draftStars = v),
                                  ),
                                  const SizedBox(height: 10),
                                  noirField(commentCtrl, 'Review (optional)',
                                      maxLines: 3,
                                      hint: 'Tell others what you thought...'),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      GoldButton(
                                        label: saved == null
                                            ? 'Submit rating'
                                            : 'Update rating',
                                        height: 44,
                                        radius: 10,
                                        onTap: draftStars == 0
                                            ? null
                                            : () {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                store.rate(d, draftStars,
                                                    commentCtrl.text);
                                                toast(context,
                                                    'Thanks for your rating!');
                                              },
                                      ),
                                      if (saved != null) ...[
                                        const SizedBox(width: 12),
                                        Tap(
                                          onTap: () {
                                            store.removeReview(d);
                                            setState(() {
                                              draftStars = 0;
                                              commentCtrl.clear();
                                            });
                                            toast(context, 'Rating removed');
                                          },
                                          child: Text('Remove',
                                              style: sans(14,
                                                  color: C.danger)),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
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
                          toast(context, '${d.title} added to cart');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
      key: ValueKey('${it.drink.id}-${it.size}'),
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
        decoration: cardDeco(),
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
              onTap: () async {
                final order = store.placeOrder(cart.items);
                cart.clear();
                await showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: C.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    title: Text('Order placed', style: serif(24)),
                    content: Text(
                        'Thank you${store.profile.isGuest ? '' : ', ${store.profile.name.split(' ').first}'}! '
                        'Order ${order.id} (${money(order.total)}) is being prepared.',
                        style: sans(14, color: C.muted, height: 1.45)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('Done',
                            style: sans(15, color: C.goldLight)),
                      ),
                    ],
                  ),
                );
                if (context.mounted) {
                  Navigator.popUntil(context, (r) => r.isFirst);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= PROFILE =================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int tab = 0; // 0 orders, 1 ratings, 2 favorites

  Future<void> _edit() async {
    final p = store.profile;
    final name = TextEditingController(text: p.isGuest ? '' : p.name);
    final email = TextEditingController(text: p.email);
    final phone = TextEditingController(text: p.phone);
    final addr = TextEditingController(text: p.address);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            22, 16, 22, 22 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: C.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Edit profile', style: serif(24)),
              const SizedBox(height: 18),
              noirField(name, 'Full name'),
              const SizedBox(height: 12),
              noirField(email, 'Email', type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              noirField(phone, 'Phone', type: TextInputType.phone),
              const SizedBox(height: 12),
              noirField(addr, 'Delivery address', maxLines: 2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GoldButton(
                  label: 'Save',
                  height: 50,
                  radius: 12,
                  onTap: () {
                    store.updateProfile(Profile(
                      name: name.text.trim().isEmpty
                          ? 'Guest'
                          : name.text.trim(),
                      email: email.text.trim(),
                      phone: phone.text.trim(),
                      address: addr.text.trim(),
                    ));
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Clear my data?', style: serif(22)),
        content: Text(
            'This removes your profile, orders, ratings and favorites from this phone.',
            style: sans(14, color: C.muted, height: 1.45)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: sans(15, color: C.muted))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Clear', style: sans(15, color: C.danger))),
        ],
      ),
    );
    if (ok == true) store.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final p = store.profile;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Row(
                  children: [
                    RoundIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.pop(context)),
                    const SizedBox(width: 16),
                    Text('Profile', style: serif(26)),
                    const Spacer(),
                    RoundIconButton(icon: Icons.edit_outlined, onTap: _edit),
                  ],
                ),
                const SizedBox(height: 26),
                Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF9C7945), Color(0xFF65492B)],
                      ),
                      border: Border.all(color: const Color(0x66D9B87A)),
                    ),
                    child: p.isGuest
                        ? const Icon(Icons.person_outline,
                            size: 42, color: Color(0xFFECE4CF))
                        : Text(p.initials,
                            style: serif(32, color: const Color(0xFFFDFCE8))),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                    child: Text(p.isGuest ? 'Guest' : p.name,
                        style: serif(26))),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                      p.email.isNotEmpty
                          ? p.email
                          : 'Tap the pencil to set up your profile',
                      style: sans(13, color: C.muted)),
                ),
                if (p.phone.isNotEmpty || p.address.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: cardDeco(radius: 14),
                    child: Column(
                      children: [
                        if (p.phone.isNotEmpty)
                          _info(Icons.phone_outlined, p.phone),
                        if (p.phone.isNotEmpty && p.address.isNotEmpty)
                          const SizedBox(height: 10),
                        if (p.address.isNotEmpty)
                          _info(Icons.location_on_outlined, p.address),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    _stat('Orders', store.orders.length, 0),
                    const SizedBox(width: 10),
                    _stat('Ratings', store.reviews.length, 1),
                    const SizedBox(width: 10),
                    _stat('Favorites', store.favs.length, 2),
                  ],
                ),
                const SizedBox(height: 22),
                if (tab == 0) ..._orders(),
                if (tab == 1) ..._ratings(),
                if (tab == 2) ..._favorites(),
                const SizedBox(height: 30),
                Center(
                  child: Tap(
                    onTap: _confirmClear,
                    child: Text('Clear my data',
                        style: sans(14, color: C.danger)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _info(IconData i, String t) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(i, size: 18, color: C.goldLight),
          const SizedBox(width: 10),
          Expanded(child: Text(t, style: sans(13.5, height: 1.35))),
        ],
      );

  Widget _stat(String label, int n, int idx) {
    final sel = tab == idx;
    return Expanded(
      child: Tap(
        onTap: () => setState(() => tab = idx),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: sel
                  ? const [Color(0xFF7D6650), Color(0xFF5C4837)]
                  : const [Color(0xFF3E352C), Color(0xFF2D2722)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: sel ? const Color(0xFF9A7F66) : const Color(0xFF6A5538),
                width: 1.2),
          ),
          child: Column(
            children: [
              Text('$n', style: serif(24)),
              const SizedBox(height: 2),
              Text(label, style: sans(12.5, color: const Color(0xFFD9CFC4))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyTab(IconData icon, String title, String sub) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(icon, size: 44, color: C.goldLight),
            const SizedBox(height: 12),
            Text(title, style: serif(20)),
            const SizedBox(height: 4),
            Text(sub,
                textAlign: TextAlign.center,
                style: sans(13, color: C.muted)),
          ],
        ),
      );

  // ----- orders tab -----
  List<Widget> _orders() {
    if (store.orders.isEmpty) {
      return [
        _emptyTab(Icons.receipt_long_outlined, 'No orders yet',
            'Your past orders will appear here.')
      ];
    }
    return store.orders.map((o) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: cardDeco(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(o.id, style: sans(15, weight: FontWeight.w600)),
                const Spacer(),
                Text(money(o.total),
                    style: sans(15,
                        color: C.goldLight, weight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 2),
            Text(fmtDate(o.at), style: sans(12, color: C.muted)),
            const SizedBox(height: 10),
            ...o.lines.map((l) {
              final d = findDrink(l.drinkId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                    '${l.qty}×  ${d?.title ?? l.drinkId}  (${l.size})',
                    style: sans(13.5, color: const Color(0xFFD9CFC4))),
              );
            }),
            const SizedBox(height: 10),
            GoldButton(
              label: 'Reorder',
              height: 38,
              radius: 9,
              fontSize: 14,
              onTap: () {
                for (final l in o.lines) {
                  final d = findDrink(l.drinkId);
                  if (d != null) cart.add(d, l.size, l.qty);
                }
                openCart(context);
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  // ----- ratings tab -----
  List<Widget> _ratings() {
    final entries = store.reviews.entries.toList()
      ..sort((a, b) => b.value.at.compareTo(a.value.at));
    if (entries.isEmpty) {
      return [
        _emptyTab(Icons.star_outline_rounded, 'No ratings yet',
            'Open a drink and rate it to see it here.')
      ];
    }
    final out = <Widget>[];
    for (final e in entries) {
      final d = findDrink(e.key);
      if (d == null) continue;
      out.add(Tap(
        onTap: () => openDetail(context, d),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: cardDeco(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                    width: 60, height: 60, child: DrinkImage(drink: d)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title, style: sans(15, weight: FontWeight.w500)),
                    const SizedBox(height: 3),
                    StarRating(value: e.value.stars.toDouble(), size: 16),
                    if (e.value.comment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(e.value.comment,
                          style: sans(13,
                              color: const Color(0xFFD9CFC4), height: 1.4)),
                    ],
                    const SizedBox(height: 4),
                    Text(fmtDate(e.value.at),
                        style: sans(11.5, color: C.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return out;
  }

  // ----- favorites tab -----
  List<Widget> _favorites() {
    final list = menu.where((d) => store.isFav(d)).toList();
    if (list.isEmpty) {
      return [
        _emptyTab(Icons.favorite_border, 'No favorites yet',
            'Tap the heart on a drink to save it.')
      ];
    }
    return list.map((d) {
      return Tap(
        onTap: () => openDetail(context, d),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: cardDeco(),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                    width: 60, height: 60, child: DrinkImage(drink: d)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.title, style: sans(15, weight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: C.star),
                        const SizedBox(width: 3),
                        Text(store.ratingOf(d).toStringAsFixed(1),
                            style: sans(12.5, color: C.muted)),
                        const SizedBox(width: 10),
                        Text(money(d.price),
                            style: sans(13, color: C.goldLight)),
                      ],
                    ),
                  ],
                ),
              ),
              Tap(
                onTap: () => store.toggleFav(d),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.favorite,
                      size: 22, color: Color(0xFFE0735F)),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}