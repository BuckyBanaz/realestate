import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/constant/app_colors.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController();
    final _phoneController = TextEditingController();
    final _emailController = TextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text("Edit Profile", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(IconlyLight.profile, size: 30, color: Theme.of(context).iconTheme.color),
                  backgroundColor: Theme.of(context).cardColor,
                  // backgroundImage: NetworkImage("https://i.pravatar.cc/300?u=mathew"),
                ),
              ),
              SizedBox(height: 30),
              // Email field with outline + inside icon right
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  hintText: 'Jhone Doe',
                  suffixIcon: Icon(IconlyLight.message, color: secondary),
                ),
                style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 20),

              // Email field with outline + inside icon right
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+62 112-3288-9111 ',
                  suffixIcon: Icon(IconlyLight.call, color: secondary),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 20),

              // Email field with outline + inside icon right
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'chetan@email.com',
                  suffixIcon: Icon(IconlyLight.message, color: secondary),
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              Spacer(),
              // Login button
              Center(
                child: SizedBox(
                  width: 200,
                  height: 63,

                  child: ElevatedButton(
                    onPressed: () {
                      // Get.to(RegisterScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: const Color(0xFF8BD63A), // green
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
