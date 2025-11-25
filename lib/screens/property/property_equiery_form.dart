// ADD THIS IMPORT AT TOP (if not already)
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:iconly/iconly.dart';
import 'package:realestate/screens/property/plot_selection_screen.dart';

import '../../constant/app_colors.dart';

// ADD THIS FULL FORM SCREEN AFTER YOUR PropertyDetailScreen CLASS
class EnquiryFormScreen extends StatefulWidget {
  final String propertyName;
  // final String propertyPrice;
  final String propertyLocation;

  const EnquiryFormScreen({
    Key? key,
    required this.propertyName,
    // required this.propertyPrice,
    required this.propertyLocation,
  }) : super(key: key);

  @override
  State<EnquiryFormScreen> createState() => _EnquiryFormScreenState();
}

class _EnquiryFormScreenState extends State<EnquiryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitEnquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Get.snackbar(
    //   "Success!",
    //   "Your enquiry has been sent successfully.",
    //   backgroundColor: Colors.green,
    //   colorText: Colors.white,
    //   snackPosition: SnackPosition.BOTTOM,
    //   margin: EdgeInsets.all(16),
    //   borderRadius: 12,
    // );

    Get.back(); // Close form
  }

  String? _selectedPlot; // Add this line at the top of _EnquiryFormScreenState
  // ADD THIS INSIDE _EnquiryFormScreenState class, just after "Your Details" title
  String? _selectedPlotSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Submit Enquiry",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Preview Card (same as before)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.propertyName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // SizedBox(height: 6),
                    // Text(widget.propertyPrice, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primary)),
                    SizedBox(height: 4),
                    Text(
                      "You Selected Plot No. 106 ",
                      style: TextStyle(fontSize: 18),
                    ),

                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          IconlyLight.location,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Text(
                          widget.propertyLocation,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28),

              // // Show warning if no plot selected
              // if (_selectedPlot == null)
              //   Padding(
              //     padding: EdgeInsets.only(top: 8),
              //     child: Text(
              //       "Please select a plot to continue",
              //       style: TextStyle(color: Colors.red[600], fontSize: 13),
              //     ),
              //   ),
              Text(
                "Kindly Provide Your Details We Will Be in Touch !",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Name, Phone, Email, Message (same as before)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Full Name",
                  fillColor: cardColor,
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.trim().isEmpty ? "Name is required" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  fillColor: cardColor,
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) {
                  if (v!.isEmpty) return "Phone is required";
                  if (v.length < 10) return "Enter valid 10-digit number";
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email (Optional)",
                  fillColor: cardColor,
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none
                  ),

                ),
                validator: (v) => v!.isNotEmpty && !GetUtils.isEmail(v)
                    ? "Enter valid email"
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                maxLines: 4,

                decoration: InputDecoration(

                  fillColor: cardColor,
                  labelText: "Message (Optional)",
                  hintText: "I'm interested in this property...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: grey,width: 2)
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Submit Button with Plot Validation
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          _submitEnquiry();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Send Enquiry",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ADD THIS METHOD inside _EnquiryFormScreenState class
  Widget _plotChip(String plotNo, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlot = plotNo;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          plotNo,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
