import 'package:flutter/material.dart';
import 'package:virtual_queue/views/restaurant_queue_page.dart';
import 'package:virtual_queue/views/restaurant_profile_page.dart';

class RestaurantReservationPage extends StatefulWidget {
  final String restaurantId;
  final String restaurantBrandId;
  final List<String> restaurantIds;

  const RestaurantReservationPage({
    super.key,
    required this.restaurantId,
    required this.restaurantBrandId,
    required this.restaurantIds,
  });

  @override
  State<RestaurantReservationPage> createState() => _RestaurantReservationPageState();
}

class _RestaurantReservationPageState extends State<RestaurantReservationPage>{

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FAFB),
      body: Column(
        children: [],
      ),
      bottomNavigationBar: Container(
        height: 100,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(
              icon: Icons.room_service_outlined,
              label: 'Reservation',
              isActive: true,
              onTap: () {},
            ),
            _buildBottomNavItem(
              icon: Icons.hourglass_empty,
              label: 'Queue',
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantQueuePage(
                      restaurantBrandId: widget.restaurantBrandId,
                      restaurantId: widget.restaurantId,
                      restaurantIds: widget.restaurantIds,
                    ),
                  ),
                );
              },
            ),
            _buildBottomNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantProfilePage(
                      restaurantBrandId: widget.restaurantBrandId,
                      restaurantId: widget.restaurantId,
                      restaurantIds: widget.restaurantIds,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF0FDFA) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? const Color(0xFF115E59) : const Color(0xFF64748B),
            ),
            const SizedBox(height: 2),
            Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF115E59) : const Color(0xFF64748B),
                )
            ),
          ],
        ),
      ),
    );
  }
}