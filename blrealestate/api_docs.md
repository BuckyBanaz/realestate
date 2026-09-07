# Channel Partner API Documentation

Generated from http://108.181.185.27/blapis/docs?api-docs.json

## Send OTP to Channel Partner
- **Route**: `/ChannelPartner/send-otp`
- **Method**: `POST`

### Request Body
- **MIME Type**: `application/json`
```json
{
  "mobile": string,
}
```

### Responses
#### 200 - OTP sent successfully
#### 422 - Validation error
#### 404 - Channel Partner not found

---

## Verify OTP and Login
- **Route**: `/ChannelPartner/verify-otp`
- **Method**: `POST`

### Request Body
- **MIME Type**: `application/json`
```json
{
  "mobile": string,
  "otp": string,
  "fcm_token": string,
}
```

### Responses
#### 200 - Login successful
#### 401 - Invalid or expired OTP
#### 403 - Unauthorized

---

## Get Channel Partner Dashboard Statistics
- **Route**: `/ChannelPartner/dashboard`
- **Method**: `GET`

### Responses
#### 200 - Dashboard data fetched successfully

---

## Get All Active Properties
- **Route**: `/ChannelPartner/properties`
- **Method**: `GET`

### Responses
#### 200 - Properties fetched successfully
```json
{
  "status": boolean,
  "message": string,
  "data": List<{
  "id": integer,
  "title": string,
  "price": number,
  "main_image": string,
  "attributes": object,
  "amenities": List<{
  "id": integer,
  "title": string,
  "icon": string,
}>,
}>,
}
```

---

## Get Deals for Assigned Inventory
- **Route**: `/ChannelPartner/deals`
- **Method**: `GET`

### Responses
#### 200 - Deals fetched successfully

---

## Get Earned Commissions
- **Route**: `/ChannelPartner/commissions`
- **Method**: `GET`

### Responses
#### 200 - Commissions fetched successfully

---

## Get Assigned Tasks
- **Route**: `/ChannelPartner/tasks`
- **Method**: `GET`

### Responses
#### 200 - Tasks fetched successfully

---

## Get Assigned Leads
- **Route**: `/ChannelPartner/leads`
- **Method**: `GET`

### Responses
#### 200 - Leads fetched successfully

---

## Get Channel Partner Profile
- **Route**: `/ChannelPartner/profile`
- **Method**: `GET`

### Responses
#### 200 - Profile fetched successfully
#### 401 - Unauthorized

---

## Channel Partner Logout
- **Route**: `/ChannelPartner/logout`
- **Method**: `POST`

### Responses
#### 200 - Logged out successfully

---

