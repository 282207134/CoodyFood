import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/food.dart';
import '../state/app_state.dart';

void go(
  BuildContext context,
  String screen, {
  bool replace = false,
  Object? arguments,
}) {
  if (replace) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/$screen', (_) => false, arguments: arguments);
  } else {
    Navigator.of(context).pushNamed('/$screen', arguments: arguments);
  }
}

void back(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  } else {
    go(context, '201', replace: true);
  }
}

void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

Widget gap([double h = 16]) => SizedBox(height: h);
Widget label(
  String text, {
  Color? color,
  double size = 14,
  FontWeight weight = FontWeight.w400,
  int? lines,
}) => Text(
  text,
  maxLines: lines,
  overflow: lines == null ? null : TextOverflow.ellipsis,
  style: TextStyle(
    fontSize: size,
    color: color ?? CoodyColors.ink,
    fontWeight: weight,
  ),
);

class FoodImage extends StatelessWidget {
  const FoodImage(
    this.index, {
    super.key,
    this.width,
    this.height,
    this.radius = 10,
    this.fit = BoxFit.cover,
  });
  final int index;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/asset_${index.toString().padLeft(2, '0')}.webp',
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.text, this.onPressed, {super.key});
  final String text;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}

class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color = Colors.white,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  @override
  Widget build(BuildContext context) => Material(
    color: color,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: Padding(padding: padding, child: child),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.action, this.onAction});
  final String text;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: label(text, size: 18, weight: FontWeight.w700)),
      if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
    ],
  );
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    this.title,
    required this.body,
    this.tab,
    this.actions,
    this.bottom,
    this.white = false,
  });
  final String? title;
  final Widget body;
  final int? tab;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool white;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: white ? Colors.white : CoodyColors.background,
    appBar: title == null
        ? null
        : AppBar(
            title: Text(title!),
            leading: tab == null
                ? IconButton(
                    tooltip: 'Back',
                    onPressed: () => back(context),
                    icon: const Icon(Icons.chevron_left_rounded),
                  )
                : const SizedBox.shrink(),
            actions: actions,
          ),
    body: SafeArea(top: title == null, bottom: false, child: body),
    bottomNavigationBar: bottom != null
        ? Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            child: SafeArea(top: false, child: bottom!),
          )
        : tab == null
        ? null
        : BottomTabs(tab!),
  );
}

class BottomTabs extends StatelessWidget {
  const BottomTabs(this.selected, {super.key});
  final int selected;
  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.grid_view_rounded,
      Icons.location_on_outlined,
      Icons.receipt_long_outlined,
      Icons.notifications_none_rounded,
      Icons.person_outline_rounded,
    ];
    const names = ['Home', 'Discover', 'Orders', 'Updates', 'Profile'];
    const routes = ['201', '301', '401', '510', '501'];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: CoodyColors.background)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            children: List.generate(
              5,
              (i) => Expanded(
                child: InkWell(
                  onTap: () {
                    if (selected != i) go(context, routes[i], replace: true);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[i],
                        size: 23,
                        color: selected == i
                            ? CoodyColors.primary
                            : const Color(0xFFB3BAC5),
                      ),
                      gap(4),
                      label(
                        names[i],
                        size: 10,
                        color: selected == i
                            ? CoodyColors.primary
                            : CoodyColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    this.hint = 'Search on Coody',
    this.onTap,
    this.controller,
    this.onChanged,
    this.autofocus = false,
  });
  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    readOnly: onTap != null,
    onTap: onTap,
    autofocus: autofocus,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(
        Icons.search_rounded,
        size: 22,
        color: Color(0xFFB3BAC5),
      ),
      isDense: true,
    ),
  );
}

class RatingPill extends StatelessWidget {
  const RatingPill(this.rating, {super.key});
  final double rating;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: CoodyColors.primary,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: Colors.white),
        const SizedBox(width: 3),
        label(
          rating.toStringAsFixed(1),
          size: 12,
          color: Colors.white,
          weight: FontWeight.w700,
        ),
      ],
    ),
  );
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard(
    this.restaurant, {
    super.key,
    this.compact = false,
    this.onTap,
  });
  final Restaurant restaurant;
  final bool compact;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap ?? () => openRestaurant(context, r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: compact ? 1.65 : 1.78,
            child: FoodImage(r.image),
          ),
          gap(12),
          Row(
            children: [
              Flexible(
                child: label(
                  r.name,
                  size: compact ? 18 : 20,
                  weight: FontWeight.w500,
                  lines: 1,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.verified_user_rounded,
                size: 16,
                color: CoodyColors.green,
              ),
            ],
          ),
          gap(4),
          Row(
            children: [
              label(
                r.open ? 'Open' : 'Closed',
                size: 12,
                color: r.open ? CoodyColors.green : CoodyColors.primary,
              ),
              Flexible(
                child: label(
                  '  ·  ${compact ? 'Hanoi, Vietnam' : r.category}',
                  size: 12,
                  color: CoodyColors.muted,
                  lines: 1,
                ),
              ),
            ],
          ),
          gap(10),
          Wrap(
            spacing: 8,
            runSpacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              RatingPill(r.rating),
              label('${r.distance} km', size: 12, color: CoodyColors.muted),
              label(
                r.deliveryCents == 0
                    ? '·  Free shipping'
                    : '·  ${money(r.deliveryCents)} delivery',
                size: 12,
                color: CoodyColors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> openRestaurant(BuildContext context, Restaurant r) async {
  final state = AppScope.of(context);
  if (!r.open) {
    toast(context, '${r.name} is closed. Please choose an open restaurant.');
    return;
  }
  if (!state.selectRestaurant(r.id)) {
    final clear = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Start a new order?'),
        content: const Text(
          'Your current items are from another restaurant. Start a new order here?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep order'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Start new'),
          ),
        ],
      ),
    );
    if (clear != true || !context.mounted) return;
    state.cart.clear();
    state.selectRestaurant(r.id);
  }
  if (context.mounted) go(context, r.id == 'starbucks' ? '213' : '214');
}

class QuantityControl extends StatelessWidget {
  const QuantityControl(this.quantity, this.minus, this.plus, {super.key});
  final int quantity;
  final VoidCallback minus, plus;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        tooltip: 'Decrease quantity',
        visualDensity: VisualDensity.compact,
        onPressed: minus,
        icon: const Icon(
          Icons.remove_circle_outline_rounded,
          color: CoodyColors.muted,
          size: 22,
        ),
      ),
      label('$quantity', weight: FontWeight.w500),
      IconButton(
        tooltip: 'Increase quantity',
        visualDensity: VisualDensity.compact,
        onPressed: plus,
        icon: const Icon(
          Icons.add_circle_rounded,
          color: CoodyColors.primary,
          size: 22,
        ),
      ),
    ],
  );
}

class EmojiTile extends StatelessWidget {
  const EmojiTile(
    this.emoji, {
    super.key,
    this.size = 80,
    this.color = CoodyColors.peach,
  });
  final String emoji;
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(size / 4),
    ),
    child: Text(emoji, style: TextStyle(fontSize: size * .45)),
  );
}
