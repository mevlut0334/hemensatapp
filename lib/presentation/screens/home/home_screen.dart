import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hemensatapp/logic/sale_listing/sale_listings_list_event.dart';
import 'package:hemensatapp/presentation/screens/my_listings/my_sale_listings_screen.dart';
import 'package:hemensatapp/presentation/screens/offers/received_offers_screen.dart';
import 'package:hemensatapp/presentation/screens/offers/sent_offers_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/service_locator.dart'; // ← Bunu ekleyin
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_event.dart';
import '../../../logic/repair_listing/repair_listings_list_bloc.dart';
import '../../../logic/repair_listing/repair_listings_list_event.dart';
import 'repair_listings_tab.dart';
import '../../../logic/sale_listing/sale_listings_list_bloc.dart';
import 'sale_listings_tab.dart';
import '../../widgets/common/app_drawer.dart';
import '../my_listings/my_repair_listings_screen.dart'; // <-- BU SATIRI EKLEYİN

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedListingType = 'sale'; // 'sale' veya 'repair'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(), // ← BU SATIRI EKLEYİN
      appBar: AppBar(
        title: const Text('HemenSat'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Çıkış Yap',
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'İlan Gir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'İşlemlerim',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildCreateListingTab();
      case 2:
        return _buildMyListingsTab();
      default:
        return _buildHomeTab();
    }
  }

  // ANASAYFA SEKMESİ
  Widget _buildHomeTab() {
    return Column(
      children: [
        // Üst butonlar: Satış İlanları / Tamir İlanları
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterButton(
                  label: 'Satış İlanları',
                  isSelected: _selectedListingType == 'sale',
                  onTap: () {
                    setState(() {
                      _selectedListingType = 'sale';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterButton(
                  label: 'Tamir İlanları',
                  isSelected: _selectedListingType == 'repair',
                  onTap: () {
                    setState(() {
                      _selectedListingType = 'repair';
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // İlanlar listesi
        Expanded(
          child: _selectedListingType == 'repair'
              ? BlocProvider(
                  create: (context) =>
                      sl<RepairListingsListBloc>()
                        ..add(const LoadRepairListings()),
                  child: const RepairListingsTab(),
                )
              : BlocProvider(
                  create: (context) =>
                      sl<SaleListingsListBloc>()..add(const LoadSaleListings()),
                  child: const SaleListingsTab(),
                ),
        ),
      ],
    );
  }

  // İLAN GİR SEKMESİ
  Widget _buildCreateListingTab() {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Üst butonlar konteyner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Satış Yap Butonu
                _buildListingTypeButton(
                  icon: Icons.sell_outlined,
                  label: 'Satış Yap',
                  description: 'Cihazınızı satışa çıkarın',
                  onTap: () {
                    // Satış ilanı oluşturma ekranına git
                    Navigator.pushNamed(context, '/create-sale-listing');
                  },
                ),
                const SizedBox(height: 12),
                // Tamir Ettir Butonu
                _buildListingTypeButton(
                  icon: Icons.build_outlined,
                  label: 'Tamir Ettir',
                  description: 'Cihazınızı tamire verin',
                  onTap: () {
                    // Tamir ilanı oluşturma ekranına git
                    Navigator.pushNamed(context, '/create-repair-listing');
                  },
                ),
              ],
            ),
          ),

          // Boş alan
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Yukarıdan bir seçenek seçin',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // İLAN TİPİ BUTONU
  Widget _buildListingTypeButton({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 32, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // İŞLEMLERİM SEKMESİ
  Widget _buildMyListingsTab() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık
          const Text(
            'İşlemlerim',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Butonlar
          _buildMyListingsButton(
            icon: Icons.sell_outlined,
            label: 'Satış İlanlarım',
            description: 'Yayınladığınız satış ilanları',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MySaleListingsScreen(),
                ),
              );
              // Navigator.pushNamed(context, '/my-sale-listings');
            },
          ),
          const SizedBox(height: 12),

          _buildMyListingsButton(
            icon: Icons.build_outlined,
            label: 'Tamir İlanlarım',
            description: 'Yayınladığınız tamir ilanları',
            onTap: () {
              // MyRepairListingsScreen sayfasına yönlendir
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyRepairListingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildMyListingsButton(
            icon: Icons.inbox_outlined,
            label: 'Gelen Tekliflerim',
            description: 'İlanlarınıza gelen teklifler',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReceivedOffersScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildMyListingsButton(
            icon: Icons.send_outlined,
            label: 'Teklif Verdiklerim',
            description: 'Gönderdiğiniz teklifler',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SentOffersScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // İŞLEMLERİM BUTON WİDGET
  Widget _buildMyListingsButton({
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 28, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // FİLTRE BUTONU
  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
