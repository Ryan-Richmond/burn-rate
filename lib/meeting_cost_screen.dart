import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'meeting_cost_engine.dart';
import 'widgets/rolling_currency_display.dart';

class MeetingCostScreen extends StatefulWidget {
  const MeetingCostScreen({super.key});

  @override
  State<MeetingCostScreen> createState() => _MeetingCostScreenState();
}

class _MeetingCostScreenState extends State<MeetingCostScreen> {
  final _attendeeController = TextEditingController();
  final _salaryController = TextEditingController();

  Timer? _ticker;
  DateTime? _runningStartedAt;
  Duration _elapsedBeforeRun = Duration.zero;
  Duration _manualAdvance = Duration.zero;
  bool _isFullScreen = false;

  bool get _isRunning => _runningStartedAt != null;

  int? get _attendeeCount => parseAttendeeCount(_attendeeController.text);
  double? get _averageSalary => parseSalary(_salaryController.text);

  bool get _hasValidInputs {
    final attendees = _attendeeCount;
    final salary = _averageSalary;
    return attendees != null && attendees > 0 && salary != null && salary > 0;
  }

  Duration get _elapsed {
    var total = _elapsedBeforeRun + _manualAdvance;
    if (_runningStartedAt != null) {
      total += DateTime.now().difference(_runningStartedAt!);
    }
    return total;
  }

  double get _currentCost {
    if (!_hasValidInputs) {
      return 0;
    }

    return calculateMeetingCost(
      elapsed: _elapsed,
      attendeeCount: _attendeeCount!,
      averageSalary: _averageSalary!,
    );
  }

  double get _hourlyRate {
    if (!_hasValidInputs) {
      return 0;
    }

    return calculateHourlyRate(
      attendeeCount: _attendeeCount!,
      averageSalary: _averageSalary!,
    );
  }

  double get _perMinuteRate {
    if (!_hasValidInputs) {
      return 0;
    }

    return calculatePerMinuteRate(
      attendeeCount: _attendeeCount!,
      averageSalary: _averageSalary!,
    );
  }

  double get _perSecondRate {
    if (!_hasValidInputs) {
      return 0;
    }

    return calculatePerSecondRate(
      attendeeCount: _attendeeCount!,
      averageSalary: _averageSalary!,
    );
  }

  @override
  void initState() {
    super.initState();
    _attendeeController.addListener(_handleInputChanged);
    _salaryController.addListener(_handleInputChanged);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _attendeeController
      ..removeListener(_handleInputChanged)
      ..dispose();
    _salaryController
      ..removeListener(_handleInputChanged)
      ..dispose();
    super.dispose();
  }

  void _handleInputChanged() {
    setState(() {});
  }

  void _startTimer() {
    if (_isRunning || !_hasValidInputs) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _runningStartedAt = DateTime.now();
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(displayRefreshInterval, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) {
      return;
    }

    setState(() {
      _elapsedBeforeRun += DateTime.now().difference(_runningStartedAt!);
      _runningStartedAt = null;
    });
    _ticker?.cancel();
    _ticker = null;
  }

  void _resetTimer() {
    setState(() {
      _runningStartedAt = null;
      _elapsedBeforeRun = Duration.zero;
      _manualAdvance = Duration.zero;
    });
    _ticker?.cancel();
    _ticker = null;
  }

