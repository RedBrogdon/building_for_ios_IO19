import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:multiplatform/widgets.dart';

bool get _isIOS => foundation.defaultTargetPlatform == TargetPlatform.iOS;

class AdaptiveSegmentedControl extends StatelessWidget {
  AdaptiveSegmentedControl({
    this.onValueChanged,
    this.children,
    this.groupValue,
  });

  final ValueChanged<int> onValueChanged;
  final Map<int, Widget> children;
  final int groupValue;

  @override
  Widget build(BuildContext context) {
    if (_isIOS) {
      return CupertinoSegmentedControl<int>(
        children: children,
        groupValue: groupValue,
        onValueChanged: onValueChanged,
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final key in children.keys)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: RaisedButton(
                child: children[key],
                color: groupValue == key
                    ? Theme.of(context).buttonTheme.colorScheme.primary
                    : Color(0xffcccccc),
                onPressed: () {
                  onValueChanged(key);
                },
              ),
            ),
        ],
      );
    }
  }
}

class AdaptiveBackground extends StatelessWidget {
  const AdaptiveBackground({this.color, this.intensity = 25, this.child});

  final Color color;
  final double intensity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: (_isIOS)
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: intensity, sigmaY: intensity),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                ),
                child: child,
              ),
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                color: color.withAlpha(0xe8),
              ),
              child: child,
            ),
    );
  }
}

class AdaptivePageScaffold extends StatelessWidget {
  const AdaptivePageScaffold({
    @required this.title,
    @required this.child,
  })  : assert(title != null),
        assert(child != null);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (_isIOS) {
      return AdaptiveTextTheme(
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text(title),
          ),
          resizeToAvoidBottomInset: false,
          child: child,
        ),
      );
    } else {
      return AdaptiveTextTheme(
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          drawer: ModalRoute.of(context).isFirst ? MainDrawer() : null,
          body: child,
        ),
      );
    }
  }
}

class AdaptiveSlider extends StatelessWidget {
  const AdaptiveSlider({
    this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    Key key,
  }) : super(key: key);

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;

  @override
  Widget build(BuildContext context) {
    if (_isIOS) {
      return CupertinoSlider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
      );
    } else {
      return Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
      );
    }
  }
}

class AdaptiveTextField extends StatelessWidget {
  const AdaptiveTextField({
    this.maxLines,
    this.controller,
    this.focusNode,
    this.textAlign,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
    this.style,
    Key key,
  }) : super(key: key);

  final int maxLines;
  final TextEditingController controller;
  final FocusNode focusNode;
  final TextAlign textAlign;
  final TextInputType keyboardType;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (_isIOS) {
      return CupertinoTextField(
        maxLines: maxLines,
        controller: controller,
        focusNode: focusNode,
        textAlign: textAlign,
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: onChanged,
        style: style,
      );
    } else {
      return TextField(
        maxLines: maxLines,
        controller: controller,
        focusNode: focusNode,
        textAlign: textAlign,
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: onChanged,
        style: style,
      );
    }
  }
}

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    this.child,
    this.onPressed,
    Key key,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (_isIOS) {
      return CupertinoButton.filled(
        child: child,
        onPressed: onPressed,
      );
    } else {
      return RaisedButton(
        child: child,
        onPressed: onPressed,
      );
    }
  }
}

class AdaptiveTextTheme extends StatelessWidget {
  const AdaptiveTextTheme({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final materialThemeData = Theme.of(context);
    final cupertinoThemeData = CupertinoTheme.of(context);

    return _AdaptiveTextThemeProvider(
      data: AdaptiveTextThemeData(
        materialThemeData?.textTheme,
        cupertinoThemeData?.textTheme,
      ),
      child: child,
    );
  }

  static AdaptiveTextThemeData of(BuildContext context) {
    final provider =
        context.inheritFromWidgetOfExactType(_AdaptiveTextThemeProvider)
            as _AdaptiveTextThemeProvider;
    return provider?.data;
  }
}

class _AdaptiveTextThemeProvider extends InheritedWidget {
  _AdaptiveTextThemeProvider({
    this.data,
    @required Widget child,
    Key key,
  }) : super(child: child, key: key);

  final AdaptiveTextThemeData data;

  @override
  bool updateShouldNotify(_AdaptiveTextThemeProvider oldWidget) {
    return data != oldWidget.data;
  }
}

class AdaptiveTextThemeData {
  const AdaptiveTextThemeData(this.materialThemeData, this.cupertinoThemeData);

  final TextTheme materialThemeData;
  final CupertinoTextThemeData cupertinoThemeData;

  TextStyle get headline =>
      (materialThemeData?.headline ?? cupertinoThemeData.navLargeTitleTextStyle)
          .copyWith(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.6,
      );

  TextStyle get subhead =>
      (materialThemeData?.subhead ?? cupertinoThemeData.textStyle).copyWith(
        color: Color(0xDE000000),
        fontSize: 14,
        letterSpacing: 0.1,
      );

  TextStyle get tileTitle =>
      (materialThemeData?.body2 ?? cupertinoThemeData.textStyle).copyWith(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  TextStyle get bodySmall =>
      (materialThemeData?.body2 ?? cupertinoThemeData.textStyle).copyWith(
        color: Color(0xDE000000),
        fontSize: 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w500,
      );

  TextStyle get body =>
      (materialThemeData?.subhead ?? cupertinoThemeData.navTitleTextStyle)
          .copyWith(
        color: Color(0xDE000000),
        fontSize: 14.05,
        letterSpacing: 0.25,
        fontWeight: FontWeight.w500,
      );

  TextStyle get label =>
      (materialThemeData?.body2 ?? cupertinoThemeData.textStyle).copyWith(
        fontStyle: FontStyle.italic,
        fontSize: 12,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w500,
        color: Color(0x99000000),
      );

  @override
  int get hashCode => materialThemeData.hashCode ^ cupertinoThemeData.hashCode;

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final AdaptiveTextThemeData typedOther = other;
    return materialThemeData != typedOther.materialThemeData ||
        cupertinoThemeData != typedOther.cupertinoThemeData;
  }
}
