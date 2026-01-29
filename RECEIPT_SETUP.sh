#!/bin/bash

# Receipt Feature Setup Script
# Run this script to complete the receipt sharing feature setup

echo "📝 Setting up Receipt Sharing Feature..."
echo ""

# Step 1: Merge localization files
echo "1️⃣ Merging localization strings..."

# Backup original files
cp lib/l10n/app_en.arb lib/l10n/app_en.arb.backup
cp lib/l10n/app_fr.arb lib/l10n/app_fr.arb.backup

# Remove closing brace from English file
head -n -1 lib/l10n/app_en.arb > lib/l10n/app_en.arb.tmp

# Add receipt strings to English
cat >> lib/l10n/app_en.arb.tmp << 'EOF'
,

  "receipt_shareReceipt": "Share Receipt",
  "@receipt_shareReceipt": {
    "description": "Share receipt title"
  },

  "receipt_shareViaWhatsApp": "Share via WhatsApp",
  "@receipt_shareViaWhatsApp": {
    "description": "Share via WhatsApp option"
  },

  "receipt_shareViaWhatsAppSubtitle": "Send receipt to WhatsApp contact",
  "@receipt_shareViaWhatsAppSubtitle": {
    "description": "Share via WhatsApp subtitle"
  },

  "receipt_shareAsImage": "Share as Image",
  "@receipt_shareAsImage": {
    "description": "Share as image option"
  },

  "receipt_shareAsImageSubtitle": "Share via any app",
  "@receipt_shareAsImageSubtitle": {
    "description": "Share as image subtitle"
  },

  "receipt_shareAsPdf": "Share as PDF",
  "@receipt_shareAsPdf": {
    "description": "Share as PDF option"
  },

  "receipt_shareAsPdfSubtitle": "Professional PDF document",
  "@receipt_shareAsPdfSubtitle": {
    "description": "Share as PDF subtitle"
  },

  "receipt_saveToGallery": "Save to Gallery",
  "@receipt_saveToGallery": {
    "description": "Save to gallery option"
  },

  "receipt_saveToGallerySubtitle": "Save receipt image to photos",
  "@receipt_saveToGallerySubtitle": {
    "description": "Save to gallery subtitle"
  },

  "receipt_emailReceipt": "Email Receipt",
  "@receipt_emailReceipt": {
    "description": "Email receipt option"
  },

  "receipt_emailReceiptSubtitle": "Send via email",
  "@receipt_emailReceiptSubtitle": {
    "description": "Email receipt subtitle"
  },

  "receipt_copyReference": "Copy Reference Number",
  "@receipt_copyReference": {
    "description": "Copy reference option"
  },

  "receipt_openingWhatsApp": "Opening WhatsApp...",
  "@receipt_openingWhatsApp": {
    "description": "Opening WhatsApp loading message"
  },

  "receipt_generatingImage": "Generating image...",
  "@receipt_generatingImage": {
    "description": "Generating image loading message"
  },

  "receipt_generatingPdf": "Generating PDF...",
  "@receipt_generatingPdf": {
    "description": "Generating PDF loading message"
  },

  "receipt_openingEmail": "Opening email...",
  "@receipt_openingEmail": {
    "description": "Opening email loading message"
  },

  "receipt_whatsAppNotInstalled": "WhatsApp is not installed",
  "@receipt_whatsAppNotInstalled": {
    "description": "WhatsApp not installed error"
  },

  "receipt_errorSharing": "Failed to share receipt",
  "@receipt_errorSharing": {
    "description": "Error sharing receipt"
  },

  "receipt_errorSaving": "Failed to save receipt",
  "@receipt_errorSaving": {
    "description": "Error saving receipt"
  },

  "receipt_errorOpeningEmail": "Failed to open email app",
  "@receipt_errorOpeningEmail": {
    "description": "Error opening email"
  },

  "receipt_savedToGallery": "Receipt saved to gallery",
  "@receipt_savedToGallery": {
    "description": "Receipt saved success message"
  },

  "receipt_referenceCopied": "Reference number copied",
  "@receipt_referenceCopied": {
    "description": "Reference copied success message"
  },

  "receipt_enterEmail": "Enter Email Address",
  "@receipt_enterEmail": {
    "description": "Enter email dialog title"
  },

  "receipt_emailAddress": "Email Address",
  "@receipt_emailAddress": {
    "description": "Email address input label"
  }
}
EOF

