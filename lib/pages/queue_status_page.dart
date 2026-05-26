// import 'package:flutter/material.dart';

// class QueueStatusPage extends StatelessWidget {
//   const QueueStatusPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Queue Status'),
//         backgroundColor: Colors.green,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Your Position in Line',
//                 style: TextStyle(fontSize: 20, color: Colors.grey),
//               ),
//               const SizedBox(height: 10),
//               // Big bold number for the user's ticket
//               const Text(
//                 '#108',
//                 style: TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.blueAccent),
//               ),
//               const SizedBox(height: 30),
//               const Divider(),
//               const SizedBox(height: 30),
//               const Text(
//                 'Now Serving:',
//                 style: TextStyle(fontSize: 18),
//               ),
//               const Text(
//                 '#105',
//                 style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Estimated wait: 2 groups ahead of you',
//                 style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QueueStatusPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFB),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            // Forces strict conformance to the canvas bounds specification
            width: 440,
            height: 1075,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Color(0xFFF6FAFB),
            ),
            child: Stack(
              children: [
                
                // 1. TOP APP BAR HEADER
                Positioned(
                  top: MediaQuery.of(context).padding.top + 6,
                  left: 0,
                  right: 0,
                  height: 72,
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Color(0xFF115E59), size: 18),
                          onPressed: () => Navigator.pop(context),
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

                // 2. EDITORIAL HEADER SECTION
                Positioned(
                  top: 116,
                  left: 24,
                  right: 24,
                  height: 111.5,
                  child: Column(
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
                      const SizedBox(height: 4.5),
                      const Text(
                        'Your Spot at Oriental Kopi',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF171C1D),
                          height: 45 / 36,
                          letterSpacing: -0.9,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                      ),
                    ],
                  ),
                ),

                // REAL-TIME FIRESTORE STREAM PIPELINE
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('queues').doc(restaurantId).snapshots(),
                  builder: (context, snapshot) {
                    int currentServing = 0; // Default mockup layout fallback
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      currentServing = data['current_serving'] ?? 0;
                    }

                    int peopleAhead = myTicketNumber - currentServing;
                    if (peopleAhead < 0) peopleAhead = 0;

                    // Calculate progress factor for the vector circle arc logic
                    double progressPercentage = peopleAhead > 0 ? (1.0 / (peopleAhead + 1)) : 1.0;

                    return Stack(
                      children: [
                        
                        // 3. CENTRAL QUEUE STATUS BENTO CARD
                        Positioned(
                          top: 239,
                          left: 24,
                          right: 26,
                          height: 451,
                          child: Container(
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
                                // Background Soft Accent Blur Circle
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
                                // Main Interior Canvas Content
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      // Vector Circle Progress Ring Stack
                                      SizedBox(
                                        width: 192,
                                        height: 192,
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: CustomPaint(
                                                painter: CircularProgressVectorPainter(
                                                  progress: progressPercentage,
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
                                                    '#$myTicketNumber',
                                                    style: const TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 54, // Adjusted down slightly from 60 to prevent double digits clipping line boundaries
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
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Queue Details Rows Layout Block
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildDetailsBentoNode("NOW SERVING", "#$currentServing"),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _buildDetailsBentoNode("QUEUE LENGTH", "$peopleAhead tables"),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 12),
                                      _buildDetailsBentoNode(
                                        "ESTIMATED WAITING TIME", 
                                        peopleAhead > 0 ? "${peopleAhead * 10} minutes" : "Now Serving!"
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        // 4. RESTAURANT INFO & DIRECTIONS CARD (MAP CANVAS)
                        Positioned(
                          top: 727,
                          left: 24,
                          right: 26,
                          height: 249,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E9EA),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                // Upper Static Map Placeholder Canvas Panel
                                Container(
                                  height: 153,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(24),
                                      topRight: Radius.circular(24),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.map_outlined, size: 48, color: Colors.blueGrey.withOpacity(0.4)),
                                  ),
                                ),
                                // Lower Text Navigation Detail Strip
                                Container(
                                  height: 96,
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Oriental Kopi',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF171C1D),
                                            ),
                                          ),
                                          Text(
                                            '128 Queensbay Mall, Pulau Pinang',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF48626E),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF006670),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // 5. FROSTED BLUR BOTTOM NAVIGATION BAR
                Positioned(
                  left: 24,
                  bottom: 0,
                  width: 390,
                  height: 88,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xF8F8FAFC).withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D134E4A),
                          blurRadius: 50,
                          offset: Offset(0, 25),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavButton(Icons.storefront, "Home", false),
                        _buildNavButton(Icons.confirmation_num, "Queue", true),
                        _buildNavButton(Icons.history, "History", false),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper template for uniform Bento Node structure components
  Widget _buildDetailsBentoNode(String labelText, String mainValue) {
    return Container(
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
          const SizedBox(height: 4),
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

  // Builder for matching bottom navigator button tabs
  Widget _buildNavButton(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: isActive 
          ? BoxDecoration(color: const Color(0xFFF0FDFA), borderRadius: BorderRadius.circular(16))
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF115E59) : const Color(0xFF64748B), size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF115E59) : const Color(0xFF64748B),
            ),
          )
        ],
      ),
    );
  }
}

// Custom vector painter matching the native Figma border transforms exactly
class CircularProgressVectorPainter extends CustomPainter {
  final double progress;
  CircularProgressVectorPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (size.width / 2) - 12;

    // 1. Structural base layout track curve circle vector (#E5E9EA)
    Paint baseTrackPaint = Paint()
      ..color = const Color(0xFFE5E9EA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, baseTrackPaint);

    // 2. Active index foreground dynamic mask outline track curve vector (#006670)
    Paint activeArcPaint = Paint()
      ..color = const Color(0xFF006670)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Mathematical rotation to initiate tracing from absolute true north position (-90 degrees)
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