import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:halal_admin/core/constants/app_colors.dart';
import 'package:halal_admin/core/constants/app_strings.dart';
import 'package:halal_admin/core/utils/validators.dart';
import 'package:halal_admin/core/routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _currentRestaurantIndex = 0;
  int _currentPhotoIndex = 0;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _whatsappController = TextEditingController();

  late AnimationController _phoneAnimController;
  late AnimationController _carouselAnimController;
  late Animation<double> _phoneFloatAnimation;

  final List<Map<String, dynamic>> _mockRestaurants = [
    {
      'name': 'Le Delice Oriental',
      'cuisine': 'Marocain',
      'badge': 'Top 3',
      'photos': [
        'assets/images/landing/couscous_4k.jpg',
        'assets/images/landing/tajine_4k.jpg',
        'assets/images/landing/pastilla_4k.jpg',
      ],
    },
    {
      'name': 'Istanbul Grill',
      'cuisine': 'Turc',
      'badge': 'Tendance',
      'photos': [
        'assets/images/landing/kebab_4k.jpg',
        'assets/images/landing/mezze_turc_4k.jpg',
        'assets/images/landing/chawarma_4k.jpg',
      ],
    },
    {
      'name': 'Le Jardin de Beyrouth',
      'cuisine': 'Libanais',
      'badge': 'Premium',
      'photos': [
        'assets/images/landing/mezze_libanais_4k.jpg',
        'assets/images/landing/falafel_4k.jpg',
        'assets/images/landing/baklava_4k.jpg',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _phoneAnimController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    
    _phoneFloatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _phoneAnimController, curve: Curves.easeInOut),
    );

    _carouselAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startRestaurantCarousel();
    _startPhotoCarousel();
  }

  void _startRestaurantCarousel() {
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _currentRestaurantIndex = (_currentRestaurantIndex + 1) % _mockRestaurants.length;
          _currentPhotoIndex = 0;
        });
        _carouselAnimController.forward(from: 0);
        _startRestaurantCarousel();
      }
    });
  }

  void _startPhotoCarousel() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentPhotoIndex = (_currentPhotoIndex + 1) % 3;
        });
        _startPhotoCarousel();
      }
    });
  }

  @override
  void dispose() {
    _phoneAnimController.dispose();
    _carouselAnimController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _restaurantNameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      if (_isLogin) {
        _showSnackBar('Connexion reussie !', isError: false);
      } else {
        final normalizedPhone = Validators.normalizeWhatsAppNumber(_whatsappController.text);
        _showSnackBar('Inscription reussie ! Redirection...', isError: false);
        
        if (mounted) {
          Navigator.pushNamed(
            context,
            AppRoutes.registration,
            arguments: RegistrationArgs(
              restaurantName: _restaurantNameController.text,
              email: _emailController.text,
              whatsappNumber: normalizedPhone,
            ),
          );
        }
      }
    } catch (e) {
      _showSnackBar('Erreur: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildHeroSection(),
              _buildPhoneMockup(),
              _buildFeatures(),
              _buildGiftBanner(),
              _buildFormSection(),
              _buildPromiseSection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => AppColors.goldGradient.createShader(bounds),
            child: const Text(
              AppStrings.appName,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _isLogin = true),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(AppStrings.btnDashboard, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          const Text(AppStrings.heroTitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15)),
          const SizedBox(height: 20),
          Text(AppStrings.heroSubtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildPhoneMockup() {
    final restaurant = _mockRestaurants[_currentRestaurantIndex];
    final photos = restaurant['photos'] as List<String>;
    final currentPhoto = photos[_currentPhotoIndex];
    
    return AnimatedBuilder(
      animation: _phoneFloatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _phoneFloatAnimation.value),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 50),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 380,
                  height: 750,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 80,
                        spreadRadius: 20
                      )
                    ]
                  ),
                ),
                Container(
                  width: 360,
                  height: 720,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 60
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(42),
                    child: Stack(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            key: ValueKey('$_currentRestaurantIndex-$_currentPhotoIndex'),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(currentPhoto),
                                fit: BoxFit.cover
                              )
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.black.withValues(alpha: 0.7)
                                  ]
                                )
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 120,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1C1C1E),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)
                                )
                              ),
                            )
                          )
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 800),
                            child: Container(
                              key: ValueKey(_currentRestaurantIndex),
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.9)
                                  ]
                                )
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Text(
                                      restaurant['badge'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                      )
                                    )
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    restaurant['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800
                                    )
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    restaurant['cuisine'],
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 15
                                    )
                                  )
                                ]
                              )
                            )
                          )
                        )
                      ]
                    ),
                  ),
                ),
              ]
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatures() {
    final features = [
      {'icon': '⚡', 'title': AppStrings.feature1Title, 'desc': AppStrings.feature1Desc},
      {'icon': '📈', 'title': AppStrings.feature2Title, 'desc': AppStrings.feature2Desc},
      {'icon': '💰', 'title': AppStrings.feature3Title, 'desc': AppStrings.feature3Desc},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: features.map((feature) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(16)
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.goldButtonGradient,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Center(
                  child: Text(
                    feature['icon']!,
                    style: const TextStyle(fontSize: 24)
                  )
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['desc']!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13
                      )
                    )
                  ]
                )
              )
            ]
          )
        )).toList(),
      ),
    );
  }

  Widget _buildGiftBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.giftGradient,
        border: Border.all(color: AppColors.giftBorder, width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.giftRed.withValues(alpha: 0.4),
            blurRadius: 30
          )
        ]
      ),
      child: const Text(
        AppStrings.giftBanner,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border.all(color: AppColors.darkSurfaceSecondary, width: 2),
        borderRadius: BorderRadius.circular(24)
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              AppStrings.formTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.gold
              )
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.formSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary
              )
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTab(
                    AppStrings.login,
                    _isLogin,
                    () => setState(() => _isLogin = true)
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTab(
                    AppStrings.signup,
                    !_isLogin,
                    () => setState(() => _isLogin = false)
                  )
                )
              ]
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isLogin ? _buildLoginForm() : _buildSignupForm()
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  )
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: AppColors.goldButtonGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        blurRadius: 20
                      )
                    ]
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2
                            )
                          )
                        : Text(
                            _isLogin ? AppStrings.login : AppStrings.btnCreateAccount,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            )
                          ),
                  ),
                ),
              ),
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 12),
              Text(
                AppStrings.btnSubtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary
                )
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.goldButtonGradient : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.darkBorder
          )
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14
          )
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      children: [
        _buildTextField(
          controller: _emailController,
          label: AppStrings.email,
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: AppStrings.password,
          icon: Icons.lock,
          obscureText: _obscurePassword,
          validator: Validators.password,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withValues(alpha: 0.5)
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword)
          )
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _showSnackBar('Fonctionnalite a venir', isError: false),
            child: const Text(
              AppStrings.forgotPassword,
              style: TextStyle(color: AppColors.gold, fontSize: 12)
            )
          )
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      key: const ValueKey('signup'),
      children: [
        _buildTextField(
          controller: _restaurantNameController,
          label: '${AppStrings.restaurantName} *',
          icon: Icons.restaurant_menu,
          validator: Validators.required,
          placeholder: AppStrings.restaurantNamePlaceholder
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email professionnel *',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
          placeholder: AppStrings.emailPlaceholder
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _whatsappController,
          label: '${AppStrings.whatsappNumber} *',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: Validators.whatsapp,
          placeholder: AppStrings.whatsappPlaceholder,
          helperText: AppStrings.whatsappHelper
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _passwordController,
          label: '${AppStrings.password} *',
          icon: Icons.lock,
          obscureText: _obscurePassword,
          validator: Validators.password,
          placeholder: AppStrings.passwordPlaceholder,
          helperText: AppStrings.passwordHelper,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withValues(alpha: 0.5)
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword)
          )
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? placeholder,
    String? helperText
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            hintText: placeholder,
            helperText: helperText,
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            helperStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11
            ),
            prefixIcon: Icon(icon, color: AppColors.gold),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.darkSurfaceSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.darkBorder)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gold, width: 2)
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromiseSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 42)),
          const SizedBox(height: 20),
          const Text(
            AppStrings.promiseTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white
            )
          ),
          const SizedBox(height: 18),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 17, color: AppColors.textSecondary),
              children: const [
                TextSpan(text: '🔥 En rejoignant '),
                TextSpan(
                  text: 'Halal Admin',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold
                  )
                ),
                TextSpan(
                  text: ', votre restaurant devient visible dans le flux, dans les recherches, et dans les recommandations.'
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1))
              )
            ),
            child: const Text(
              AppStrings.promiseFooter,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.w600
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1))
        )
      ),
      child: const Text(
        AppStrings.footer,
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF666666), fontSize: 13)
      ),
    );
  }
}