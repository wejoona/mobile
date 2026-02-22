/// Convert a dollar/unit amount to cents (smallest unit) for the backend.
/// Backend expects amounts in cents (e.g., $50.00 → 5000).
int toCents(double amount) => (amount * 100).round();

/// Convert cents from backend to dollar amount for display.
double fromCents(int cents) => cents / 100.0;
