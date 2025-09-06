import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greenbiller/core/colors.dart' as theme;
import 'package:greenbiller/core/gloabl_widgets/sidebar/admin_sidebar_wrapper.dart';
import 'package:greenbiller/core/utils/user_role_detrmine.dart';
import 'package:greenbiller/features/settings/controller/store_user_creation_controller.dart';

class StoreUsers extends GetView<UserCreationController> {
  const StoreUsers({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminSidebarWrapper(
      title: 'User Management',
      appColor: theme.accentColor,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Panel - User List
            Container(
              width: 360,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.people,
                            color: theme.accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Users',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: controller.clearForm,
                          icon: const Icon(Icons.add, size: 20, color: theme.accentColor),
                          label: const Text(
                            'New User',
                            style: TextStyle(fontSize: 14),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.accentColor,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.loadStoreUsers,
                          icon: const Icon(Icons.refresh, size: 20, color: theme.accentColor),
                          style: IconButton.styleFrom(
                            foregroundColor: theme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // User List
                  Obx(() {
                    if (controller.isLoadingStores.value == true) {
                      return const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (controller.storeUsers.value == null) {
                      return const Expanded(
                        child: Center(child: Text("No users found")),
                      );
                    } else if (controller.storeUsers.value?.data.isEmpty ?? true) {
                      return Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: theme.accentColor,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No users found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: controller.storeUsers.value!.data.length,
                          itemBuilder: (context, index) {
                            final user = controller.storeUsers.value!.data[index];
                            final role = UserRoleDetrmine.fromIdString(user.userLevel);
                            return Obx(
                              () => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: controller.selectedUserIndex.value == index
                                      ? theme.accentColor.withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: controller.selectedUserIndex.value == index
                                        ? theme.accentColor
                                        : Colors.grey.shade200,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: user.profileImage?.isNotEmpty == true
                                        ? null
                                        : const Color.fromARGB(225, 111, 255, 171),
                                    radius: 18,
                                    backgroundImage: user.profileImage?.isNotEmpty == true
                                        ? NetworkImage(user.profileImage!)
                                        : null,
                                    child: user.profileImage?.isEmpty != false
                                        ? Text(
                                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.email,
                                        style: const TextStyle(
                                          color: theme.textSecondaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user.storeName ?? '',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          role.name,
                                          style: TextStyle(
                                            color: Colors.green.shade700,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          size: 18,
                                          color: theme.accentColor,
                                        ),
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'view',
                                            child: Row(
                                              children: [
                                                Icon(Icons.visibility_outlined, size: 16, color: theme.accentColor),
                                                SizedBox(width: 8),
                                                Text('View Details'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_outlined, size: 16, color: theme.accentColor),
                                                SizedBox(width: 8),
                                                Text('Edit'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, 
                                                     size: 16, 
                                                     color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Delete', 
                                                     style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'view':
                                              controller.viewUserDetails(user);
                                              break;
                                            case 'edit':
                                              controller.loadUserForEdit(user);
                                              controller.selectedUserIndex.value = index;
                                              break;
                                            case 'delete':
                                              controller.deleteUser(
                                                user.id ?? 0,
                                                user.name,
                                              );
                                              break;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    controller.selectedUserIndex.value = index;
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
            // Right Panel - User Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dynamic Header based on mode
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              controller.isEditMode.value
                                  ? Icons.edit
                                  : Icons.person_add,
                              color: theme.accentColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            controller.isEditMode.value
                                ? 'Edit User'
                                : 'Create New User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (controller.isEditMode.value) ...[
                            const Spacer(),
                            TextButton.icon(
                              onPressed: controller.cancelEdit,
                              icon: const Icon(Icons.close, size: 18, color: Colors.orange),
                              label: const Text('Cancel Edit'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.orange,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Profile Image Section
                      Center(
                        child: Stack(
                          children: [
                            Obx(() {
                              Widget imageWidget;
                              if (controller.profileImage.value != null) {
                                imageWidget = CircleAvatar(
                                  radius: 40,
                                  backgroundImage: FileImage(controller.profileImage.value!),
                                );
                              } else if (controller.profileImageUrl.value.isNotEmpty) {
                                imageWidget = CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(controller.profileImageUrl.value),
                                );
                              } else {
                                imageWidget = Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 32,
                                    color: theme.accentColor,
                                  ),
                                );
                              }
                              return imageWidget;
                            }),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // Show options for image
                                  Get.bottomSheet(
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: const Icon(Icons.camera_alt, color: theme.accentColor),
                                            title: const Text('Pick Image'),
                                            onTap: () {
                                              Get.back();
                                              controller.pickProfileImage();
                                            },
                                          ),
                                          if (controller.profileImage.value != null ||
                                              controller.profileImageUrl.value.isNotEmpty)
                                            ListTile(
                                              leading: const Icon(Icons.delete, color: Colors.red),
                                              title: const Text('Remove Image'),
                                              onTap: () {
                                                Get.back();
                                                controller.removeProfileImage();
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.accentColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Form Fields with Controllers
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => TextField(
                              controller: TextEditingController(text: controller.name.value)
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.name.value.length),
                                ),
                              onChanged: (value) => controller.name.value = value,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person_outline, size: 20, color: theme.accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: theme.accentColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              style: const TextStyle(fontSize: 14),
                            )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => TextField(
                              controller: TextEditingController(text: controller.email.value)
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.email.value.length),
                                ),
                              onChanged: (value) => controller.email.value = value,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined, size: 20, color: theme.accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: theme.accentColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 14),
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Obx(() => TextField(
                              controller: TextEditingController(text: controller.countryCode.value)
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.countryCode.value.length),
                                ),
                              onChanged: (value) => controller.countryCode.value = value,
                              decoration: InputDecoration(
                                
                                labelText: 'Code',
                                prefixIcon: const Icon(Icons.flag_outlined, size: 20, color: theme.accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: theme.accentColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                            )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => TextField(
                              controller: TextEditingController(text: controller.phone.value)
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.phone.value.length),
                                ),
                              onChanged: (value) => controller.phone.value = value,
                              decoration: InputDecoration(
                                labelText: 'Phone',
                                prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: theme.accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: theme.accentColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                            )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => TextField(
                              controller: TextEditingController(text: controller.password.value)
                                ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.password.value.length),
                                ),
                              onChanged: (value) => controller.password.value = value,
                              decoration: InputDecoration(
                                labelText: controller.isEditMode.value 
                                    ? 'Password (Leave empty to keep current)'
                                    : 'Password',
                                prefixIcon: const Icon(Icons.password_outlined, size: 20, color: theme.accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: theme.accentColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              obscureText: true,
                              style: const TextStyle(fontSize: 14),
                            )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => DropdownButtonFormField<String>(
                              value: controller.selectedRole.value,
                              decoration: InputDecoration(
                                labelText: 'Role',
                                prefixIcon: const Icon(Icons.work_outline, size: 20, color: theme.accentColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: theme.accentColor),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              items: controller.userRolesMap.values
                                  .map(
                                    (role) => DropdownMenuItem<String>(
                                      value: role,
                                      child: Text(role, style: const TextStyle(fontSize: 14)),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedRole.value = value;
                                  controller.selectedRoleId.value = controller
                                      .userRolesMap
                                      .entries
                                      .firstWhere((entry) => entry.value == value)
                                      .key;
                                }
                              },
                            )),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(
                              () => DropdownButtonFormField<String>(
                                value: controller.storeMap.containsKey(controller.selectedStore.value) 
                                    ? controller.selectedStore.value 
                                    : null,
                                decoration: InputDecoration(
                                  labelText: 'Select Store',
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: theme.accentColor.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.store,
                                      color: theme.accentColor.withOpacity(0.85),
                                      size: 18,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: theme.accentColor),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                hint: const Text(
                                  'Select a Store',
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                items: controller.storeMap.entries.map(
                                  (entry) => DropdownMenuItem<String>(
                                    value: entry.key,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(color: Colors.black, fontSize: 14),
                                    ),
                                  ),
                                ).toList(),
                                onChanged: (value) {
                                  print('Dropdown onChanged called with value: $value');
                                  if (value != null) {
                                    controller.selectedStore.value = value;
                                    controller.selectedStoreId.value = controller.storeMap[value];
                                    print('Selected store: $value, ID: ${controller.storeMap[value]}');
                                    if (!controller.isEditMode.value) {
                                      controller.loadStoreUsers();
                                    }
                                  }
                                },
                                icon: controller.isLoadingStores.value
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(theme.accentColor),
                                        ),
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 20,
                                        color: theme.accentColor.withOpacity(0.85),
                                      ),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                borderRadius: BorderRadius.circular(10),
                                dropdownColor: Colors.white,
                                isExpanded: true,
                                menuMaxHeight: 250,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.isEditMode.value 
                                  ? controller.cancelEdit 
                                  : controller.clearForm,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                controller.isEditMode.value ? 'Cancel' : 'Clear',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(
                              () {
                                final isLoading = controller.isEditMode.value 
                                    ? controller.isUpdating.value 
                                    : controller.isLoading.value;
                                
                                return ElevatedButton(
                                  onPressed: isLoading ? null : () {
                                    if (controller.isEditMode.value) {
                                      // Update existing user
                                      final userId = controller.selectedUser.value?.id;
                                      if (userId != null) {
                                        controller.updateUser(userId);
                                      }
                                    } else {
                                      // Create new user
                                      controller.createUser();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.accentColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          controller.isEditMode.value ? 'Update User' : 'Create User',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      // Loading indicator for delete operation
                      Obx(() {
                        if (controller.isDeleting.value) {
                          return Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(Colors.red),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Deleting user...',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}