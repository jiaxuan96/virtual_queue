import 'package:flutter/material.dart';
import 'package:virtual_queue/models/restaurant_brand_model.dart';
import 'package:virtual_queue/models/restaurant_queue_model.dart';
import 'package:virtual_queue/viewmodels/restaurant_queue_viewmodel.dart';
import 'package:virtual_queue/models/restaurant_model.dart';

class RestaurantQueuePage extends StatefulWidget{
  final String restaurantId;
  final String restaurantBrandId;
  final List<String> restaurantIds;

  const RestaurantQueuePage({super.key, required this.restaurantId, required this.restaurantBrandId, required this.restaurantIds,});

  @override
  State<RestaurantQueuePage> createState() => _RestaurantQueuePageState();
}

class _RestaurantQueuePageState extends State<RestaurantQueuePage> {

  final viewmodel = RestaurantQueueViewmodel();

  late String selectedRestaurantId;

  @override
  void initState() {
    super.initState();
    selectedRestaurantId = widget.restaurantId;
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0FDFA) : const Color(0xFFFFFFFFF),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 140,
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 70,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      color: Color(0xFF006670),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/Oriental_Kopi_Logo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<RestaurantBrandModel>(
                stream: viewmodel.watchRestaurantBrand(widget.restaurantBrandId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text(
                      'Loading...',
                      style: TextStyle(color: Colors.white),
                    );
                  }
                  final brand = snapshot.data!;
                  return Text(
                    brand.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 12
                  ),
                  SizedBox(width: 2),
                  StreamBuilder<RestaurantModel> (
                      stream: viewmodel.watchRestaurantBranch(
                        widget.restaurantBrandId,
                        widget.restaurantId,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          );
                        }
                        final restaurant = snapshot.data!;
                        return Text(
                          restaurant.branchName,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        );
                      }
                  )
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Color(0xFFF0F4F5),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  '${widget.restaurantIds.length} branch',
                  style: const TextStyle(
                    color: Color(0xFF006670),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF006670),
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6FAFB),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<RestaurantQueueModel>(
              stream: viewmodel.watchQueue(widget.restaurantId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final queue = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Queue Management',
                        style: TextStyle(
                          fontWeight: FontWeight(1000),
                          color: Color(0xFF006670),
                          fontSize: 25,
                        ),
                      ),
                      SizedBox(height:10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F4F5),
                          borderRadius: BorderRadius.circular(20),
                          border: const Border(
                            left: BorderSide(color: Color(0xFF006670), width: 8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '# ${queue.currentServing}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                              ),
                            ),
                            Text(
                              'Now Serving',
                              style: TextStyle(
                                color: Color(0xFF777777),
                                fontSize: 16,
                              ),
                            ),
                            Divider(height: 32),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF006670),
                                  padding: const EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 10),
                                ),
                                onPressed: (){
                                  viewmodel.callNextCustomer(widget.restaurantId);
                                },
                                icon: const Icon(
                                  Icons.notifications,
                                  color: Color(0xFFFFFFFF),
                                  size: 20,
                                ),
                                label: const Text(
                                  'Call Next',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF1F2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${queue.queueLength}',
                              style: const TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight(1000),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Tables in Queue',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF39850),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                queue.waitStatus,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
              isActive: false,
            ),
            _buildBottomNavItem(
              icon: Icons.hourglass_empty,
              label: 'Queue',
              isActive: true,
            ),
            _buildBottomNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: false,
            ),
          ],
        ),
      ),
    );
  }
}