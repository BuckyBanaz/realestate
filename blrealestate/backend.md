# Backend Developer Guide — Channel Partner App
## FCM Push Notifications Setup (Laravel PHP)

---

## What is this?
When admin creates a notification for a channel partner, the app should receive a push notification on their phone automatically.
Right now notifications are saved to DB but the phone doesn't receive them.
This guide fixes that.

---

## Step 1 — Copy the credentials file

Take this file from the Flutter project folder:
```
firebase-service-account.json
```

Copy it to your Laravel project at this exact path:
```
storage/app/firebase-credentials.json
```

---

## Step 2 — Install Firebase package

Open terminal in your Laravel project folder and run:
```bash
composer require kreait/firebase-php
```

Wait for it to finish. This installs the Firebase library.

---

## Step 3 — Create a helper file

Create a new file at this path in your Laravel project:
```
app/Helpers/FcmHelper.php
```

Paste this exact code inside:

```php
<?php

namespace App\Helpers;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FcmHelper
{
    /**
     * Send push notification to a channel partner's phone.
     *
     * @param string $fcmToken  — from channel_partners table, fcm_token column
     * @param string $title     — notification title
     * @param string $body      — notification message
     * @param array  $data      — optional extra data
     */
    public static function send(
        string $fcmToken,
        string $title,
        string $body,
        array $data = []
    ): void {
        try {
            $factory = (new Factory)
                ->withServiceAccount(storage_path('app/firebase-credentials.json'));

            $messaging = $factory->createMessaging();

            $message = CloudMessage::withTarget('token', $fcmToken)
                ->withNotification(Notification::create($title, $body))
                ->withData($data);

            $messaging->send($message);

        } catch (\Throwable $e) {
            // Don't crash — just log the error
            \Log::error('FCM push failed: ' . $e->getMessage());
        }
    }
}
```

---

## Step 4 — Use it when saving a notification

Find the place in your code where you save a notification to the database for a channel partner.

Add these lines **right after** saving to DB:

```php
use App\Helpers\FcmHelper;

// Get the channel partner
$partner = \App\Models\User::find($channelPartnerId);

// Send push if they have an FCM token
if ($partner && !empty($partner->fcm_token)) {
    FcmHelper::send(
        fcmToken: $partner->fcm_token,
        title:    $title,    // same title you saved to DB
        body:     $body,     // same body/message you saved to DB
        data:     ['type' => $type ?? 'admin']
    );
}
```

---

## Step 5 — Test it

1. Open the Channel Partner app on a phone and login
2. From admin panel, send a notification to that channel partner
3. The phone should receive the push notification immediately

---

## Important Notes

- The `fcm_token` is sent by the app every time the user logs in (via the verify-otp API)
- Always use the latest token from the database — it updates on every login
- If the token is empty or null, skip sending (the user hasn't logged in yet)
- Errors are logged to `storage/logs/laravel.log` — check there if push doesn't arrive

---

## Files Summary

| What | Where |
|------|-------|
| Credentials file | `storage/app/firebase-credentials.json` |
| Helper class | `app/Helpers/FcmHelper.php` |
| Call it | Wherever you save notifications to DB |

---

## That's it!
No Firebase account access needed. No extra configuration.
Just copy the 2 files and add 4 lines of code.
