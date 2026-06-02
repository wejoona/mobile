/// Convert a dollar/unit amount to cents for endpoints that explicitly use
/// minor units, such as withdrawals.
int toCents(double amount) => (amount * 100).round();

/// Convert cents from backend to dollar amount for display.
double fromCents(int cents) => cents / 100.0;
