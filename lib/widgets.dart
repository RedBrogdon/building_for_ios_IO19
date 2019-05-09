// Copyright 2019 The Flutter Team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multiplatform/data/models.dart';
import 'package:multiplatform/data/veggie.dart';
import 'package:multiplatform/main.dart';

import 'adaptive_widgets.dart';

typedef VeggieTapCallback = void Function(int veggieId);

class VeggieCardList extends StatelessWidget {
  const VeggieCardList(this.veggies, this.onVeggieTap);

  final List<Veggie> veggies;
  final VeggieTapCallback onVeggieTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding:
          MediaQuery.of(context).padding + EdgeInsets.symmetric(vertical: 12),
      itemCount: veggies.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 8.0,
          ),
          child: VeggieCard(
            veggies[index],
            () => onVeggieTap(veggies[index].id),
          ),
        );
      },
    );
  }
}

class VeggieCard extends StatelessWidget {
  const VeggieCard(this.veggie, this.onPressed);

  final VoidCallback onPressed;

  final Veggie veggie;

  Widget _buildDetails(AdaptiveTextThemeData textTheme) {
    return AdaptiveBackground(
      color: Color.lerp(CupertinoColors.white, veggie.accentColor, 0.15)
          .withAlpha(140),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              veggie.name,
              style: textTheme.headline,
            ),
            SizedBox(height: 4),
            Text(
              veggie.shortDescription,
              style: textTheme.subhead,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = AdaptiveTextTheme.of(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      pressedOpacity: 0.7,
      child: FlatCard(
        height: 240,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              veggie.imageAssetPath,
              fit: BoxFit.fitWidth,
              semanticLabel: 'A card background featuring ${veggie.name}',
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: _buildDetails(textTheme),
            ),
          ],
        ),
      ),
    );
  }
}

class DailyDisplay extends StatelessWidget {
  const DailyDisplay(this.model);

  final DailySummaryViewModel model;

  @override
  Widget build(BuildContext context) {
    AdaptiveTextThemeData textTheme = AdaptiveTextTheme.of(context);

    return FloatingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat.MMMMEEEEd().format(model.day),
            style: textTheme.headline,
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: model.entries.map((e) {
              return FlatCard(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    ZoomClipAssetImage(
                      imageAsset: e.veggie.imageAssetPath,
                      zoom: 2.4,
                      height: 72,
                      width: 72,
                    ),
                    Text(e.servings.toString(),
                        style: TextStyle(
                          color: CupertinoColors.white.withAlpha(240),
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 35),
          Summary(
            calories: model.calories,
            vitaminA: model.vitaminAPercentage,
            vitaminC: model.vitaminCPercentage,
          ),
        ],
      ),
    );
  }
}

class LogEntryDisplay extends StatelessWidget {
  const LogEntryDisplay(this.model);

  final LogEntryViewModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(model.veggie.name),
        Text('Servings: ${model.servings}'),
      ],
    );
  }
}

class MainDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = AdaptiveTextTheme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'VeggieTracker',
                style: textTheme.headline,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context)
                ..pop()
                ..pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LogScreen(),
                  ),
                  (route) => false,
                );
            },
            leading: Icon(Icons.book),
            title: Text('Log'),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context)
                ..pop()
                ..push(MaterialPageRoute(
                  builder: (context) => ListScreen(),
                ));
            },
            leading: Icon(Icons.add),
            title: Text('Add from List'),
          ),
        ],
      ),
    );
  }
}

class FlatCard extends StatelessWidget {
  const FlatCard({this.height, this.width, @required this.child});

  final double height;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        border: Border.all(
            width: 1 / MediaQuery.of(context).devicePixelRatio,
            color: CupertinoColors.lightBackgroundGray),
        shape: BoxShape.rectangle,
      ),
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
        child: child,
      ),
    );
  }
}

class FloatingCard extends StatelessWidget {
  const FloatingCard({@required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: PhysicalModel(
        elevation: 25,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        color: CupertinoColors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}

class ZoomClipAssetImage extends StatelessWidget {
  const ZoomClipAssetImage(
      {@required this.zoom,
      this.height,
      this.width,
      @required this.imageAsset});

  final double zoom;
  final double height;
  final double width;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      child: ClipRect(
        child: OverflowBox(
          maxHeight: height * zoom,
          maxWidth: width * zoom,
          child: Image.asset(
            imageAsset,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

class Line extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 0,
              color: CupertinoColors.lightBackgroundGray,
            ),
          ),
        ),
      ),
    );
  }
}

class QuoteText extends StatelessWidget {
  static const quoteStyle = TextStyle(
    fontSize: 34,
    color: Color(0xDE000000),
    fontWeight: FontWeight.bold,
  );

  const QuoteText({@required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('“', style: quoteStyle),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(text, style: AdaptiveTextTheme.of(context).body),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('”', style: quoteStyle),
          ),
        ],
      ),
    );
  }
}

class Summary extends StatelessWidget {
  const Summary({
    @required this.calories,
    @required this.vitaminA,
    @required this.vitaminC,
  });

  final int calories;
  final int vitaminA;
  final int vitaminC;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SUMMARY',
            style: AdaptiveTextTheme.of(context).subhead.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xff202020),
                )),
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Nutrition(
                  name: 'Energy',
                  value: '$calories cal',
                  fraction: calories / 2000,
                  color: Color(0xFFEF8EA0),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Nutrition(
                  name: 'Vitamin A',
                  value: '$vitaminA% DV',
                  fraction: vitaminA / 100,
                  color: Color(0xFFB09CC6),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Nutrition(
                  name: 'Vitamin C',
                  value: '$vitaminC% DV',
                  fraction: vitaminC / 100,
                  color: Color(0xFF92B6F9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Nutrition extends StatelessWidget {
  const Nutrition({this.name, this.value, this.color, this.fraction});

  final String name;
  final String value;
  final Color color;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final textTheme = AdaptiveTextTheme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: textTheme.label),
        SizedBox(height: 1),
        SmallBar(
          filledFraction: fraction,
          color: color,
        ),
        Text(value, style: textTheme.bodySmall),
      ],
    );
  }
}

class SmallBar extends StatelessWidget {
  const SmallBar({this.filledFraction, this.color});

  final double filledFraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxWidth: 100,
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: CupertinoColors.lightBackgroundGray,
        ),
        alignment: Alignment.centerLeft,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              width: constraints.maxWidth * filledFraction,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: color,
              ),
            );
          },
        ),
      ),
    );
  }
}
