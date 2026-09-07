import '../config/app_config.dart';

class ApiEndpoints {
  static const String baseUrl = AppConfig.apiBaseUrl;


  // ── Auth (confirmed in swagger) ──────────────────────────────────────────
  // POST  /ChannelPartner/send-otp      body: {mobile}
  // POST  /ChannelPartner/verify-otp    body: {mobile, otp, fcm_token?}
  // POST  /ChannelPartner/logout        bearer required
  static const String sendOtp   = '/ChannelPartner/send-otp';
  static const String verifyOtp = '/ChannelPartner/verify-otp';
  static const String logout    = '/ChannelPartner/logout';

  // ── Profile & Dashboard (confirmed in swagger) ───────────────────────────
  // GET   /ChannelPartner/profile     bearer required
  // POST  /ChannelPartner/profile     bearer required — update profile
  // GET   /ChannelPartner/dashboard   bearer required
  static const String profile       = '/ChannelPartner/profile';
  static const String updateProfile = '/ChannelPartner/profile/update';
  static const String stats         = '/ChannelPartner/dashboard';

  // ── Inventory (confirmed in swagger) ─────────────────────────────────────
  // GET  /ChannelPartner/properties   bearer required
  //      response: {status, message, data:[{id,title,price,main_image,attributes{},amenities[]}]}
  // POST /ChannelPartner/properties/{id}/hold  ← PENDING backend implementation
  //      body: {property_id}
  static const String inventory = '/ChannelPartner/properties';
  static String propertyDetail(int id) => '/property/$id';
  static String holdProperty(int id) => '/ChannelPartner/properties/$id/hold';

  // ── Leads ────────────────────────────────────────────────────────────────
  // GET   /ChannelPartner/leads              bearer required
  // POST  /ChannelPartner/leads              bearer required
  //       body: {name, mobile, address, property_id, paid_amount, balance_amount, advance_amount, appointment_date}
  // PATCH /ChannelPartner/leads/{id}/status  bearer required
  //       body: {status}  values: new|seen|contacted|proposal|negotiation|closed
  static const String leads = '/ChannelPartner/leads';
  static String leadStatus(int id) => '/ChannelPartner/leads/$id/status';

  // ── Documents ─────────────────────────────────────────────────────────────
  // POST /ChannelPartner/properties/documents  bearer required, multipart/form-data
  //      body: {document: File, document_type: string}
  // GET  /ChannelPartner/properties/documents  bearer required
  static const String documents = '/ChannelPartner/properties/documents';

  // ── Tasks (confirmed in swagger) ─────────────────────────────────────────
  // GET  /ChannelPartner/tasks   bearer required
  // POST /ChannelPartner/tasks/{id}/status  ← PENDING backend implementation
  //      body: {status}  values: pending|in_progress|completed
  static const String tasks = '/ChannelPartner/tasks';
  static String taskStatus(int id) => '/ChannelPartner/tasks/$id/status';

  // ── Commissions (confirmed in swagger) ───────────────────────────────────
  // GET /ChannelPartner/commissions   bearer required
  static const String commissions = '/ChannelPartner/commissions';

  // ── Deals (confirmed in swagger) ─────────────────────────────────────────
  // GET /ChannelPartner/deals   bearer required
  static const String deals = '/ChannelPartner/deals';

  // ── Notifications ──────────────────────────────────────────────────────────
  // GET /ChannelPartner/notifications   bearer required
  // response: {status, message, data:[{id,title,body,type,is_read,created_at}]}
  static const String notifications = '/ChannelPartner/notifications';

  // ── Categories ────────────────────────────────────────────────────────────
  // GET /categories   no auth required
  // response: {status, message, data:[{id, name, children:[...]}]}
  static const String categories = '/categories';
}
