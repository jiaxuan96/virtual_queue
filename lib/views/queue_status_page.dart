// views/queue_status_page.dart
import 'package:flutter/material.dart';
import 'restaurant_card_page.dart';
import '../viewmodels/queue_status_viewmodel.dart';
import '../models/queue_status_state.dart';

class QueueStatusPage extends StatefulWidget {
  final String restaurantId;
  final int myTicketNumber;
  final String ticketId;

  const QueueStatusPage({
    super.key,
    required this.restaurantId,
    required this.myTicketNumber,
    required this.ticketId,
  });

  @override
  State<QueueStatusPage> createState() => _QueueStatusPageState();
}

class _QueueStatusPageState extends State<QueueStatusPage> {
  final QueueStatusViewModel _viewModel = QueueStatusViewModel();

  // Temporary helper value parser to split out brandId root strings
  String get _derivedBrandId {
    if (widget.restaurantId.contains('_')) {
      final parts = widget.restaurantId.split('_');
      if (parts.length >= 2) return '${parts[0]}_${parts[1]}';
    }
    return 'oriental_kopi'; // Safe system fallback
  }

  String _formatWaitTime(int peopleAhead) {
    if (peopleAhead <= 0) return "Now Serving!";
    
    int totalMinutes = peopleAhead * 10;
    
    if (totalMinutes < 60) {
      return "$totalMinutes minutes";
    } else {
      int hours = totalMinutes ~/ 60; // Integer division to get total hours
      int minutes = totalMinutes % 60; // Modulo to get remaining minutes
      
      String hourLabel = hours == 1 ? "hour" : "hours";
      
      if (minutes == 0) {
        return "$hours $hourLabel";
      } else {
        return "$hours $hourLabel $minutes mins";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFB),
      
      // 📌 TOP BAR LAYER - Cloned precisely from CustomerHomeView specifications
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
                icon: const Icon(Icons.menu_rounded, color: Color(0xFF115E59), size: 24),
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

      body: StreamBuilder<QueueStatusState>(
        stream: _viewModel.getLiveTrackingStream(
          brandId: _derivedBrandId,
          restaurantId: widget.restaurantId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF006670)),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Failed to establish live sequence syncing.',
                style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Colors.grey[600]),
              ),
            );
          }

          final state = snapshot.data!;
          
          // Unpack clean field definitions parsed directly out of MVVM layers
          final String brandName = state.brandData['name'] ?? 'Oriental Kopi';
          final String branchName = state.restaurantData['branch_name'] ?? '';
          final String addressText = state.restaurantData['address'] ?? 'No Address Listed';
          
          final int currentServing = state.queueData['current_serving'] ?? 0;
          int peopleAhead = widget.myTicketNumber - currentServing;
          if (peopleAhead < 0) peopleAhead = 0;

          final double ringProgress = state.calculateProgressFactor(widget.myTicketNumber);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // EDITORIAL HEADER SECTION - Now dynamically updates with the real branch name
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

                // CENTRAL QUEUE STATUS BENTO CARD
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
                            // Circular Progress Indicator Ring
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
                                          '#${widget.myTicketNumber}',
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

                // RESTAURANT INFO & DIRECTIONS DETAIL STRIP
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
                            // Container(
                            //   width: 48,
                            //   height: 48,
                            //   decoration: const BoxDecoration(
                            //     color: Color(0xFF006670),
                            //     shape: BoxShape.circle,
                            //   ),
                            //   child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            // )
                            InkWell(
                              onTap: () {
                                debugPrint('🔍 [Navigation] Heading back to card page details for: ${widget.restaurantId}');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantCardPage(
                                      brandId: _derivedBrandId,       // Pass your parsed brand ID string here
                                      restaurantId: widget.restaurantId, // Pass your active restaurant ID string here
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(99), // Keeps the touch splash perfectly round
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
                
                // Safe padding buffer area for modern screens
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
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