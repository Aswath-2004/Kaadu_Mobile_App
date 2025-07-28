// lib/screens/seller_details_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import UserAccount and BankDetails

class SellerDetailsScreen extends StatelessWidget {
  final UserAccount sellerAccount;

  const SellerDetailsScreen({super.key, required this.sellerAccount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${sellerAccount.name}\'s Store Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(sellerAccount.profileImageUrl),
                backgroundColor: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Text(
                sellerAccount.storeName ?? 'No Store Name Provided',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8.0),
            Center(
              child: Text(
                'Seller ID: ${sellerAccount.id}',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha((255 * 0.7).round())),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32.0),

            // Store Details Section
            Text(
              'Store Information',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            _buildInfoCard(context, 'Seller Name', sellerAccount.name,
                Icons.person_rounded),
            _buildInfoCard(
                context, 'Email', sellerAccount.email, Icons.email_rounded),
            _buildInfoCard(context, 'Phone Number', sellerAccount.phoneNumber,
                Icons.phone_rounded),
            const SizedBox(height: 16.0),
            // Display Store Address
            Text(
              'Store Address',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            _buildInfoCard(
                context,
                'Address Line 1',
                sellerAccount.sellerAddress1 ?? 'N/A',
                Icons.location_on_rounded),
            if (sellerAccount.sellerAddress2 != null &&
                sellerAccount.sellerAddress2!.isNotEmpty)
              _buildInfoCard(context, 'Address Line 2',
                  sellerAccount.sellerAddress2!, Icons.location_on_rounded),
            _buildInfoCard(context, 'City', sellerAccount.sellerCity ?? 'N/A',
                Icons.location_city_rounded),
            _buildInfoCard(context, 'State', sellerAccount.sellerState ?? 'N/A',
                Icons.map_rounded),
            _buildInfoCard(
                context,
                'Postal Code',
                sellerAccount.sellerPostalCode ?? 'N/A',
                Icons.local_post_office_rounded),
            const SizedBox(height: 32.0),

            // Bank Details Section
            Text(
              'Bank Details',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12.0),
            if (sellerAccount.bankDetails != null) ...[
              _buildInfoCard(
                  context,
                  'Bank Name',
                  sellerAccount.bankDetails!.bankName,
                  Icons.account_balance_rounded),
              _buildInfoCard(
                  context,
                  'Account Number',
                  sellerAccount.bankDetails!.accountNumber,
                  Icons.credit_card_rounded),
              _buildInfoCard(context, 'IFSC Code',
                  sellerAccount.bankDetails!.ifscCode, Icons.code_rounded),
              _buildInfoCard(
                  context,
                  'Account Holder',
                  sellerAccount.bankDetails!.accountHolderName,
                  Icons.person_rounded),
            ] else
              Text(
                'Bank details are not available.',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha((255 * 0.7).round())),
              ),
            const SizedBox(height: 32.0),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to BecomeSellerScreen for editing this seller's profile
                  Navigator.pushNamed(context, '/become_seller',
                      arguments: sellerAccount);
                },
                child: const Text('Edit Seller Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String label, String value, IconData icon) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5CB85C)),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha((255 * 0.7).round()),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