mv lib/l10n/app_en.arb.tmp lib/l10n/app_en.arb

# Remove closing brace from French file
head -n -1 lib/l10n/app_fr.arb > lib/l10n/app_fr.arb.tmp

# Add receipt strings to French
cat >> lib/l10n/app_fr.arb.tmp << 'EOF'
,

  "receipt_shareReceipt": "Partager le reçu",
  "receipt_shareViaWhatsApp": "Partager via WhatsApp",
  "receipt_shareViaWhatsAppSubtitle": "Envoyer le reçu à un contact WhatsApp",
  "receipt_shareAsImage": "Partager comme image",
  "receipt_shareAsImageSubtitle": "Partager via n'importe quelle application",
  "receipt_shareAsPdf": "Partager comme PDF",
  "receipt_shareAsPdfSubtitle": "Document PDF professionnel",
  "receipt_saveToGallery": "Enregistrer dans la galerie",
  "receipt_saveToGallerySubtitle": "Enregistrer l'image du reçu dans les photos",
  "receipt_emailReceipt": "Envoyer le reçu par e-mail",
  "receipt_emailReceiptSubtitle": "Envoyer par e-mail",
  "receipt_copyReference": "Copier le numéro de référence",
  "receipt_openingWhatsApp": "Ouverture de WhatsApp...",
  "receipt_generatingImage": "Génération de l'image...",
  "receipt_generatingPdf": "Génération du PDF...",
  "receipt_openingEmail": "Ouverture de l'e-mail...",
  "receipt_whatsAppNotInstalled": "WhatsApp n'est pas installé",
  "receipt_errorSharing": "Échec du partage du reçu",
  "receipt_errorSaving": "Échec de l'enregistrement du reçu",
  "receipt_errorOpeningEmail": "Échec de l'ouverture de l'application e-mail",
  "receipt_savedToGallery": "Reçu enregistré dans la galerie",
  "receipt_referenceCopied": "Numéro de référence copié",
  "receipt_enterEmail": "Entrer l'adresse e-mail",
  "receipt_emailAddress": "Adresse e-mail"
}
EOF

mv lib/l10n/app_fr.arb.tmp lib/l10n/app_fr.arb

echo "✅ Localization files merged"
echo ""

# Step 2: Clean up temporary files
echo "2️⃣ Cleaning up temporary files..."
rm -f lib/l10n/app_en_receipt.arb
rm -f lib/l10n/app_fr_receipt.arb
echo "✅ Cleanup complete"
echo ""

# Step 3: Install dependencies
echo "3️⃣ Installing dependencies..."
flutter pub get
echo "✅ Dependencies installed"
echo ""

# Step 4: Generate localizations
echo "4️⃣ Generating localizations..."
flutter gen-l10n
echo "✅ Localizations generated"
echo ""

# Step 5: Run code analysis
echo "5️⃣ Running code analysis..."
flutter analyze lib/features/receipts/
echo "✅ Analysis complete"
echo ""

echo "🎉 Receipt Sharing Feature Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Test the feature: flutter run"
echo "2. Navigate to a transaction detail screen"
echo "3. Tap the share icon to test receipt sharing"
echo ""
echo "Integration guide: lib/features/receipts/INTEGRATION_GUIDE.md"
echo "Feature docs: lib/features/receipts/README.md"
echo ""
echo "Restore backups if needed:"
echo "  mv lib/l10n/app_en.arb.backup lib/l10n/app_en.arb"
echo "  mv lib/l10n/app_fr.arb.backup lib/l10n/app_fr.arb"
