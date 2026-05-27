import 'package:flutter/material.dart';
import '../viewmodels/customer_home_viewmodel.dart';
import 'restaurant_card_page.dart'; 
import 'queue_status_page.dart'; 

class CustomerHomeView extends StatefulWidget {
  const CustomerHomeView({super.key});

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  int _currentIndex = 0; // Tracks active structural page selection

  String? activeRestaurantId;
  int? activeTicketNumber;

  @override
  Widget build(BuildContext context) {
    // List of structural master pages mapped to navigation tab indices
    final List<Widget> tabs = [
      // ✅ FIXED: Passing down the state modifier function into the Explore Sub-Widget Container
      ExploreTabContent(
        onQueueRegisteredInChild: (restId, ticketNum) {
          setState(() {
            activeRestaurantId = restId;
            activeTicketNumber = ticketNum;
            _currentIndex = 1;
          });
        },
      ),
      
      // Dynamically switches layout based on whether they have an active ticket
      activeTicketNumber != null 
        ? QueueStatusPage(
            restaurantId: activeRestaurantId!,
            myTicketNumber: activeTicketNumber!,
            ticketId: '',
          )
        : const Center(
            child: Text(
              'You are not currently in any queue line.',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, color: Color(0xFF6E797B)),
            ),
          ),
          
      const Center(child: Text('Reservations Page Coming Soon')),
      const Center(child: Text('Profile Settings Page Coming Soon')),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFB),
      
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
      ),

      // 📌 FIXED BOTTOM DOCK NAVIGATION BAR
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 88,
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
              offset: Offset(0, -5), 
            )
          ],
        ),
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(0, Icons.storefront_rounded, "Explore"),
            _buildNavButton(1, Icons.confirmation_num_rounded, "Queue"),
            _buildNavButton(2, Icons.calendar_today_rounded, "Reservation"),
            _buildNavButton(3, Icons.person_rounded, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(int index, IconData icon, String label) {
    final bool isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: isActive 
            ? BoxDecoration(
                color: const Color(0xFFF0FDFA), 
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isActive ? const Color(0xFF115E59) : const Color(0xFF64748B), 
              size: 20,
            ),
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
      ),
    );
  }
}

// =========================================================================
// 🌐 SUB-WIDGET COMPONENT: EXPLORE FEED SCROLL VIEW
// =========================================================================
class ExploreTabContent extends StatefulWidget {
  // ✅ FIXED: Constructor now accepts the parameter pass-through handler
  final Function(String restaurantId, int ticketNumber) onQueueRegisteredInChild;

  const ExploreTabContent({
    super.key,
    required this.onQueueRegisteredInChild,
  });

  @override
  State<ExploreTabContent> createState() => _ExploreTabContentState();
}

class _ExploreTabContentState extends State<ExploreTabContent> {
  final CustomerHomeViewModel _viewModel = CustomerHomeViewModel();

  @override
  Widget build(BuildContext context) {
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

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchSection(),
            const SizedBox(height: 32),
            _buildCategoriesSection(),
            const SizedBox(height: 32),
            const Text(
              'Restaurants',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF134E4A),
                letterSpacing: -0.75,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Popular entry queues nearby',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3E494B),
              ),
            ),
            const SizedBox(height: 24),

            StreamBuilder<List<RestaurantDisplayState>>(
              stream: _viewModel.restaurantCardsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: CircularProgressIndicator(color: Color(0xFF006670)),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final cardStates = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cardStates.length,
                  itemBuilder: (context, index) {
                    return _buildRestaurantCard(context, cardStates[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFDFE3E4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search for restaurants, cuisines...',
          hintStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF3E494B),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF6E797B), size: 18),
          suffixIcon: Icon(Icons.tune_rounded, color: Color(0xFF006670), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'label': 'Western', 'icon': Icons.restaurant_rounded},
      {'label': 'Sushi', 'icon': Icons.rice_bowl_rounded},
      {'label': 'Burgers', 'icon': Icons.lunch_dining_rounded},
      {'label': 'Beverages', 'icon': Icons.coffee_rounded},
      {'label': 'Local', 'icon': Icons.dinner_dining_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Categories',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171C1D),
                letterSpacing: -0.5,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006670),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        categories[index]['icon'] as IconData,
                        color: const Color(0xFF006670),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      categories[index]['label'] as String,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3E494B),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantCard(BuildContext context, RestaurantDisplayState cardState) {
    final String assetName = cardState.brand.name.replaceAll(' ', '_');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          ).then((assignedNumber) {
            // ✅ FIXED: Using the native Flutter route completion engine framework!
            // When the card detail view is popped off the screen stack, if it passes back an int ticket,
            // we relay that data back up using our callback.
            if (assignedNumber != null && assignedNumber is int) {
              
              widget.onQueueRegisteredInChild(
                cardState.queue.restaurantId,
                assignedNumber,
              );
            }
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 213.75, 
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFECEFF1),
                image: DecorationImage(
                  image: AssetImage('assets/images/$assetName.png'), 
                  onError: (exception, stackTrace) => const AssetImage('assets/images/Oriental_Kopi.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
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

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cardState.brand.name} (${cardState.restaurant.branchName})', 
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
                  
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu_rounded, color: Color(0xFF6E797B), size: 14),
                      const SizedBox(width: 6),
                      Text(
                        cardState.brand.cuisine.isNotEmpty ? cardState.brand.cuisine : 'Local',
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
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, color: Color(0xFFF39850), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              cardState.restaurant.openingHours, 
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF39850),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start, // Align icon cleanly with the top line of text
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 3.0), // Precision alignment for the icon vector
                            child: const Icon(
                              Icons.people_alt_outlined, 
                              color: Color(0xFF006670), 
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8), // Clean spacing separation from icon to text block
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${cardState.queueLength}',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 20, // Increased size to make the primary data metric stand out
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF006670),
                                  height: 1.0, // Forces the font container box to fit the character bounds tightly
                                  leadingDistribution: TextLeadingDistribution.even,
                                ),
                              ),
                              const SizedBox(height: 4), // Controlled margin gap preventing vertical collision
                              const Text(
                                'tables waiting',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6E797B), // Slate color creates visual hierarchy against the bold number
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Icon(Icons.restaurant_menu_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No registered restaurants found.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6E797B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}