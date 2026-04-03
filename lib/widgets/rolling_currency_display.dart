import 'package:flutter/material.dart';

import '../meeting_cost_engine.dart';

class RollingCurrencyDisplay extends StatelessWidget {
  const RollingCurrencyDisplay({
    super.key,
    required this.value,
    required this.style,
  });

  final double value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final displayStyle = style.copyWith(
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final formatted = formatCurrency(value);
    final scaledValue = value.isFinite && value > 0 ? value * 100 : 0.0;
    var divisor = 1.0;
    final placeValues = <double?>[];

    for (final character in formatted.split('').reversed) {
      if (_isDigit(character)) {
        placeValues.insert(0, scaledValue / divisor);
        divisor *= 10;
      } else {
        placeValues.insert(0, null);
      }
    }

    final digitSize = _measureDigit(displayStyle);
    final punctuationStyle = displayStyle.copyWith(
      color: displayStyle.color?.withValues(alpha: 0.78),
    );

    return Semantics(
      label: formatted,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var index = 0; index < formatted.length; index++)
              if (_isDigit(formatted[index]))
                _RollingDigit(
                  placeValue: placeValues[index]!,
                  style: displayStyle,
                  size: digitSize,
                )
              else
                Padding(
                  padding: EdgeInsets.only(
                    left: formatted[index] == '\$' ? 0 : 1,
                    right: formatted[index] == '.' ? 1 : 2,
                  ),
                  child: Text(formatted[index], style: punctuationStyle),
                ),
          ],
        ),
      ),
    );
  }

  Size _measureDigit(TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: '8', style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    return painter.size;
  }

  bool _isDigit(String character) => RegExp(r'^\d$').hasMatch(character);
}

class _RollingDigit extends StatelessWidget {
  const _RollingDigit({
    required this.placeValue,
    required this.style,
    required this.size,
  });

  final double placeValue;
  final TextStyle style;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final currentDigit = placeValue.floor() % 10;

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Text('$currentDigit', style: style),
    );
  }
}
