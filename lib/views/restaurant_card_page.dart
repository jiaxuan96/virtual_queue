import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/queue_service.dart';
import 'queue_status_page.dart';

class RestaurantCardPage extends StatefulWidget {
  const RestaurantCardPage({super.key});

  @override
  State<RestaurantCardPage> createState() => _RestaurantCardPageState();
}

class _RestaurantCardPageState extends State<RestaurantCardPage> {
  final QueueService _queueService = QueueService();
  bool _isLoading = false;

  final String _restaurantId = "oriental_kopi"; // This should match the document ID in Firestore for this restaurant
  final String _userId = "test_customer_123";

  // void _handleJoinQueue() async {
  //   setState(() => _isLoading = true);
    
  //   int? assignedNumber = await _queueService.joinQueue(_restaurantId, _userId);
    
  //   setState(() => _isLoading = false);

  //   if (assignedNumber != null && mounted) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => QueueStatusPage(
  //           restaurantId: _restaurantId,
  //           myTicketNumber: assignedNumber, 
  //           ticketId: '', 
  //         ),
  //       ),
  //     );
  //   } else if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to join queue. Try again.')),
  //     );
  //   }
  // }

  void _handleJoinQueue() async {
    if (_isLoading) return; 

    setState(() => _isLoading = true);
    debugPrint('🚀 [Queue System] Attempting to join line for restaurant: $_restaurantId...');
    
    try {
      int? assignedNumber = await _queueService.joinQueue(_restaurantId, _userId);
      
      debugPrint('📥 [Queue System] Service responded. Assigned Number: $assignedNumber');

      setState(() => _isLoading = false);

      if (assignedNumber != null && mounted) {
        debugPrint('🎯 [Queue System] Success! Navigating to QueueStatusPage...');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QueueStatusPage(
              restaurantId: _restaurantId,
              myTicketNumber: assignedNumber,
              ticketId: '', 
            ),
          ),
        );
      } else {
        debugPrint('⚠️ [Queue System] Service returned null. Check if restaurant document exists.');
        if (mounted) {
          _showErrorDialog('Queue is currently closed or the restaurant configuration was not found.');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('❌ [Queue System] CRITICAL ERROR encountered: $e');
      if (mounted) {
        _showErrorDialog('Database connection error: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Queue Failure'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFB), // Matching overall page background
      body: SingleChildScrollView(
        child: Center(
          // child: Container(
          //   width: 440,
          //   height: 1275,
          //   clipBehavior: Clip.antiAlias,
          //   decoration: const BoxDecoration(
          //     color: Color(0xFFF6FAFB),
          //   ),
          //   child: Stack(
          //     children: [
                
          //       // 1. HERO IMAGE SECTION
          //       Positioned(
          //         top: 0,
          //         left: 0,
          //         right: 0,
          //         height: 431,
          //         child: Container(
          //           decoration: const BoxDecoration(
          //             image: DecorationImage(
          //               image: AssetImage('assets/images/Oriental_Kopi.png'), 
          //               fit: BoxFit.cover,
          //             ),
          //           ),
          //           // Gradient overlay matching style matrix specs exactly
          //           child: Container(
          //             decoration: const BoxDecoration(
          //               gradient: LinearGradient(
          //                 begin: Alignment.bottomCenter,
          //                 end: Alignment.topCenter,
          //                 colors: [
          //                   Color(0xFFF6FAFB), // 0% opacity location mapping
          //                   Color(0x00F6FAFB), // 50% clear interpolation anchor
          //                   Color(0x33000000), // 100% surface dark structural layer
          //                 ],
          //                 stops: [0.0, 0.5, 1.0],
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),

          //       // 2. HEADER TOP APP BAR BUTTONS
          //       Positioned(
          //         top: MediaQuery.of(context).padding.top + 6, // 👈 Tweak this multiplier to fine-tune layout balance
          //         left: 16,
          //         right: 16,
          //         child: SizedBox(
          //           height: 48, // 👈 Lock a structural block height to vertically center the 40px buttons
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             crossAxisAlignment: CrossAxisAlignment.center, // Forces child buttons to center inside the 48px track
          //             children: [
          //               _buildBlurCircleButton(Icons.arrow_back),
          //               _buildBlurCircleButton(Icons.bookmark_border),
          //             ],
          //           ),
          //         ),
          //       ),

          //       // 3. MAIN CONTENT CANVAS FRAME
          //       Positioned(
          //         top: 349,
          //         left: 18,
          //         right: 18,
          //         // width: 392,
          //         // height: 882,
          //         child: Container(
          //           decoration: BoxDecoration(
          //             color: Colors.white,
          //             borderRadius: BorderRadius.circular(24),
          //             boxShadow: const [
          //               BoxShadow(
          //                 color: Color(0x0D171C1D), // Matches rgba(23, 28, 29, 0.05)
          //                 blurRadius: 50,
          //                 offset: Offset(0, 25),
          //               )
          //             ],
          //           ),
          //           child: Padding(
          //             padding: const EdgeInsets.all(32.0),
          //             child: Column(
          //               mainAxisSize: MainAxisSize.min,
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
                          
          //                 // RESTAURANT HEADER INFO BLOCK
          //                 Row(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                   children: [
          //                     Expanded(
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           const Text(
          //                             'Oriental Kopi',
          //                             style: TextStyle(
          //                               fontFamily: 'Plus Jakarta Sans',
          //                               fontSize: 36,
          //                               fontWeight: FontWeight.w800, // 800 Ultra Bold
          //                               color: Color(0xFF171C1D),
          //                               height: 40 / 36,
          //                               letterSpacing: -0.9,
          //                             ),
          //                           ),
          //                           const SizedBox(height: 8),
          //                           _buildMetaRow(Icons.restaurant_menu, 'Nanyang Cuisine'),
          //                         ],
          //                       ),
          //                     ),
          //                     // Short Wait Badge Status
          //                     Container(
          //                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          //                       decoration: BoxDecoration(
          //                         color: const Color(0xFFF39850),
          //                         borderRadius: BorderRadius.circular(9999),
          //                       ),
          //                       child: const Text(
          //                         'Short wait',
          //                         style: TextStyle(
          //                           fontFamily: 'Plus Jakarta Sans',
          //                           fontSize: 14,
          //                           fontWeight: FontWeight.w700,
          //                           color: Color(0xFFF6FFF4),
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
                          
          //                 const SizedBox(height: 16),
          //                 _buildMetaRow(Icons.access_time, 'Mon - Fri 9AM - 9PM'),
          //                 const SizedBox(height: 12),
          //                 _buildMetaRow(Icons.location_on_outlined, '128 Queensbay Mall, Pulau Pinang'),
          //                 const SizedBox(height: 12),
          //                 _buildMetaRow(Icons.phone_in_talk_outlined, '+04-10263288'),
                          
          //                 const SizedBox(height: 24),

          //                 // REAL-TIME STATUS BENTO GRID NODES
          //                 Row(
          //                   children: [
          //                     // Node A: Current Serving Counter
          //                     Expanded(
          //                       child: Container(
          //                         height: 160,
          //                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
          //                         decoration: BoxDecoration(
          //                           color: const Color(0xFFF0F4F5),
          //                           borderRadius: BorderRadius.circular(16),
          //                           border: const Border(
          //                             left: BorderSide(color: Color(0xFF006670), width: 4),
          //                           ),
          //                         ),
          //                         child: Column(
          //                           crossAxisAlignment: CrossAxisAlignment.start,
          //                           mainAxisAlignment: MainAxisAlignment.center,
          //                           children: [
          //                             StreamBuilder<DocumentSnapshot>(
          //                                 stream: FirebaseFirestore.instance.collection('queues').doc(_restaurantId).snapshots(),                                        builder: (context, snapshot) {
          //                                 int current = 0; // Baseline fallback value matching mockup target
          //                                 if (snapshot.hasData && snapshot.data!.exists) {
          //                                   var d = snapshot.data!.data() as Map<String, dynamic>;
          //                                   current = d['current_serving'] ?? 0;
          //                                 }
          //                                 return Column(
          //                                   crossAxisAlignment: CrossAxisAlignment.start,
          //                                   children: [
          //                                     const Text(
          //                                       'CURRENT SERVING',
          //                                       style: TextStyle(
          //                                         fontFamily: 'Plus Jakarta Sans',
          //                                         fontSize: 12,
          //                                         fontWeight: FontWeight.w700,
          //                                         letterSpacing: 1.2,
          //                                         color: Color(0xFF006670),
          //                                       ),
          //                                     ),
          //                                     const SizedBox(height: 4),
          //                                     Text(
          //                                       '#$current',
          //                                       style: const TextStyle(
          //                                         fontFamily: 'Plus Jakarta Sans',
          //                                         fontSize: 40,
          //                                         fontWeight: FontWeight.w800,
          //                                         color: Color(0xFF171C1D),
          //                                         height: 1.0,
          //                                         leadingDistribution: TextLeadingDistribution.even,
          //                                       ),
          //                                     ),
          //                                   ],
          //                                 );
          //                               }
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                     const SizedBox(width: 12),
          //                     // Node B: Active Line Tracking Data
          //                     Expanded(
          //                       child: Container(
          //                         height: 160,
          //                         padding: const EdgeInsets.all(24),
          //                         decoration: BoxDecoration(
          //                           color: const Color(0xFFF0F4F5),
          //                           borderRadius: BorderRadius.circular(16),
          //                           border: const Border(
          //                             left: BorderSide(color: Color(0xFF006A35), width: 4),
          //                           ),
          //                         ),
          //                         child: Column(
          //                           crossAxisAlignment: CrossAxisAlignment.start,
          //                           mainAxisAlignment: MainAxisAlignment.center,
          //                           children: [
          //                             const Text(
          //                               'QUEUE LENGTH',
          //                               style: TextStyle(
          //                                 fontFamily: 'Plus Jakarta Sans',
          //                                 fontSize: 12,
          //                                 fontWeight: FontWeight.w700,
          //                                 letterSpacing: 1.2,
          //                                 color: Color(0xFF006A35),
          //                               ),
          //                             ),
          //                             const SizedBox(height: 4),
                                      
          //                             StreamBuilder<DocumentSnapshot>(
          //                               stream: FirebaseFirestore.instance.collection('queues').doc(_restaurantId).snapshots(),
          //                               builder: (context, snapshot) {
          //                                 int peopleAhead = 0;
          //                                 int queueLength = 0; // Baseline fallback value matching mockup target
                                          
          //                                 if (snapshot.hasData && snapshot.data!.exists) {
          //                                   var d = snapshot.data!.data() as Map<String, dynamic>;
                                            
          //                                   // 👈 FIXED: Removed the duplicate 'int' keyword here to update the outer variable correctly
          //                                   peopleAhead = (d['next_available_number'] ?? 1) - (d['current_serving'] ?? 0) - 1;
                                            
          //                                   queueLength = peopleAhead > 0 ? peopleAhead : 0; // Ensure non-negative queue length
          //                                 }

          //                                 return Row(
          //                                   crossAxisAlignment: CrossAxisAlignment.baseline,
          //                                   textBaseline: TextBaseline.alphabetic,
          //                                   children: [
          //                                     Text(
          //                                       '$queueLength', 
          //                                       style: const TextStyle(
          //                                         fontFamily: 'Plus Jakarta Sans',
          //                                         fontSize: 40,
          //                                         fontWeight: FontWeight.w800,
          //                                         color: Color(0xFF171C1D),
          //                                       ),
          //                                     ),
          //                                     const SizedBox(width: 4),
          //                                     const Text(
          //                                       'tables',
          //                                       style: TextStyle(
          //                                         fontFamily: 'Plus Jakarta Sans',
          //                                         fontSize: 16,
          //                                         fontWeight: FontWeight.w500,
          //                                         color: Color(0xFF6E797B),
          //                                       ),
          //                                     ),
          //                                   ],
          //                                 );
          //                               },
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),

          //                 const SizedBox(height: 24),

          //                 // STICKY CORE FOOTER ACTION CALLS
          //                 SizedBox(
          //                   width: 328,
          //                   height: 68,
          //                   child: ElevatedButton.icon(
          //                     style: ElevatedButton.styleFrom(
          //                       backgroundColor: const Color(0xFF006670), // Primary Teal Accent
          //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          //                       elevation: 0,
          //                     ),
          //                     onPressed: _isLoading ? null : _handleJoinQueue,
          //                     icon: _isLoading 
          //                       ? const SizedBox.shrink()
          //                       : const Icon(Icons.confirmation_num_outlined, color: Colors.white, size: 20),
          //                     label: _isLoading 
          //                       ? const CircularProgressIndicator(color: Colors.white)
          //                       : const Text(
          //                           'Join Queue Line',
          //                           style: TextStyle(
          //                             fontFamily: 'Plus Jakarta Sans',
          //                             fontSize: 18,
          //                             fontWeight: FontWeight.w700,
          //                             color: Colors.white,
          //                           ),
          //                         ),
          //                   ),
          //                 ),
                          
          //                 const SizedBox(height: 16),
                          
          //                 // Secondary Option Action Call (Reservation Interface Placeholder)
          //                 Container(
          //                   width: 328,
          //                   height: 68,
          //                   decoration: BoxDecoration(
          //                     color: const Color(0xFFCBE7F5),
          //                     borderRadius: BorderRadius.circular(16),
          //                   ),
          //                   child: InkWell(
          //                     onTap: () {
          //                       // Will interact with Member 2's system module components
          //                     },
          //                     borderRadius: BorderRadius.circular(16),
          //                     child: const Row(
          //                       mainAxisAlignment: MainAxisAlignment.center,
          //                       children: [
          //                         Icon(Icons.calendar_today_outlined, color: Color(0xFF4E6874), size: 20),
          //                         SizedBox(width: 12),
          //                         Text(
          //                           'Book Table',
          //                           style: TextStyle(
          //                             fontFamily: 'Plus Jakarta Sans',
          //                             fontSize: 18,
          //                             fontWeight: FontWeight.w700,
          //                             color: Color(0xFF4E6874),
          //                           ),
          //                         ),
          //                       ],
          //                     ),
          //                   ),
          //                 ),

          //                 const SizedBox(height: 24),

          //                 // ABOUT RESTAURANT DESCRIPTION FOOTNOTE
          //                 const Text(
          //                   'About',
          //                   style: TextStyle(
          //                     fontFamily: 'Plus Jakarta Sans',
          //                     fontSize: 20,
          //                     fontWeight: FontWeight.w700,
          //                     color: Color(0xFF171C1D),
          //                   ),
          //                 ),
          //                 const SizedBox(height: 16),
          //                 const Text(
          //                   "A rapidly growing Malaysian kopitiam chain founded in 2020 by Dato' Chan Jian Chern, specializing in authentic Nanyang cuisine, high-quality coffee, and award-winning egg tarts.",
          //                   style: TextStyle(
          //                     fontFamily: 'Plus Jakarta Sans',
          //                     fontSize: 16,
          //                     fontWeight: FontWeight.w400,
          //                     color: Color(0xFF3E494B),
          //                     height: 26 / 16,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          child: Container(
            width: 440,
            // 💡 REMOVED: height: 1275, -> Height now wraps content organically
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Color(0xFFF6FAFB),
            ),
            child: Column( // 👈 CHANGED: Swapped root Stack for a Column so components stack and calculate height naturally
              mainAxisSize: MainAxisSize.min, // 👈 CRITICAL: Tells the container to shrink-wrap its children
              children: [
                
                // 1. HERO IMAGE SECTION WITH APP BAR OVERLAYS
                SizedBox(
                  height: 431,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/Oriental_Kopi.png'), 
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color(0xFFF6FAFB), 
                                  Color(0x00F6FAFB), 
                                  Color(0x33000000), 
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // 2. HEADER TOP APP BAR BUTTONS (Still floating perfectly on image)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 6,
                        left: 16,
                        right: 16,
                        child: SizedBox(
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildBlurCircleButton(Icons.arrow_back),
                              _buildBlurCircleButton(Icons.bookmark_border),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. MAIN CONTENT CANVAS FRAME (Calculates height flawlessly)
                Transform.translate(
                  offset: const Offset(0, -82), // 👈 Pulls the card back up over the cover image to match your 'top: 349' spacing (431 - 82 = 349)
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D171C1D), 
                            blurRadius: 50,
                            offset: Offset(0, 25),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Hug content
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            // RESTAURANT HEADER INFO BLOCK
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Oriental Kopi',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 36,
                                          fontWeight: FontWeight.w800, 
                                          color: Color(0xFF171C1D),
                                          height: 40 / 36,
                                          letterSpacing: -0.9,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildMetaRow(Icons.restaurant_menu, 'Nanyang Cuisine'),
                                    ],
                                  ),
                                ),
                                // Container(
                                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                //   decoration: BoxDecoration(
                                //     color: const Color(0xFFF39850),
                                //     borderRadius: BorderRadius.circular(9999),
                                //   ),
                                //   child: const Text(
                                //     'Short wait',
                                //     style: TextStyle(
                                //       fontFamily: 'Plus Jakarta Sans',
                                //       fontSize: 14,
                                //       fontWeight: FontWeight.w700,
                                //       color: Color(0xFFF6FFF4),
                                //     ),
                                //   ),
                                // ),
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance.collection('queues').doc(_restaurantId).snapshots(),
                                  builder: (context, snapshot) {
                                    // 1. Default fallback values while loading or if data is missing
                                    String badgeText = 'No waiting';
                                    Color badgeBgColor = const Color(0xFF008645); // Soft Green
                                    Color badgeTextColor = const Color(0xFFFFFFFF); // Sharp Green

                                    if (snapshot.hasData && snapshot.data!.exists) {
                                      var d = snapshot.data!.data() as Map<String, dynamic>;
                                      
                                      // Calculate queue length using your established math formula
                                      int peopleAhead = (d['next_available_number'] ?? 1) - (d['current_serving'] ?? 0) - 1;
                                      int queueLength = peopleAhead > 0 ? peopleAhead : 0;

                                      // 🧠 2. STATUS CONDITIONAL MATRIX WEIGHTS
                                      if (queueLength == 0) {
                                        badgeText = 'No waiting';
                                        badgeBgColor = const Color(0xFF008645);// Clear Emerald
                                        badgeTextColor = const Color(0xFFFFFFFF); 
                                      } else if (queueLength >= 1 && queueLength <= 5) {
                                        badgeText = 'Short wait';
                                        badgeBgColor = const Color(0xFFF39850); // Soft Peach/Orange
                                        badgeTextColor = const Color(0xFFFFFFFF); 
                                      } else if (queueLength >= 6 && queueLength <= 10) {
                                        badgeText = 'Moderate';
                                        badgeBgColor = const Color(0xFFFF7890); // Soft Amber/Yellow
                                        badgeTextColor = const Color(0xFFFFFFFF); 
                                      } else {
                                        badgeText = 'Busy';
                                        badgeBgColor = const Color(0xFFBA1A1A); // Soft Coral/Red
                                        badgeTextColor = const Color(0xFFFFFFFF); 
                                      }
                                    }

                                    // 3. The Dynamically Rendered Container Badge
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300), // Smoothly cross-fades colors when status updates live
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: badgeBgColor,
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      child: Text(
                                        badgeText,
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800, // 800 Ultra-Bold matching your Figma design system token
                                          color: badgeTextColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            _buildMetaRow(Icons.access_time, 'Mon - Fri 9AM - 9PM'),
                            const SizedBox(height: 12),
                            _buildMetaRow(Icons.location_on_outlined, '128 Queensbay Mall, Pulau Pinang'),
                            const SizedBox(height: 12),
                            _buildMetaRow(Icons.phone_in_talk_outlined, '+04-10263288'),
                            
                            const SizedBox(height: 24),

                            // REAL-TIME STATUS BENTO GRID NODES
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 160,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F4F5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: const Border(
                                        left: BorderSide(color: Color(0xFF006670), width: 4),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance.collection('queues').doc(_restaurantId).snapshots(),                                        
                                          builder: (context, snapshot) {
                                            int current = 0; 
                                            if (snapshot.hasData && snapshot.data!.exists) {
                                              var d = snapshot.data!.data() as Map<String, dynamic>;
                                              current = d['current_serving'] ?? 0;
                                            }
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'CURRENT SERVING',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1.2,
                                                    color: Color(0xFF006670),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '#$current',
                                                  style: const TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 40,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF171C1D),
                                                    height: 1.0,
                                                    leadingDistribution: TextLeadingDistribution.even,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 160,
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F4F5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: const Border(
                                        left: BorderSide(color: Color(0xFF006A35), width: 4),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'QUEUE LENGTH',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.2,
                                            color: Color(0xFF006A35),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance.collection('queues').doc(_restaurantId).snapshots(),
                                          builder: (context, snapshot) {
                                            int peopleAhead = 0;
                                            int queueLength = 0; 
                                            
                                            if (snapshot.hasData && snapshot.data!.exists) {
                                              var d = snapshot.data!.data() as Map<String, dynamic>;
                                              peopleAhead = (d['next_available_number'] ?? 1) - (d['current_serving'] ?? 0) - 1;
                                              queueLength = peopleAhead > 0 ? peopleAhead : 0; 
                                            }

                                            return Row(
                                              crossAxisAlignment: CrossAxisAlignment.baseline,
                                              textBaseline: TextBaseline.alphabetic,
                                              children: [
                                                Text(
                                                  '$queueLength', 
                                                  style: const TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 40,
                                                    fontWeight: FontWeight.w800,
                                                    color: Color(0xFF171C1D),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'tables',
                                                  style: TextStyle(
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF6E797B),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // STICKY CORE FOOTER ACTION CALLS
                            SizedBox(
                              width: double.infinity, // 👈 CHANGED: Match parent card width adaptively
                              height: 68,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006670), 
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: _isLoading ? null : _handleJoinQueue,
                                icon: _isLoading 
                                  ? const SizedBox.shrink()
                                  : const Icon(Icons.confirmation_num_outlined, color: Colors.white, size: 20),
                                label: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Join Queue Line',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            Container(
                              width: double.infinity, // 👈 CHANGED: Match parent card width adaptively
                              height: 68,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBE7F5),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(16),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calendar_today_outlined, color: Color(0xFF4E6874), size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      'Book Table',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF4E6874),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ABOUT RESTAURANT DESCRIPTION FOOTNOTE
                            const Text(
                              'About',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF171C1D),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "A rapidly growing Malaysian kopitiam chain founded in 2020 by Dato' Chan Jian Chern, specializing in authentic Nanyang cuisine, high-quality coffee, and award-winning egg tarts.",
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF3E494B),
                                height: 26 / 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // 4. BALANCING EMPTY SPACE REMOVAL
                const SizedBox(height: 12), // Subtle padding at the very bottom of your scroll canvas
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlurCircleButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6E797B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6E797B),
            ),
          ),
        ),
      ],
    );
  }
}