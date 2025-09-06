import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbiller/core/api_constants.dart';
import 'package:greenbiller/core/app_handler/dio_client.dart';
import 'package:greenbiller/core/utils/common_api_functions_controller.dart';
import 'package:greenbiller/features/auth/controller/auth_controller.dart';
import 'package:greenbiller/features/settings/models/store_users_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:logger/logger.dart';

class UserCreationController extends GetxController {
  // Services
  late DioClient dioClient;
  late AuthController authController;
  late CommonApiFunctionsController commonApi;
  late Logger logger;
  final ImagePicker _picker = ImagePicker();

  // Form fields
  final name = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final password = ''.obs;
  final countryCode = '+91'.obs;
  final selectedRole = 'Manager'.obs;
  final selectedRoleId = 3.obs;
  final selectedStore = Rxn<String>();
  final selectedStoreId = Rxn<int>();
  final isLoading = false.obs;
  final isLoadingStores = false.obs;
  final isUpdating = false.obs;
  final isDeleting = false.obs;
  final profileImage = Rxn<File>();
  final profileImageUrl = ''.obs;
  final storeMap = <String, int>{}.obs;
  final storeUsers = Rxn<StoreUsersModelsResponse>();
  final selectedUserIndex = (-1).obs;  // Fixed: Changed from 4 to -1
  final selectedUser = Rxn<StoreUsersModel>();
  final isEditMode = false.obs;

  final userRolesMap = {
    2: 'Manager',
    3: 'Staff',
    4: 'Store Admin',
    5: 'Store Manager',
    6: 'Store Accountant',
    7: 'Store Staff',
    8: 'Biller',
  };

  @override
  void onInit() {
    super.onInit();
    dioClient = DioClient();
    authController = Get.find<AuthController>();
    commonApi = Get.find<CommonApiFunctionsController>();
    logger = Logger();

    loadStores();
  }

  Future<void> loadStores() async {
    try {
      isLoadingStores.value = true;
      final stores = await commonApi.fetchStores();

      if (stores.isNotEmpty) {
        storeMap.clear();
        storeMap.assignAll(stores);
        
        // Set first store as default only if no store is currently selected
        if (selectedStore.value == null || !storeMap.containsKey(selectedStore.value)) {
          final firstStore = stores.keys.first;
          final firstStoreId = stores.values.first;
          
          selectedStore.value = firstStore;
          selectedStoreId.value = firstStoreId;
          
          logger.i('Set default store: $firstStore (ID: $firstStoreId)');
        }
        
        logger.i('Loaded ${stores.length} stores');
        
        // Load users after stores are loaded
        await loadStoreUsers();
        
      } else {
        logger.w('No stores found');
        storeMap.clear();
        selectedStore.value = null;
        selectedStoreId.value = null;
      }
    } catch (e, stack) {
      logger.e("Error in loadStores: $e", e, stack);
    } finally {
      isLoadingStores.value = false;
    }
  }

  Future<void> loadStoreUsers() async {
    try {
      isLoadingStores.value = true;
      final url = selectedStoreId.value != null
          ? '$storeusersUrl?store_id=${selectedStoreId.value}'
          : storeusersUrl;

      final response = await dioClient.dio.get(url);

      if (response.statusCode == 200 && response.data['status'] == 1) {
        storeUsers.value = StoreUsersModelsResponse.fromJson(response.data);
        logger.i('Loaded store users: ${storeUsers.value!.data.length} users');
      } else {
        storeUsers.value = StoreUsersModelsResponse(
          message: 'Failed to fetch store users',
          data: [],
          total: 0,
          status: 0,
        );
        logger.w('Failed to load store users: ${response.data}');
      }
    } catch (e, stackTrace) {
      logger.e('Error loading store users: $e', e, stackTrace);
      storeUsers.value = StoreUsersModelsResponse(
        message: 'Unexpected error: $e',
        data: [],
        total: 0,
        status: 0,
      );
    } finally {
      isLoadingStores.value = false;
    }
  }

  // Fixed: Store selection method
  void onStoreChanged(String? storeName) {
    if (storeName != null && storeMap.containsKey(storeName)) {
      selectedStore.value = storeName;
      selectedStoreId.value = storeMap[storeName];
      logger.i('Store changed to: $storeName (ID: ${storeMap[storeName]})');
      
      // Load users for the newly selected store
      if (!isEditMode.value) {
        loadStoreUsers();
      }
    }
  }