  void _pushAhead(Duration amount) {
    setState(() {
      _manualAdvance += amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompact = MediaQuery.of(context).size.width < 780;

    if (_isFullScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFF06090E),
        body: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RollingCurrencyDisplay(
                    value: _currentCost,
                    style: theme.textTheme.displayLarge!.copyWith(
                      fontSize: 300,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -6,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: SafeArea(
                child: IconButton(
                  icon: const Icon(
                    Icons.fullscreen_exit,
                    color: Colors.white54,
                    size: 36,
                  ),
                  onPressed: () => setState(() => _isFullScreen = false),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final inputsPanel = _Panel(
      eyebrow: 'Meeting Inputs',
      title: 'Define the room',
      subtitle:
          'Salary is treated as yearly USD compensation and converted to hourly, then by the second using 2,080 working hours per year.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _attendeeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Number of attendees',
              hintText: '8',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _salaryController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Average annual salary (USD)',
              hintText: '175000',
              prefixText: '\$',
            ),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _hasValidInputs
                ? _RateSummary(
                    hourlyRate: _hourlyRate,
                    perMinuteRate: _perMinuteRate,
                    perSecondRate: _perSecondRate,
                  )
                : Text(
                    'Enter at least 1 attendee and a salary above \$0 to unlock the live meter.',
                    key: const ValueKey('hint'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
          ),
        ],
      ),
    );

    final controlsPanel = _Panel(
      eyebrow: 'Controls',
      title: 'Run the meter',
      subtitle:
          'Use quick offsets when the timer starts late so the total reflects the real meeting cost, not just the visible clock time.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: _hasValidInputs && !_isRunning ? _startTimer : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
              OutlinedButton.icon(
                onPressed: _isRunning ? _pauseTimer : null,
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
              ),
              OutlinedButton.icon(
                onPressed:
                    _elapsed > Duration.zero || _manualAdvance > Duration.zero
                    ? _resetTimer
                    : null,
                icon: const Icon(Icons.replay),
                label: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Push Ahead',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _JumpButton(
                label: '+30 sec',
                onPressed: () => _pushAhead(const Duration(seconds: 30)),
              ),
              _JumpButton(
                label: '+1 min',
                onPressed: () => _pushAhead(const Duration(minutes: 1)),
              ),
              _JumpButton(
                label: '+5 min',
                onPressed: () => _pushAhead(const Duration(minutes: 5)),
              ),
              _JumpButton(
                label: '+15 min',
                onPressed: () => _pushAhead(const Duration(minutes: 15)),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB648).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.schedule, color: Color(0xFFFFC566)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visible clock',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatElapsed(_elapsed),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF090F16), Color(0xFF11151D), Color(0xFF06090E)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Burn Rate', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 10),
                    Text(
                      'Turn attendee count and average annual salary into a live meeting burn meter. Start on time, or push the clock ahead when the meeting is already underway.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    _DisplayCard(
                      isRunning: _isRunning,
                      isReady: _hasValidInputs,
                      attendeeCount: _attendeeCount,
                      elapsed: _elapsed,
                      lateStart: _manualAdvance,
                      hourlyRate: _hourlyRate,
                      cost: _currentCost,
                      compact: isCompact,
                      onFullScreen: _hasValidInputs
                          ? () => setState(() => _isFullScreen = true)
                          : null,
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wideLayout = constraints.maxWidth >= 880;

                        if (wideLayout) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: inputsPanel),
                              const SizedBox(width: 22),
                              Expanded(child: controlsPanel),
                            ],
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            inputsPanel,
                            const SizedBox(height: 22),
                            controlsPanel,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DisplayCard extends StatelessWidget {
  const _DisplayCard({
    required this.isRunning,
    required this.isReady,
    required this.attendeeCount,
    required this.elapsed,
    required this.lateStart,
    required this.hourlyRate,
    required this.cost,
    required this.compact,
    this.onFullScreen,
  });

  final bool isRunning;
  final bool isReady;
  final int? attendeeCount;
  final Duration elapsed;
  final Duration lateStart;
  final double hourlyRate;
  final double cost;
  final bool compact;
  final VoidCallback? onFullScreen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyStyle =
        theme.textTheme.displayLarge?.copyWith(
          fontSize: compact ? 52 : 88,
          fontWeight: FontWeight.w800,
          letterSpacing: -3,
          color: Colors.white,
        ) ??
        TextStyle(
          fontSize: compact ? 52 : 88,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 20 : 28,
        compact ? 22 : 28,
        compact ? 20 : 28,
        compact ? 24 : 30,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF35210C), Color(0xFF7C4A0E), Color(0xFF191E2A)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55240F00),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isRunning
                      ? const Color(0xFFFFD8A1).withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isRunning
                        ? const Color(0xFFFFC566).withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  isRunning ? 'Meter running' : 'Ready to start',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isRunning
                        ? const Color(0xFFFFD995)
                        : Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                isReady
                    ? 'Burning ${formatCurrency(hourlyRate)}/hr'
                    : 'Enter meeting details to calculate the burn rate',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.76),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live meeting cost',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                ),
              ),
              if (onFullScreen != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.fullscreen, color: Colors.white54),
                  onPressed: onFullScreen,
                ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RollingCurrencyDisplay(value: cost, style: currencyStyle),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(
                label: 'Attendees',
                value: attendeeCount?.toString() ?? '--',
              ),
              _MetricChip(label: 'Elapsed', value: formatElapsed(elapsed)),
              _MetricChip(label: 'Late start', value: formatElapsed(lateStart)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eyebrow.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFFFFC566),
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateSummary extends StatelessWidget {
  const _RateSummary({
    required this.hourlyRate,
    required this.perMinuteRate,
    required this.perSecondRate,
  });

  final double hourlyRate;
  final double perMinuteRate;
  final double perSecondRate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const ValueKey('summary'),
      spacing: 12,
      runSpacing: 12,
      children: [
        _SummaryStat(
          label: 'Per hour',
          value: '${formatCurrency(hourlyRate)}/hr',
        ),
        _SummaryStat(
          label: 'Per minute',
          value: '${formatCurrency(perMinuteRate)}/min',
        ),
        _SummaryStat(
          label: 'Per second',
          value: '${formatCurrency(perSecondRate)}/sec',
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B121A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _JumpButton extends StatelessWidget {
  const _JumpButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        backgroundColor: const Color(0xFF161F2B),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label),
    );
  }
}
