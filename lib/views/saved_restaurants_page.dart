import 'package:flutter/material.dart';
import '../viewmodels/saved_restaurants_viewmodel.dart';
import '../models/restaurant_display_state.dart';
import '../models/restaurant_brand_model.dart';
import 'restaurant_card_page.dart';

class SavedRestaurantsPage extends StatefulWidget {

  const SavedRestaurantsPage({
    super.key
  });

  @override
  State<SavedRestaurantsPage> createState() => _SavedRestaurantsPageState();
}

class _SavedRestaurantsPageState extends State<SavedRestaurantsPage> {
  final SavedRestaurantsViewModel _viewModel = SavedRestaurantsViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF115E59), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Restaurants',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            color: Color(0xFF171C1D),
            fontSize: 20,
          ),
        ),
      ),
      body: StreamBuilder<List<RestaurantDisplayState>>(
        stream: _viewModel.savedRestaurantsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF006670)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          final bookmarkedList = snapshot.data ?? [];

          // 🚨 IF BOOKMARKS COLLECTION CONTAINER IS EMPTY, RENDER EMPTY STATE
          if (bookmarkedList.isEmpty) {
            return _buildEmptyState();
          }

          // 📋 CARD GRID GRID VIEW FEED LIST BUILDER
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            itemCount: bookmarkedList.length,
            itemBuilder: (context, index) {
              return _buildRestaurantCard(context, bookmarkedList[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF115E59).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bookmark_outline_rounded, size: 36, color: Color(0xFF115E59)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Bookmarks are Empty',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans', 
                fontSize: 18, 
                fontWeight: FontWeight.w700, 
                color: Color(0xFF171C1D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the bookmark badge on your favorite dining spots to add them here for immediate queue bookings.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans', 
                color: Colors.grey[500], 
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(BuildContext context, RestaurantDisplayState cardState) {
    final String brandName = cardState.brand.name;
    final String branchName = cardState.restaurant.branchName;
    final String cuisineText = cardState.brand.cuisine.isNotEmpty ? cardState.brand.cuisine : 'Local';
    final String openingHours = cardState.restaurant.openingHours;
    
    // Dynamic asset image conversion
    final String assetName = brandName.replaceAll(' ', '_');

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 18, right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), 
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000), 
            blurRadius: 15,
            spreadRadius: -3,
            offset: Offset(0, 10),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RestaurantCardPage(
                brandId: cardState.queue.brandId,
                restaurantId: cardState.queue.restaurantId,
              ),
            ),
          );
          // .then((assignedNumber) {
          //   if (assignedNumber != null && assignedNumber is int) {
          //     widget.onQueueRegisteredInChild(
          //       cardState.queue.restaurantId,
          //       assignedNumber,
          //     );
          //   }
          // });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO IMAGE ARCHITECTURE LAYER (WITH ERROR FALLBACK WRAPPER)
            SizedBox(
              height: 213.75, 
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/$assetName.png', 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Image(
                          image: AssetImage('assets/images/Restaurant_Icon.png'),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Color(0x66000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cardState.badgeBgColor,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        cardState.badgeText,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: cardState.badgeTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. MAIN DETAILS METADATA BLOCK
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    branchName.isNotEmpty ? '$brandName ($branchName)' : brandName, 
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20, 
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF171C1D),
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Cuisine row
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu_rounded, color: Color(0xFF6E797B), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        cuisineText,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6E797B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),                  
                  
                  const Divider(height: 24, thickness: 1, color: Color(0xFFEDF2F4)),
                  
                  // 3. HORIZONTAL DATA SPLIT (OPENING HOURS & TABLES WAITING METRIC)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFFF39850), size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                openingHours, 
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF39850),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 3.0), 
                            child: const Icon(
                              Icons.people_alt_outlined, 
                              color: Color(0xFF006670), 
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8), 
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${cardState.queueLength}',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 20, 
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF006670),
                                  height: 1.0, 
                                  leadingDistribution: TextLeadingDistribution.even,
                                ),
                              ),
                              const SizedBox(height: 4), 
                              const Text(
                                'tables waiting',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6E797B), 
                                  height: 1.0,
                                  leadingDistribution: TextLeadingDistribution.even,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}