  // Debug method to check store state
  void debugStoreState() {
    logger.i('=== STORE STATE DEBUG ===');
    logger.i('selectedStore.value: ${selectedStore.value}');
    logger.i('selectedStoreId.value: ${selectedStoreId.value}');
    logger.i('storeMap.keys: ${storeMap.keys.toList()}');
    logger.i('storeMap.values: ${storeMap.values.toList()}');
    logger.i('storeMap.isEmpty: ${storeMap.isEmpty}');
    logger.i('========================');
  }

  Future<void> createUser() async {
    try {
      isLoading.value = true;
      
      // Debug store state before validation
      debugStoreState();
      
      final errors = _validateFields();
      if (errors.isNotEmpty) {
        Get.snackbar('Error', errors.join('\n'), backgroundColor: Colors.red);
        return;
      }
      log(selectedRoleId.value.toString());
      
      // Prepare form data
      final formData = dio.FormData.fromMap({
        'user_level': selectedRoleId.value.toString(),
        'name': name.value.trim(),
        'email': email.value.trim(),
        'country_code': countryCode.value.trim(),
        'mobile': phone.value.trim(),
        'password': password.value.trim(),
        'password_confirmation': password.value.trim(),
        'store_id': selectedStoreId.value.toString(),
      });

      // Add profile image if selected
      if (profileImage.value != null) {
        formData.files.add(MapEntry(
          'profile_image',
          await dio.MultipartFile.fromFile(
            profileImage.value!.path,
            filename: profileImage.value!.path.split('/').last,
          ),
        ));
      }

      final response = await dioClient.dio.post(signUpUrl, data: formData);

      if (response.statusCode == 200) {
        await loadStoreUsers(); // Refresh user list
        Get.snackbar(
          'Success',
          'New user created successfully',
          backgroundColor: Colors.green,
        );
        clearForm();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e, stackTrace) {
      logger.e('Error creating user: $e', e, stackTrace);
      Get.snackbar('Error', 'Signup failed: $e', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // Update User Function
  Future<void> updateUser(int userId) async {
    try {
      isUpdating.value = true;
      final errors = _validateFields(isUpdate: true);
      if (errors.isNotEmpty) {
        Get.snackbar('Error', errors.join('\n'), backgroundColor: Colors.red);
        return;
      }

      // Prepare form data
      final formData = dio.FormData.fromMap({
        'name': name.value.trim(),
        'email': email.value.trim(),
        'country_code': countryCode.value.trim(),
        'mobile': phone.value.trim(),
        'user_level': selectedRoleId.value.toString(),
        'store_id': selectedStoreId.value.toString(),
      });

      // Add password only if provided
      if (password.value.isNotEmpty) {
        formData.fields.add(MapEntry('password', password.value.trim()));
      }

      // Add profile image if selected
      if (profileImage.value != null) {
        formData.files.add(MapEntry(
          'profile_image',
          await dio.MultipartFile.fromFile(
            profileImage.value!.path,
            filename: profileImage.value!.path.split('/').last,
          ),
        ));
      }

      final response = await dioClient.dio.put(
        'user-update/$userId',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        await loadStoreUsers(); // Refresh user list
        Get.snackbar(
          'Success',
          'User updated successfully',
          backgroundColor: Colors.green,
        );
        clearForm();
        isEditMode.value = false;
      } else {
        _handleErrorResponse(response);
      }
    } catch (e, stackTrace) {
      logger.e('Error updating user: $e', e, stackTrace);
      Get.snackbar('Error', 'Update failed: $e', backgroundColor: Colors.red);
    } finally {
      isUpdating.value = false;
    }
  }

  // Delete User Function
  Future<void> deleteUser(int userId, String userName) async {
    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "$userName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isDeleting.value = true;
      
      final response = await dioClient.dio.delete('user-delete/$userId');

      if (response.statusCode == 200) {
        await loadStoreUsers(); // Refresh user list
        Get.snackbar(
          'Success',
          'User deleted successfully',
          backgroundColor: Colors.green,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete user',
          backgroundColor: Colors.red,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error deleting user: $e', e, stackTrace);
      Get.snackbar('Error', 'Delete failed: $e', backgroundColor: Colors.red);
    } finally {
      isDeleting.value = false;
    }
  }

  // Load User Details for Edit/View
  void loadUserForEdit(StoreUsersModel user) {
    selectedUser.value = user;
    name.value = user.name ?? '';
    email.value = user.email ?? '';
    phone.value = user.mobile ?? '';
    countryCode.value = user.countryCode ?? '+91';
    profileImageUrl.value = user.profileImage ?? '';
    
    // Set role
    final roleEntry = userRolesMap.entries
        .firstWhere((entry) => entry.value == user.userLevel, 
                   orElse: () => const MapEntry(3, 'Staff'));
    selectedRoleId.value = roleEntry.key;
    selectedRole.value = roleEntry.value;
    
    // Set store
    if (user.storeId != null) {
      final storeEntry = storeMap.entries
          .firstWhere((entry) => entry.value == user.storeId, 
                     orElse: () => storeMap.entries.first);
      selectedStore.value = storeEntry.key;
      selectedStoreId.value = storeEntry.value;
    }
    
    isEditMode.value = true;
    password.value = ''; // Clear password for edit mode
  }

  // View User Details (Read-only)
  void viewUserDetails(StoreUsersModel user) {
    selectedUser.value = user;
    Get.dialog(
      AlertDialog(
        title: Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.profileImage?.isNotEmpty == true)
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(user.profileImage!),
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('Name', user.name ?? 'N/A'),
              _buildDetailRow('Email', user.email ?? 'N/A'),
              _buildDetailRow('Phone', '${user.countryCode ?? ''} ${user.mobile ?? ''}'),
              _buildDetailRow('Role', user.userLevel ?? 'N/A'),
              _buildDetailRow('Store ID', user.storeId?.toString() ?? 'N/A'),
              _buildDetailRow('Created At', user.createdAt ?? 'N/A'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              loadUserForEdit(user);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Pick Profile Image
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      logger.e('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image', backgroundColor: Colors.red);
    }
  }

  // Remove Profile Image
  void removeProfileImage() {
    profileImage.value = null;
    profileImageUrl.value = '';
  }

  List<String> _validateFields({bool isUpdate = false}) {
    final errors = <String>[];
    if (name.value.isEmpty) errors.add('Name cannot be empty');
    if (email.value.isEmpty) {
      errors.add('Email cannot be empty');
    } else if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email.value)) {
      errors.add('Enter a valid email address');
    }
    if (countryCode.value.isEmpty) {
      errors.add('Country code is required');
    } else if (!RegExp(r'^\+?[0-9]{1,4}$').hasMatch(countryCode.value)) {
      errors.add('Invalid country code format');
    }
    if (phone.value.isEmpty) {
      errors.add('Phone number cannot be empty');
    } else if (!RegExp(r'^[0-9]{6,15}$').hasMatch(phone.value)) {
      errors.add('Invalid phone number');
    }
    
    // Password validation - required for create, optional for update
    if (!isUpdate) {
      if (password.value.isEmpty) {
        errors.add('Password cannot be empty');
      } else if (password.value.length < 6) {
        errors.add('Password must be at least 6 characters');
      }
    } else if (password.value.isNotEmpty && password.value.length < 6) {
      errors.add('Password must be at least 6 characters');
    }
    
    if (selectedRole.value.isEmpty) {
      errors.add('Please select a valid role');
    }
    if (selectedStoreId.value == null || selectedStore.value == null) {
      errors.add('Please select a valid store');
    }
    return errors;
  }

  void _handleErrorResponse(dio.Response response) {
    final decodedData = response.data;
    if (decodedData is Map && decodedData.containsKey('errors')) {
      final errors = decodedData['errors'] as Map<String, dynamic>;
      final messages = errors.values.expand((e) => e).join('\n');
      Get.snackbar('Error', messages, backgroundColor: Colors.red);
    } else {
      Get.snackbar(
        'Error',
        decodedData['message'] ?? 'Operation failed',
        backgroundColor: Colors.red,
      );
    }
  }

  void clearForm() {
    name.value = '';
    email.value = '';
    phone.value = '';
    password.value = '';
    countryCode.value = '+91';
    selectedRole.value = 'Manager';
    selectedRoleId.value = 3;
    
    // Keep the current selected store when clearing form
    // Only reset if no stores are available
    if (storeMap.isEmpty) {
      selectedStore.value = null;
      selectedStoreId.value = null;
      logger.w('clearForm - No stores available');
    } else {
      // Keep current store selection or set first store if none selected
      if (selectedStore.value == null || !storeMap.containsKey(selectedStore.value)) {
        selectedStore.value = storeMap.keys.first;
        selectedStoreId.value = storeMap.values.first;
        logger.i('clearForm - Set store: ${selectedStore.value}, ID: ${selectedStoreId.value}');
      }
    }
    
    profileImage.value = null;
    profileImageUrl.value = '';
    selectedUser.value = null;
    isEditMode.value = false;
    selectedUserIndex.value = -1; // Reset selection
  }

  // Cancel Edit Mode
  void cancelEdit() {
    clearForm();
    isEditMode.value = false;
  }
}