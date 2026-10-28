import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/catalog.dart';
import '../models/food.dart';
import '../state/app_state.dart';
import '../ui/components.dart';

const categoryNames = ['Burgers', 'Pizza', 'Sandwich', 'Coffee', 'Chicken'];
const categoryImages = [6, 5, 4, 21, 11];

List<Restaurant> filteredRestaurants(AppState s, [String query = '']) {
  final result = restaurants
      .where(
        (r) =>
            (s.category == 'All' || r.category == s.category) &&
            '${r.name} ${r.category}'.toLowerCase().contains(
              query.toLowerCase(),
            ) &&
            r.deliveryCents <= s.maxFee &&
            (s.priceLevel >= 2 || r.category == 'Burgers'),
      )
      .toList();
  if (s.sort == 'Fastest Delivery' || s.sort == 'Nearby') {
    result.sort((a, b) => a.distance.compareTo(b.distance));
  }
  if (s.sort == 'Most Popular' || s.sort == 'Rate') {
    result.sort((a, b) => b.rating.compareTo(a.rating));
  }
  return result;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.variant = 201});
  final int variant;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final list = filteredRestaurants(state);
    return PageFrame(
      tab: 0,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(35, 16, 35, 18),
            child: Column(
              children: [
                SearchBox(onTap: () => go(context, '211')),
                gap(20),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: CoodyColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => go(context, '508'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            label(
                              'Delivery to',
                              size: 12,
                              color: CoodyColors.muted,
                            ),
                            gap(2),
                            label(
                              state.address,
                              weight: FontWeight.w500,
                              lines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: CoodyColors.background,
                        foregroundColor: CoodyColors.ink,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        minimumSize: const Size(0, 34),
                      ),
                      onPressed: () => go(context, '207'),
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: const Text(
                        'Filter',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                if (variant != 202) ...[
                  Surface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle('Category'),
                        gap(20),
                        SizedBox(
                          height: 142,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categoryNames.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 16),
                            itemBuilder: (c, i) => SizedBox(
                              width: 95,
                              child: InkWell(
                                onTap: () {
                                  state.category = categoryNames[i];
                                  state.commit();
                                  go(context, '204');
                                },
                                child: Column(
                                  children: [
                                    FoodImage(
                                      categoryImages[i],
                                      height: 96,
                                      width: 95,
                                      radius: 14,
                                    ),
                                    gap(12),
                                    label(categoryNames[i], size: 13, lines: 1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        PrimaryButton('See all', () => go(context, '210')),
                      ],
                    ),
                  ),
                  gap(15),
                ],
                if (variant != 203) ...[
                  Surface(
                    child: Column(
                      children: [
                        const SectionTitle('Best Partners'),
                        gap(20),
                        SizedBox(
                          height: 258,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 20),
                            itemBuilder: (c, i) => SizedBox(
                              width: 205,
                              child: RestaurantCard(
                                restaurants[i],
                                compact: true,
                              ),
                            ),
                          ),
                        ),
                        gap(8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: CoodyColors.background,
                              foregroundColor: CoodyColors.ink,
                              minimumSize: const Size(0, 44),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => go(context, '204'),
                            child: const Text('See all'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  gap(15),
                ],
                Surface(
                  child: Column(
                    children: [
                      _SortTabs(
                        onChanged: (s) {
                          state.sort = s;
                          state.commit();
                        },
                        selected: state.sort,
                      ),
                      gap(20),
                      if (list.isEmpty)
                        const EmptyResults()
                      else if (variant == 201 || variant == 206)
                        ...list.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 28),
                            child: RestaurantCard(r),
                          ),
                        )
                      else
                        ...list.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: RestaurantRow(r),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (variant == 206 || state.activeOrder)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
              child: Row(
                children: [
                  const EmojiTile('🛵', size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label(
                          'Your food is on the way',
                          weight: FontWeight.w500,
                          size: 13,
                        ),
                        label(
                          'Coming within 15 mins',
                          size: 12,
                          color: CoodyColors.muted,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => go(context, '401', replace: true),
                    child: const Text(
                      'Detail Order',
                      style: TextStyle(fontSize: 12),
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

class _SortTabs extends StatelessWidget {
  const _SortTabs({required this.onChanged, required this.selected});
  final ValueChanged<String> onChanged;
  final String selected;
  @override
  Widget build(BuildContext context) => Row(
    children: ['Nearby', 'Sales', 'Rate', 'Fast']
        .map(
          (s) => Expanded(
            child: InkWell(
              onTap: () => onChanged(
                s == 'Fast'
                    ? 'Fastest Delivery'
                    : s == 'Sales'
                    ? 'Most Popular'
                    : s,
              ),
              child: Container(
                padding: const EdgeInsets.only(bottom: 14, top: 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          selected == s ||
                              (s == 'Nearby' && selected == 'Recommended') ||
                              (s == 'Sales' && selected == 'Most Popular') ||
                              (s == 'Fast' && selected == 'Fastest Delivery')
                          ? CoodyColors.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: label(
                    s,
                    size: 13,
                    color: selected == s
                        ? CoodyColors.primary
                        : CoodyColors.muted,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList(),
  );
}

class RestaurantRow extends StatelessWidget {
  const RestaurantRow(this.restaurant, {super.key});
  final Restaurant restaurant;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => openRestaurant(context, restaurant),
    child: Row(
      children: [
        FoodImage(restaurant.image, width: 92, height: 92),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              label(restaurant.name, size: 18, weight: FontWeight.w500),
              gap(5),
              label(
                '${restaurant.open ? 'Open' : 'Closed'}  ·  ${restaurant.category}',
                size: 12,
                color: CoodyColors.muted,
              ),
              gap(10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  RatingPill(restaurant.rating),
                  label(
                    '${restaurant.distance} km',
                    size: 12,
                    color: CoodyColors.muted,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFFB3BAC5)),
      ],
    ),
  );
}

class PartnersPage extends StatelessWidget {
  const PartnersPage(this.grid, {super.key});
  final bool grid;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final list = filteredRestaurants(state);
    return PageFrame(
      title: state.category == 'All' ? 'Best Partners' : state.category,
      actions: [
        IconButton(
          tooltip: grid ? 'List view' : 'Grid view',
          onPressed: () => go(context, grid ? '204' : '205'),
          icon: Icon(
            grid ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
          ),
        ),
        IconButton(
          tooltip: 'Reset filters',
          onPressed: () {
            state.category = 'All';
            state.maxFee = 1000;
            state.priceLevel = 5;
            state.commit();
          },
          icon: const Icon(Icons.filter_alt_off_outlined),
        ),
      ],
      body: list.isEmpty
          ? const EmptyResults()
          : grid
          ? GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 280,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: list.length,
              itemBuilder: (c, i) => RestaurantCard(list[i], compact: true),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(35),
              itemCount: list.length,
              separatorBuilder: (_, _) => gap(32),
              itemBuilder: (c, i) => RestaurantCard(list[i]),
            ),
    );
  }
}

class EmptyResults extends StatelessWidget {
  const EmptyResults({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const EmojiTile('🍽️'),
        gap(20),
        label('No restaurants found', size: 18, weight: FontWeight.w700),
        gap(8),
        const Text(
          'Try another search or change your filters.',
          textAlign: TextAlign.center,
          style: TextStyle(color: CoodyColors.muted),
        ),
      ],
    ),
  );
}

class FiltersPage extends StatelessWidget {
  const FiltersPage(this.screen, {super.key});
  final int screen;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const HomePage(),
      Positioned.fill(
        child: ColoredBox(color: Colors.black.withValues(alpha: .28)),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: SafeArea(top: false, child: FilterPanel(screen: screen)),
        ),
      ),
    ],
  );
}

class FilterPanel extends StatefulWidget {
  const FilterPanel({super.key, required this.screen});
  final int screen;
  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  int tab = 0, price = 5;
  double fee = 1000;
  String category = 'All', sort = 'Recommended';
  @override
  void initState() {
    super.initState();
    tab = widget.screen == 208
        ? 1
        : widget.screen >= 209
        ? 2
        : 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final s = AppScope.of(context);
    category = s.category;
    sort = s.sort;
    price = s.priceLevel;
    fee = s.maxFee.toDouble();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .8,
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(35, 12, 35, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFDFE1E6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          gap(8),
          Row(
            children: [
              Expanded(
                child: label('Filter', size: 18, weight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () => setState(() {
                  category = 'All';
                  sort = 'Recommended';
                  price = 5;
                  fee = 1000;
                }),
                child: const Text('Reset'),
              ),
              IconButton(
                tooltip: 'Close filter',
                onPressed: () => back(context),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: TextButton(
                  onPressed: () => setState(() => tab = i),
                  style: TextButton.styleFrom(
                    foregroundColor: i == tab
                        ? CoodyColors.primary
                        : CoodyColors.muted,
                  ),
                  child: Text(['Category', 'Sort by', 'Price'][i]),
                ),
              ),
            ),
          ),
          const Divider(),
          if (tab == 0 || widget.screen == 210) ...[
            Wrap(
              spacing: 12,
              runSpacing: 16,
              children: List.generate(
                categoryNames.length,
                (i) => SizedBox(
                  width: 82,
                  child: InkWell(
                    onTap: () => setState(() => category = categoryNames[i]),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: category == categoryNames[i]
                                  ? CoodyColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: FoodImage(
                            categoryImages[i],
                            width: 72,
                            height: 72,
                          ),
                        ),
                        gap(6),
                        label(categoryNames[i], size: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            gap(16),
            ChoiceChip(
              label: const Text('All categories'),
              selected: category == 'All',
              onSelected: (_) => setState(() => category = 'All'),
            ),
          ],
          if (tab == 1 || widget.screen == 210)
            ...['Recommended', 'Fastest Delivery', 'Most Popular'].map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: label(s),
                trailing: Icon(
                  sort == s
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: sort == s
                      ? CoodyColors.primary
                      : const Color(0xFFDFE1E6),
                ),
                onTap: () => setState(() => sort = s),
              ),
            ),
          if (tab == 2 || widget.screen == 210) ...[
            label('Price Range', weight: FontWeight.w500),
            gap(16),
            Row(
              children: List.generate(
                5,
                (i) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () => setState(() => price = i + 1),
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: price == i + 1
                              ? CoodyColors.peach
                              : CoodyColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: label(
                          '\$' * (i + 1),
                          size: 12,
                          color: price == i + 1
                              ? CoodyColors.primary
                              : CoodyColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            gap(28),
            label('Max Delivery Fee', weight: FontWeight.w500),
            gap(8),
            Slider(
              value: fee,
              min: 0,
              max: 1000,
              divisions: 20,
              onChanged: (v) => setState(() => fee = v),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                label('Free', color: CoodyColors.muted, size: 12),
                label(money(fee.round()), size: 12),
              ],
            ),
          ],
          gap(24),
          PrimaryButton('Complete', () {
            final s = AppScope.of(context);
            s.category = category;
            s.sort = sort;
            s.priceLevel = price;
            s.maxFee = fee.round();
            s.commit();
            go(context, '204');
          }),
        ],
      ),
    ),
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage(this.screen, {super.key});
  final int screen;
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final input = TextEditingController(text: 'Pizza');
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final query = input.text.trim().toLowerCase();
    final results = foods
        .where((f) => '${f.name} ${f.category}'.toLowerCase().contains(query))
        .toList();
    final shops = restaurants
        .where((r) => '${r.name} ${r.category}'.toLowerCase().contains(query))
        .toList();
    return PageFrame(
      title: 'Search',
      white: true,
      body: ListView(
        padding: const EdgeInsets.all(35),
        children: [
          SearchBox(controller: input, onChanged: (_) => setState(() {})),
          gap(24),
          if (query.isEmpty) ...[
            const SectionTitle('Recent searches'),
            gap(12),
            Wrap(
              spacing: 8,
              children: state.recentSearches
                  .map(
                    (q) => ActionChip(
                      label: Text(q),
                      onPressed: () => setState(() => input.text = q),
                    ),
                  )
                  .toList(),
            ),
          ] else ...[
            SectionTitle(
              'Food',
              action: 'Filter',
              onAction: () => go(context, '207'),
            ),
            gap(16),
            for (final f in results)
              Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: InkWell(
                  onTap: () {
                    final restaurant = restaurantForFood(f);
                    if (!state.selectRestaurant(restaurant)) {
                      toast(
                        context,
                        'Finish or clear your current order first.',
                      );
                      return;
                    }
                    go(context, '216', arguments: f.id);
                  },
                  child: Row(
                    children: [
                      FoodImage(
                        f.image,
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            label(f.name, weight: FontWeight.w500, lines: 2),
                            gap(5),
                            label(money(f.cents), color: CoodyColors.primary),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.add_circle_outline,
                        color: CoodyColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            if (results.isEmpty && shops.isEmpty) const EmptyResults(),
            if (shops.isNotEmpty) ...[
              gap(12),
              const SectionTitle('Restaurants'),
              gap(20),
              for (final r in shops)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: widget.screen == 212
                      ? RestaurantCard(r)
                      : RestaurantRow(r),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
