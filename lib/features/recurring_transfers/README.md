# Recurring/Scheduled Transfers Feature

## Overview
Allows users to schedule automatic recurring transfers (e.g., weekly allowance, monthly rent).

## File Structure

### Models (`models/`)
- `transfer_frequency.dart` - Enum for daily, weekly, biweekly, monthly
- `recurring_transfer_status.dart` - Enum for active, paused, completed, cancelled
- `recurring_transfer.dart` - Main transfer model with all details
- `create_recurring_transfer_request.dart` - Request model for creation
- `update_recurring_transfer_request.dart` - Request model for updates
- `execution_history.dart` - Past execution records
- `upcoming_execution.dart` - Scheduled upcoming executions

### Service (`/lib/services/recurring_transfers/`)
- `recurring_transfers_service.dart` - API service for all operations
  - Get all transfers
  - Create/update/delete transfers
  - Pause/resume transfers
  - Get execution history
  - Get upcoming executions

### Providers (`providers/`)
- `recurring_transfers_provider.dart` - Main state management
  - List of transfers (active, paused, inactive)
  - Detail provider for single transfer with history
- `create_recurring_transfer_provider.dart` - Form state for creation/editing

### Views (`views/`)
- `recurring_transfers_list_view.dart` - Main list screen with:
  - Upcoming executions this week
  - Active transfers section
  - Paused transfers section
  - Empty state
  - FAB to create new

- `create_recurring_transfer_view.dart` - Creation form with:
  - Recipient selection (from beneficiaries or manual)
  - Amount input
  - Frequency picker (daily, weekly, biweekly, monthly)
  - Start date picker
  - End condition (never, after X times, until date)
  - Optional note

- `recurring_transfer_detail_view.dart` - Detail screen with:
  - Full transfer details
  - Next 3 scheduled dates
  - Statistics (executed count, remaining)
  - Execution history list
  - Pause/Resume/Cancel actions

### Widgets (`widgets/`)
- `recurring_transfer_card.dart` - Card component for list
- `frequency_picker.dart` - Frequency selection UI
- `end_condition_picker.dart` - End condition selection UI
- `execution_history_list.dart` - History list component

### Mock Data (`/lib/mocks/services/recurring_transfers/`)
- `recurring_transfers_mock.dart` - Mock API responses with 3 sample transfers

## Routes
- `/recurring-transfers` - List view
- `/recurring-transfers/create` - Create new
- `/recurring-transfers/detail/:id` - Detail view
- `/recurring-transfers/edit/:id` - Edit (uses create view with prefill)

## Localization
All strings added to:
- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_fr.arb` - French translations

Key prefixes: `recurringTransfers_*`

## Usage Examples

### Navigate to list
```dart
context.push('/recurring-transfers');
```

### Create from send success screen
```dart
context.push('/recurring-transfers/create?phone=$phone&name=$name&amount=$amount');
```

### View transfer details
```dart
context.push('/recurring-transfers/detail/$transferId');
```

## API Endpoints (Expected Backend)
- `GET /recurring-transfers` - List all
- `POST /recurring-transfers` - Create new
- `GET /recurring-transfers/:id` - Get single
- `PATCH /recurring-transfers/:id` - Update
- `POST /recurring-transfers/:id/pause` - Pause
- `POST /recurring-transfers/:id/resume` - Resume
- `DELETE /recurring-transfers/:id` - Cancel
- `GET /recurring-transfers/:id/history` - Get execution history
- `GET /recurring-transfers/upcoming` - Get upcoming (next 7 days)
- `GET /recurring-transfers/:id/next-dates` - Get next X dates

## Features
- [x] Create recurring transfers with flexible schedules
- [x] Support for daily, weekly, biweekly, monthly frequencies
- [x] Flexible end conditions (never, after X times, until date)
- [x] Pause/resume transfers
- [x] View execution history
- [x] See upcoming scheduled transfers
- [x] Cancel with confirmation
- [x] Status badges (active, paused, completed, cancelled)
- [x] Bilingual support (English/French)
- [x] Mock data for testing
- [x] Integration with existing beneficiaries

## Future Enhancements
- [ ] Edit recurring transfer details
- [ ] Skip next execution
- [ ] Retry failed executions
- [ ] Notifications before execution
- [ ] Transaction history integration (show recurring indicator)
- [ ] Home screen badge for upcoming transfers
- [ ] "Make Recurring" option in send success screen
