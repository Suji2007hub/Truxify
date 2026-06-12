import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  bool _isLoading = true;
  int _currentYear = 2026;
  int _currentMonth = 5;
  late DateTime _selectedDate;

  final Map<String, Map<String, dynamic>> _dailyData = {
    '2026-05-01': {
      'earnings': 3800.0,
      'hours': 8.5,
      'trips': [
        {
          'route': 'Surat → Vadodara',
          'customer': 'Karthik Murugan',
          'amount': '₹3,800',
          'status': 'Delivered',
          'hash': '0x3a574d5c8f2c...31128',
          'verified': true,
        }
      ],
    },
    '2026-05-02': {
      'earnings': 0.0,
      'hours': 2.0,
      'trips': [
        {
          'route': 'Vadodara → Mumbai',
          'customer': 'Mehta Traders',
          'amount': '₹0',
          'status': 'Cancelled',
          'hash': '0x1aa63bce90...c901',
          'verified': false,
        }
      ],
    },
    '2026-05-03': {
      'earnings': 1300.0,
      'hours': 4.0,
      'trips': [
        {
          'route': 'Surat → Mumbai',
          'customer': 'Raj Textiles',
          'amount': '₹1,300',
          'status': 'Delivered',
          'hash': '0x4f128bc...de98',
          'verified': true,
        }
      ],
    },
    '2026-05-04': {
      'earnings': 1200.0,
      'hours': 3.5,
      'trips': [
        {
          'route': 'Surat → Mumbai',
          'customer': 'Mehta Traders',
          'amount': '₹1,200',
          'status': 'Delivered',
          'hash': '0x8f2d5e1...bc90',
          'verified': true,
        }
      ],
    },
    '2026-05-05': {
      'earnings': 3400.0,
      'hours': 7.8,
      'trips': [
        {
          'route': 'Vadodara → Pune',
          'customer': 'Sri Textiles',
          'amount': '₹3,400',
          'status': 'Delivered',
          'hash': '0x9cf11a4b5e...1b39',
          'verified': true,
        }
      ],
    },
    '2026-05-06': {
      'earnings': 2100.0,
      'hours': 5.0,
      'trips': [
        {
          'route': 'Vadodara → Mumbai',
          'customer': 'Mehta Traders',
          'amount': '₹2,100',
          'status': 'Delivered',
          'hash': '0x2d9e1f4...5def',
          'verified': true,
        }
      ],
    },
    '2026-05-07': {
      'earnings': 4800.0,
      'hours': 8.2,
      'trips': [
        {
          'route': 'Ahmedabad → Pune',
          'customer': 'Sri Textiles',
          'amount': '₹4,800',
          'status': 'Delivered',
          'hash': '0x9cf11a4...1b39',
          'verified': true,
        }
      ],
    },
    '2026-05-08': {
      'earnings': 2400.0,
      'hours': 6.0,
      'trips': [
        {
          'route': 'Surat → Jaipur',
          'customer': 'Karthik Murugan',
          'amount': '₹2,400',
          'status': 'Delivered',
          'hash': '0x7e1a3bc...2d9e',
          'verified': true,
        }
      ],
    },
    '2026-05-10': {
      'earnings': 1500.0,
      'hours': 4.5,
      'trips': [
        {
          'route': 'Vadodara → Ahmedabad',
          'customer': 'Krishna Exports',
          'amount': '₹1,500',
          'status': 'Delivered',
          'hash': '0x5b2b1e3...6ad1',
          'verified': true,
        }
      ],
    },
    '2026-05-11': {
      'earnings': 8400.0,
      'hours': 17.8,
      'trips': [
        {
          'route': 'Mumbai → Delhi',
          'customer': 'Raj Textiles',
          'amount': '₹8,400',
          'status': 'Delivered',
          'hash': '0x5b2b1e3...6ad1',
          'verified': true,
        }
      ],
    },
    '2026-05-13': {
      'earnings': 3100.0,
      'hours': 7.0,
      'trips': [
        {
          'route': 'Vadodara → Jaipur',
          'customer': 'Mehta Traders',
          'amount': '₹3,100',
          'status': 'Delivered',
          'hash': '0x3a574d5...8f2c',
          'verified': true,
        }
      ],
    },
    '2026-05-14': {
      'earnings': 5200.0,
      'hours': 9.5,
      'trips': [
        {
          'route': 'Surat → Jaipur',
          'customer': 'Karthik Murugan',
          'amount': '₹5,200',
          'status': 'Delivered',
          'hash': '0x3a574d5...8f2c',
          'verified': true,
        }
      ],
    },
    '2026-05-15': {
      'earnings': 4200.0,
      'hours': 9.0,
      'trips': [
        {
          'route': 'Ahmedabad → Pune',
          'customer': 'Sri Textiles',
          'amount': '₹2,400',
          'status': 'Delivered',
          'hash': '0x9cf11a4b5e...1b39',
          'verified': true,
        },
        {
          'route': 'Pune → Mumbai',
          'customer': 'Mehta Traders',
          'amount': '₹1,800',
          'status': 'Delivered',
          'hash': '0x1aa63bce90...c901',
          'verified': true,
        }
      ],
    },
    '2026-05-16': {
      'earnings': 2400.0,
      'hours': 5.5,
      'trips': [
        {
          'route': 'Surat → Ahmedabad',
          'customer': 'Karthik Murugan',
          'amount': '₹2,400',
          'status': 'Delivered',
          'hash': '0x7e1a3bc...2d9e',
          'verified': true,
        }
      ],
    },
    '2026-05-18': {
      'earnings': 2200.0,
      'hours': 5.2,
      'trips': [
        {
          'route': 'Vadodara → Jaipur',
          'customer': 'Mehta Traders',
          'amount': '₹2,200',
          'status': 'Delivered',
          'hash': '0x3a574d5...8f2c',
          'verified': true,
        }
      ],
    },
    '2026-05-19': {
      'earnings': 4500.0,
      'hours': 10.0,
      'trips': [
        {
          'route': 'Mumbai → Delhi',
          'customer': 'Raj Textiles',
          'amount': '₹2,500',
          'status': 'Delivered',
          'hash': '0x5b2b1e3...6ad1',
          'verified': true,
        },
        {
          'route': 'Delhi → Chandigarh',
          'customer': 'Mehta Traders',
          'amount': '₹2,000',
          'status': 'Delivered',
          'hash': '0x1aa63bce90...c901',
          'verified': true,
        }
      ],
    },
    '2026-05-20': {
      'earnings': 3800.0,
      'hours': 8.5,
      'trips': [
        {
          'route': 'Surat → Vadodara',
          'customer': 'Karthik Murugan',
          'amount': '₹3,800',
          'status': 'Delivered',
          'hash': '0x3a574d5c8f2c...31128',
          'verified': true,
        }
      ],
    },
    '2026-05-21': {
      'earnings': 1300.0,
      'hours': 4.0,
      'trips': [
        {
          'route': 'Surat → Mumbai',
          'customer': 'Raj Textiles',
          'amount': '₹1,300',
          'status': 'Delivered',
          'hash': '0x4f128bc...de98',
          'verified': true,
        }
      ],
    },
    '2026-05-22': {
      'earnings': 1200.0,
      'hours': 3.5,
      'trips': [
        {
          'route': 'Surat → Mumbai',
          'customer': 'Mehta Traders',
          'amount': '₹1,200',
          'status': 'Delivered',
          'hash': '0x8f2d5e1...bc90',
          'verified': true,
        }
      ],
    },
    '2026-05-23': {
      'earnings': 3400.0,
      'hours': 7.8,
      'trips': [
        {
          'route': 'Vadodara → Pune',
          'customer': 'Sri Textiles',
          'amount': '₹3,400',
          'status': 'Delivered',
          'hash': '0x9cf11a4b5e...1b39',
          'verified': true,
        }
      ],
    },
    '2026-05-25': {
      'earnings': 2100.0,
      'hours': 5.0,
      'trips': [
        {
          'route': 'Vadodara → Mumbai',
          'customer': 'Mehta Traders',
          'amount': '₹2,100',
          'status': 'Delivered',
          'hash': '0x2d9e1f4...5def',
          'verified': true,
        }
      ],
    },
    '2026-05-26': {
      'earnings': 4800.0,
      'hours': 8.2,
      'trips': [
        {
          'route': 'Ahmedabad → Pune',
          'customer': 'Sri Textiles',
          'amount': '₹4,800',
          'status': 'Delivered',
          'hash': '0x9cf11a4...1b39',
          'verified': true,
        }
      ],
    },
    '2026-05-27': {
      'earnings': 2400.0,
      'hours': 6.0,
      'trips': [
        {
          'route': 'Surat → Jaipur',
          'customer': 'Karthik Murugan',
          'amount': '₹2,400',
          'status': 'Delivered',
          'hash': '0x7e1a3bc...2d9e',
          'verified': true,
        }
      ],
    },
    '2026-05-28': {
      'earnings': 1500.0,
      'hours': 4.5,
      'trips': [
        {
          'route': 'Vadodara → Ahmedabad',
          'customer': 'Krishna Exports',
          'amount': '₹1,500',
          'status': 'Delivered',
          'hash': '0x5b2b1e3...6ad1',
          'verified': true,
        }
      ],
    },
    '2026-05-29': {
      'earnings': 8400.0,
      'hours': 17.8,
      'trips': [
        {
          'route': 'Mumbai → Delhi',
          'customer': 'Raj Textiles',
          'amount': '₹8,400',
          'status': 'Delivered',
          'hash': '0x5b2b1e3...6ad1',
          'verified': true,
        }
      ],
    },
    '2026-05-30': {
      'earnings': 3100.0,
      'hours': 7.0,
      'trips': [
        {
          'route': 'Vadodara → Jaipur',
          'customer': 'Mehta Traders',
          'amount': '₹3,100',
          'status': 'Delivered',
          'hash': '0x3a574d5...8f2c',
          'verified': true,
        }
      ],
    },
    // June 2026 daily data
    '2026-06-01': {
      'earnings': 4200.0,
      'hours': 9.0,
      'trips': [
        {
          'route': 'Ahmedabad → Pune',
          'customer': 'Sri Textiles',
          'amount': '₹4,200',
          'status': 'Delivered',
          'hash': '0x9cf11a4b5e...1b39',
          'verified': true,
        }
      ],
    },
    '2026-06-02': {
      'earnings': 2400.0,
      'hours': 5.5,
      'trips': [
        {
          'route': 'Surat → Ahmedabad',
          'customer': 'Karthik Murugan',
          'amount': '₹2,400',
          'status': 'Delivered',
          'hash': '0x7e1a3bc...2d9e',
          'verified': true,
        }
      ],
    },
    '2026-06-03': {
      'earnings': 2200.0,
      'hours': 5.2,
      'trips': [
        {
          'route': 'Vadodara → Jaipur',
          'customer': 'Mehta Traders',
          'amount': '₹2,200',
          'status': 'Delivered',
          'hash': '0x3a574d5...8f2c',
          'verified': true,
        }
      ],
    },
    '2026-06-04': {
      'earnings': 4500.0,
      'hours': 10.0,
      'trips': [
        {
.
          'route': 'Mumbai → Delhi',
          'customer': 'Raj Textiles',
          'amount': '₹4,500',
          'status': 'Delivered',
          'hash': '0x5b2b1e3...6ad1',
          'verified': true,
        }
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2026, 5, 14);
    _loadData();
  }

  Future<void> _loadData() async {
    // Simulate network request
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading ? _buildOverallSummaryShimmer() : _buildOverallSummaryCards(),
            const SizedBox(height: 24),
            _isLoading ? _buildHeatmapCalendarShimmer() : _buildHeatmapCalendarCard(),
            const SizedBox(height: 24),
            _isLoading ? _buildSelectedDateDetailsShimmer() : _buildSelectedDateDetailsCard(),
            const SizedBox(height: 24),
            _isLoading ? _buildPendingPaymentsShimmer() : _buildPendingPaymentsCard(),
          ],
        ),
      ),
    );
  }

  // Shimmer Widgets
  Widget _buildShimmerPlaceholder({double? width, double? height, BoxShape shape = BoxShape.rectangle}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final baseColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(8) : null,
        ),
      ),
    );
  }

  Widget _buildOverallSummaryShimmer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        return Expanded(
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerPlaceholder(width: 80, height: 14),
                  const SizedBox(height: 8),
                  _buildShimmerPlaceholder(width: 100, height: 24),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeatmapCalendarShimmer() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmerPlaceholder(width: 120, height: 20),
                _buildShimmerPlaceholder(width: 80, height: 20),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                return _buildShimmerPlaceholder(shape: BoxShape.circle);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateDetailsShimmer() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerPlaceholder(width: 150, height: 20),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerPlaceholder(width: 80, height: 14),
                    const SizedBox(height: 4),
                    _buildShimmerPlaceholder(width: 100, height: 24),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerPlaceholder(width: 80, height: 14),
                    const SizedBox(height: 4),
                    _buildShimmerPlaceholder(width: 60, height: 24),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildShimmerPlaceholder(height: 1, width: double.infinity),
            const SizedBox(height: 16),
            _buildShimmerPlaceholder(width: 120, height: 18),
            const SizedBox(height: 12),
            // Shimmer for a trip item
            Row(
              children: [
                _buildShimmerPlaceholder(width: 40, height: 40, shape: BoxShape.circle),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerPlaceholder(width: double.infinity, height: 16),
                      const SizedBox(height: 4),
                      _buildShimmerPlaceholder(width: 100, height: 14),
                    ],
                  ),
                ),
                _buildShimmerPlaceholder(width: 60, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPaymentsShimmer() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerPlaceholder(width: 180, height: 20),
            const SizedBox(height: 16),
            ...List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    _buildShimmerPlaceholder(width: 40, height: 40, shape: BoxShape.circle),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShimmerPlaceholder(width: double.infinity, height: 16),
                          const SizedBox(height: 4),
                          _buildShimmerPlaceholder(width: 120, height: 14),
                        ],
                      ),
                    ),
                    _buildShimmerPlaceholder(width: 70, height: 20),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Existing Widgets
  Widget _buildOverallSummaryCards() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? theme.colorScheme.surface.withOpacity(0.5) : theme.cardColor;

    return Row(
      children: [
        _buildSummaryCard('Today Earnings', '₹5,200', cardColor),
        const SizedBox(width: 12),
        _buildSummaryCard('This Week', '₹24,800', cardColor),
        const SizedBox(width: 12),
        _buildSummaryCard('This Month', '₹84,500', cardColor),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color cardColor) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.rubik(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeatmapCalendarCard() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? theme.colorScheme.surface.withOpacity(0.5) : theme.cardColor;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarHeader(),
            const SizedBox(height: 16),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'May 2026',
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                // TODO: Handle previous month
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                // TODO: Handle next month
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final theme = Theme.of(context);
    final daysInMonth = DateUtils.getDaysInMonth(_currentYear, _currentMonth);
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday;

    final List<Widget> dayWidgets = [];
    final List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // Add weekday labels
    for (var day in weekDays) {
      dayWidgets.add(
        Center(
          child: Text(
            day,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    // Add empty cells for days before the 1st of the month
    for (int i = 1; i < weekdayOfFirstDay; i++) {
      dayWidgets.add(Container());
    }

    // Add day cells
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_currentYear, _currentMonth, i);
      final dateString = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final data = _dailyData[dateString];
      final earnings = data?['earnings'] ?? 0.0;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: _buildDayCell(date, earnings),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(DateTime date, double earnings) {
    final theme = Theme.of(context);
    final isSelected = DateUtils.isSameDay(date, _selectedDate);
    final isToday = DateUtils.isSameDay(date, DateTime.now());

    Color cellColor = Colors.transparent;
    if (earnings > 0) {
      if (earnings > 5000) {
        cellColor = AppTheme.getHeatmapColor(5);
      } else if (earnings > 3000) {
        cellColor = AppTheme.getHeatmapColor(4);
      } else if (earnings > 2000) {
        cellColor = AppTheme.getHeatmapColor(3);
      } else if (earnings > 1000) {
        cellColor = AppTheme.getHeatmapColor(2);
      } else {
        cellColor = AppTheme.getHeatmapColor(1);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: theme.primaryColor, width: 2)
            : isToday
                ? Border.all(color: theme.hintColor, width: 1)
                : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: GoogleFonts.roboto(
            color: earnings > 2000 ? Colors.white : theme.textTheme.bodyLarge?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDateDetailsCard() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? theme.colorScheme.surface.withOpacity(0.5) : theme.cardColor;

    final dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
    final data = _dailyData[dateString];

    if (data == null) {
      return Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No activity on this day.',
            style: GoogleFonts.roboto(color: theme.textTheme.bodySmall?.color),
          ),
        ),
      );
    }

    final earnings = data['earnings'] as double;
    final hours = data['hours'] as double;
    final trips = data['trips'] as List<Map<String, dynamic>>;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details for ${_selectedDate.day} May 2026',
              style: GoogleFonts.rubik(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailItem('Daily Earnings', '₹${earnings.toStringAsFixed(2)}'),
                _buildDetailItem('Hours Driven', '${hours.toStringAsFixed(1)}h'),
                _buildDetailItem('Trips', '${trips.length}'),
              ],
            ),
            if (trips.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                'Trips on this day',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              ...trips.map((trip) => _buildTripItem(trip)).toList(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.rubik(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTripItem(Map<String, dynamic> trip) {
    final theme = Theme.of(context);
    final status = trip['status'] as String;
    final isCancelled = status == 'Cancelled';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            isCancelled ? Icons.cancel_outlined : Icons.check_circle_outline,
            color: isCancelled ? Colors.redAccent : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip['route'],
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'To: ${trip['customer']}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            trip['amount'],
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.w500,
              color: isCancelled ? Colors.redAccent : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingPaymentsCard() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? theme.colorScheme.surface.withOpacity(0.5) : theme.cardColor;

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Payments',
              style: GoogleFonts.rubik(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            ...pendingPayments.map((payment) => _buildPaymentItem(payment)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(Map<String, String> payment) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['customer']!,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  'Due on ${payment['dueDate']}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Text(
            payment['amount']!,
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}