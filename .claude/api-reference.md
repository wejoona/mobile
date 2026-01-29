# API Reference

> Endpoint definitions. Don't explore backend unless needed.

## Base URL
- Dev: `https://api-dev.joonapay.com`
- Prod: `https://api.joonapay.com`

## Auth Endpoints

### POST /auth/register
```json
Request: { "phone": "+2250123456789", "countryCode": "CI" }
Response: { "userId": "uuid", "otpSent": true }
```

### POST /auth/verify-otp
```json
Request: { "phone": "+2250123456789", "otp": "123456" }
Response: { "accessToken": "jwt", "refreshToken": "jwt", "user": {...} }
```

### POST /auth/refresh
```json
Request: { "refreshToken": "jwt" }
Response: { "accessToken": "jwt", "refreshToken": "jwt" }
```

### POST /auth/logout
```json
Request: {} (with Authorization header)
Response: { "success": true }
```

## Wallet Endpoints

### GET /wallet
```json
Response: {
  "id": "uuid",
  "balance": "1000.00",
  "currency": "USDC",
  "status": "active"
}
```

### GET /wallet/transactions
```json
Query: ?limit=20&offset=0&type=all
Response: {
  "transactions": [
    {
      "id": "uuid",
      "type": "deposit|withdrawal|transfer",
      "amount": "100.00",
      "status": "completed|pending|failed",
      "createdAt": "2024-01-01T00:00:00Z",
      "recipient": {...},
      "sender": {...}
    }
  ],
  "total": 100,
  "hasMore": true
}
```

### GET /wallet/transaction/:id
```json
Response: { "id": "uuid", "type": "...", ... }
```

## Transfer Endpoints

### POST /transfers/internal
```json
Request: {
  "recipientPhone": "+2250123456789",
  "amount": "100.00",
  "note": "optional note",
  "pinToken": "jwt"
}
Response: { "transactionId": "uuid", "status": "completed" }
```

### POST /transfers/external
```json
Request: {
  "address": "0x...",
  "network": "base",
  "amount": "100.00",
  "pinToken": "jwt"
}
Response: { "transactionId": "uuid", "status": "pending" }
```

### POST /transfers/mobile-money
```json
Request: {
  "provider": "orange_money|mtn|wave",
  "phone": "+2250123456789",
  "amount": "50000",
  "currency": "XOF",
  "pinToken": "jwt"
}
Response: { "transactionId": "uuid", "status": "pending" }
```

## Deposit Endpoints

### POST /deposits/mobile-money
```json
Request: {
  "provider": "orange_money|mtn|wave",
  "amount": "50000",
  "currency": "XOF"
}
Response: {
  "transactionId": "uuid",
  "paymentUrl": "https://...",
  "expiresAt": "2024-01-01T00:00:00Z"
}
```

## PIN Endpoints

### POST /wallet/pin/set
```json
Request: { "pin": "hashed_pin" }
Response: { "success": true }
```

### POST /wallet/pin/verify
```json
Request: { "pin": "hashed_pin" }
Response: {
  "valid": true,
  "pinToken": "jwt",
  "expiresIn": 300
}
```

### POST /wallet/pin/change
```json
Request: { "currentPin": "hashed", "newPin": "hashed" }
Response: { "success": true }
```

## KYC Endpoints

### GET /kyc/status
```json
Response: {
  "status": "none|pending|approved|rejected",
  "tier": 0|1|2|3,
  "limits": { "daily": "1000", "monthly": "10000" }
}
```

### POST /kyc/submit
```json
Request: {
  "firstName": "Amadou",
  "lastName": "Diallo",
  "dateOfBirth": "1990-01-01",
  "documentType": "national_id|passport",
  "documentNumber": "ABC123"
}
Response: { "kycId": "uuid", "status": "pending" }
```

### POST /kyc/documents
```json
Request: FormData with files: idFront, idBack, selfie
Response: { "uploaded": true }
```

## User Endpoints

### GET /users/me
```json
Response: {
  "id": "uuid",
  "phone": "+2250123456789",
  "firstName": "Amadou",
  "lastName": "Diallo",
  "email": "amadou@example.com",
  "kycStatus": "approved"
}
```

### PATCH /users/me
```json
Request: { "firstName": "New", "email": "new@example.com" }
Response: { "id": "uuid", ... }
```

## Recipients Endpoints

### GET /recipients
```json
Response: {
  "recipients": [
    {
      "id": "uuid",
      "name": "Fatou Traore",
      "phone": "+2250987654321",
      "type": "internal|external",
      "address": "0x..." // if external
    }
  ]
}
```

### POST /recipients
```json
Request: { "phone": "+2250987654321" } // or { "address": "0x..." }
Response: { "id": "uuid", "name": "...", ... }
```

## Error Responses
```json
{
  "statusCode": 400,
  "message": "Error message",
  "error": "Bad Request"
}
```

### Common Error Codes
- 400: Bad Request (validation failed)
- 401: Unauthorized (token invalid/expired)
- 403: Forbidden (insufficient permissions)
- 404: Not Found
- 429: Too Many Requests (rate limited)
- 500: Internal Server Error
