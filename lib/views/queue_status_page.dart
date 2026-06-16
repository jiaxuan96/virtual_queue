import 'package:flutter/material.dart';
import 'restaurant_card_page.dart';
import '../viewmodels/queue_status_viewmodel.dart';
import '../models/queue_status_state.dart';

class QueueStatusPage extends StatefulWidget {
  final String? restaurantId;
  final int? myTicketNumber;
  final String? ticketId;

  const QueueStatusPage({
    super.key,
    this.restaurantId,
    this.myTicketNumber,
    this.ticketId,
  });

  @override
  State<QueueStatusPage> createState() => _QueueStatusPageState();
}

class _QueueStatusPageState extends State<QueueStatusPage> {
  final QueueStatusViewModel _viewModel = QueueStatusViewModel();

  bool _isSearchingTicket = false;
  String? _activeRestaurantId;
  int? _activeTicketNumber;
  String? _activeTicketId;

  bool _hasAlertedCalled = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // If explicit data was passed from joining a queue line, use it immediately
    if (widget.restaurantId != null && widget.myTicketNumber != null) {
      _activeRestaurantId = widget.restaurantId;
      _activeTicketNumber = widget.myTicketNumber;
      _activeTicketId = widget.ticketId;
    } else {
      // 🔍 Otherwise, trigger the direct Firestore rescue sequence
      _findExistingActiveTicket();
    }
  }

  @override
  void didUpdateWidget(covariant QueueStatusPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ PROTECTED OVERWRITE: Only accept new properties from the parent home view
    // if the parent is actually passing VALID new queue info. Reject incoming nulls!
    if (widget.restaurantId != null && widget.myTicketNumber != null) {
      if (widget.restaurantId != oldWidget.restaurantId || 
          widget.myTicketNumber != oldWidget.myTicketNumber) {
        setState(() {
          _activeRestaurantId = widget.restaurantId;
          _activeTicketNumber = widget.myTicketNumber;
          _activeTicketId = widget.ticketId;
          _hasAlertedCalled = false;
        });
      }
    }
  }

  Map<String, dynamic> getTicketPresentationStatus({
    required int userTicketNumber,
    required int branchCurrentServing,
    required String savedStatus,
  }) {
    // If database explicitly confirms it has completed processing or been updated
    if (savedStatus == 'SERVED' || branchCurrentServing > userTicketNumber) {
      return {
        'text': 'Served',
        'color': const Color(0xFF6E797B), // Neutral Slate Grey for finalized states
      };
    }

    // The exact moment the counter hits the user's turn
    if (branchCurrentServing == userTicketNumber) {
      return {
        'text': 'Called',
        'color': const Color(0xFFBA1A1A), // Alert Red to draw user attention
      };
    }

    // Default waiting line position tracking fallback standard
    return {
      'text': 'Waiting',
      'color': const Color(0xFF006670), // Theme Cyan
    };
  }

  // 🔔 THE CRITICAL LIVE TRIGGER FUNCTION
  void _checkAndTriggerCallAlert(int ticketNumber, int currentServing, String brandName) {
    // If the counter matches the user's turn and they haven't been notified yet
    if (currentServing == ticketNumber && !_hasAlertedCalled) {
      _hasAlertedCalled = true;

      // Safe Frame Execution: Wait until the layout engine completes painting before throwing dialogs
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Clear snackbars to avoid visual clutter
        ScaffoldMessenger.of(context).clearSnackBars();

        // Option A: Clean, Premium Material Sticky Banner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFBA1A1A), // High Alert Vibrant Crimson
            margin: const EdgeInsets.all(16),
            duration: const Duration(days: 1), // Persistent until user manually interacts
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Row(
              children: [
                const Icon(Icons.notification_important_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Turn Has Arrived!',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ticket #$ticketNumber is called at $brandName.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
        
                // 🎯 THE COMPILER-PROOF DISMISS BUTTON:
                // We style a normal text gesture right here inside the row, bypassing SnackBarAction completely!
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: const Text(
                      'DISMISS',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }
  }

  Future<void> _findExistingActiveTicket() async {
    if (_isSearchingTicket) return;
    
    setState(() => _isSearchingTicket = true);
    debugPrint('🚀 [Queue Status View] Initializing background verification check...');
    
    // Give the app authentication sequence 400 milliseconds to initialize state user keys completely
    await Future.delayed(const Duration(milliseconds: 400));
    
    var ticketData = await _viewModel.fetchActiveUserTicket();
    
    if (!mounted) return;
    
    setState(() {
      _isSearchingTicket = false;
      if (ticketData != null && ticketData['restaurantId'].toString().isNotEmpty) {
        _activeRestaurantId = ticketData['restaurantId'];
        _activeTicketNumber = ticketData['myTicketNumber'];
        _activeTicketId = ticketData['ticketId'];
        _hasAlertedCalled = false;
        debugPrint('✅ [Queue Status View] Engine connected successfully! Active Ticket: #$_activeTicketNumber');
      } else {
        debugPrint('❌ [Queue Status View] Resetting loop: No matching live ticket detected.');
      }
    });
  }

  // String get _derivedBrandId {
  //   final targetId = _activeRestaurantId ?? '';
  //   if (targetId.contains('_')) {
  //     final parts = targetId.split('_');
  //     if (parts.length >= 2) return '${parts[0]}_${parts[1]}';
  //   }
  //   return 'oriental_kopi'; 
  // }

  String get _derivedBrandId {
    final targetId = _activeRestaurantId ?? '';
    
    // If the restaurant id is exactly "khing_cafe_arena"
    if (targetId.startsWith('khing_cafe')) {
      return 'khing_cafe';
    }
    
    // Generic robust fallback splitter
    if (targetId.contains('_')) {
      final parts = targetId.split('_');
      if (parts.length >= 2) {
        return '${parts[0]}_${parts[1]}'; 
      }
    }
    return targetId; // 🧠 Dynamic safe fallback instead of hardcoded string overrides
  }

  String _formatWaitTime(int peopleAhead) {
    if (peopleAhead <= 0) return "Now Serving!";
    int totalMinutes = peopleAhead * 10;
    if (totalMinutes < 60) {
      return "$totalMinutes minutes";
    } else {
      int hours = totalMinutes ~/ 60; 
      int minutes = totalMinutes % 60; 
      String hourLabel = hours == 1 ? "hour" : "hours";
      return minutes == 0 ? "$hours $hourLabel" : "$hours $hourLabel $minutes mins";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearchingTicket) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6FAFB),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF006670)),
        ),
      );
    }

    if (_activeRestaurantId == null || _activeTicketNumber == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6FAFB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          elevation: 0,
          toolbarHeight: 72,
          automaticallyImplyLeading: false,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.menu_rounded, color: Color.fromARGB(0, 17, 94, 89), size: 24),
                  onPressed: () {},
                ),
                const Text(
                  'VQ',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF134E4A),
                    letterSpacing: -0.6,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E9EA),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x1A006670), width: 2),
                  ),
                  child: const Icon(Icons.person, color: Colors.grey),
                )
              ],
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No Active Queue Found',
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF171C1D)),
                ),
                const SizedBox(height: 8),
                Text(
                  "You aren't holding any active waiting tickets right now. Join a restaurant line to follow your spot live!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.grey[600], height: 1.4),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.menu_rounded, color: Color.fromARGB(0, 17, 94, 89), size: 24),
                onPressed: () {},
              ),
              const Text(
                'VQ',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF134E4A),
                  letterSpacing: -0.6,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E9EA),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x1A006670), width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.grey),
              )
            ],
          ),
        ),
      ),

      body: StreamBuilder<QueueStatusState?>( // 🚀 Ensure your stream type allows nullability checks
        stream: _viewModel.liveQueueTrackingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF006670)),
            );
          }

          // Handles scenarios where the user logs in but has no active queue records
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'No active queue ticket discovered.',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.grey[600]),
              ),
            );
          }

          final state = snapshot.data!;

          // 1. EXTRACT DATA DIRECTLY FROM STREAM PACKET (Avoids dependency on local class lifecycle variables)
          final String brandName = state.brandData['name'] ?? 'Loading Restaurant...';
          final String branchName = state.restaurantData['branch_name'] ?? '';
          final String addressText = state.restaurantData['address'] ?? 'No Address listed';
          
          final String streamRestaurantId = state.queueData['restaurant_id'] ?? '';
          final String streamBrandId = state.queueData['brand_id'] ?? '';
          final int streamTicketNumber = state.queueData['ticket_number'] ?? 0; // 🚀 Extracted directly from shortcut

          final int currentServing = state.queueData['current_serving'] ?? 0;
          final int peopleAhead = state.calculatePeopleAhead(streamTicketNumber);
          final double ringProgress = state.calculateProgressFactor(streamTicketNumber);

          _checkAndTriggerCallAlert(streamTicketNumber, currentServing, brandName);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIVE TRACKING',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF006670),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      branchName.isNotEmpty ? 'Your Spot at $brandName ($branchName)' : 'Your Spot at $brandName',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF171C1D),
                        height: 1.2,
                        letterSpacing: -0.9,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // TICKET CENTER CIRCULAR VISUAL METRIC CONTAINER
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x1ABD8C9CB)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D006670),
                        blurRadius: 50,
                        offset: Offset(0, 25),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -48,
                        top: -48,
                        width: 256,
                        height: 256,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF006670).withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 192,
                              height: 192,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: CircularProgressVectorPainter(
                                        progress: ringProgress,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'TICKET',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF48626E),
                                            letterSpacing: 1.4,
                                          ),
                                        ),
                                        Text(
                                          '#$streamTicketNumber', // 🚀 FIXED: Using stream value
                                          style: const TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 54,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF171C1D),
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 28),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailsBentoNode("NOW SERVING", "#$currentServing"),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDetailsBentoNode("QUEUE LENGTH", "$peopleAhead tables"),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            _buildDetailsBentoNode(
                              "ESTIMATED WAITING TIME", 
                              _formatWaitTime(peopleAhead),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // BOTTOM BRANCH GEOLOCATION PROFILE PANEL
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E9EA),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        height: 153,
                        color: const Color(0xFFE2E8F0),
                        width: double.infinity,
                        child: const Center(
                          child: Icon(Icons.map_outlined, size: 48, color: Colors.blueGrey),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(24),
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$brandName ($branchName)',
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF171C1D),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    addressText,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF48626E),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                debugPrint('🔍 [Navigation] Heading back to card page details for: $streamRestaurantId');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantCardPage(
                                      brandId: streamBrandId,       // 🚀 FIXED: Isolated completely from local initializers
                                      restaurantId: streamRestaurantId, 
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(99), 
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF006670),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward, 
                                  color: Colors.white, 
                                  size: 20,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      )
    );
  }

  Widget _buildDetailsBentoNode(String labelText, String mainValue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            labelText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF48626E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            mainValue,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF006670),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressVectorPainter extends CustomPainter {
  final double progress;
  CircularProgressVectorPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (size.width / 2) - 12;

    Paint baseTrackPaint = Paint()
      ..color = const Color(0xFFE5E9EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, baseTrackPaint);

    Paint activeArcPaint = Paint()
      ..color = const Color(0xFF006670)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    double sweepAngle = 2 * 3.1415926535 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2, 
      sweepAngle,
      false,
      activeArcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressVectorPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}