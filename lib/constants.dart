import '/model/CurrencyModel.dart';

const FINISHED_ON_BOARDING = 'finishedOnBoarding';
const COLOR_ACCENT = 0xFF8fd468;
const COLOR_PRIMARY_DARK = 0x00B761;
const COLOR_PRIMARY = 0xFF00B761;
const FACEBOOK_BUTTON_COLOR = 0xFF415893;
const DARK_COLOR = 0xff191A1C;
const COUPON_BG_COLOR=0xFFFCF8F3;
const COUPON_DASH_COLOR=0xFFCACFDA;
const GREY_TEXT_COLOR=0xff5E5C5C;





const USERS = 'users';
const CHANNEL_PARTICIPATION = 'channel_participation';
const CHANNELS = 'channels';
const THREAD = 'thread';
const REPORTS = 'reports';
const Deliverycharge =6;
const CATEGORIES = 'vendor_categories';
const VENDORS = 'vendors';
const PRODUCTS = 'vendor_products';
const ORDERS = 'vendor_orders';
const COUPONS = "coupons";
const SECOND_MILLIS = 1000;
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const HOUR_MILLIS = 60 * MINUTE_MILLIS;
const SERVER_KEY =
    'Server key';
const GOOGLE_API_KEY = 'API key';

const ORDER_STATUS_PLACED = 'Order Placed';
const ORDER_STATUS_ACCEPTED = 'Order Accepted';
const ORDER_STATUS_REJECTED = 'Order Rejected';
const ORDER_STATUS_DRIVER_PENDING = 'Driver Pending';
const ORDER_STATUS_DRIVER_REJECTED = 'Driver Rejected';
const ORDER_STATUS_SHIPPED = 'Order Shipped';
const ORDER_STATUS_IN_TRANSIT = 'In Transit';
const ORDER_STATUS_COMPLETED = 'Order Completed';

const STRIPE_CURRENCY_CODE = 'USD';
const PAYMENT_SERVER_URL = '';

const STRIPE_PUBLISHABLE_KEY =
    '';

const USER_ROLE_DRIVER = 'driver';
const USER_ROLE_CUSTOMER = 'customer';
const VENDORS_CATEGORIES = 'vendor_categories';
const Order_Rating = 'items_review';
const COUPON = 'coupons';
const Wallet = "wallet";

const Setting = 'settings';
const StripeSetting = 'stripeSettings';
const FavouriteStore="favorite_vendor";

const COD = 'CODSettings';


const GlobalURL = "Host Url";

const Currency = 'currencies';
String symbol = '';
bool isRight = false;
int decimal = 0;
String currName = "";
CurrencyModel? currencyData;

bool isRazorPayEnabled = false;
bool isRazorPaySandboxEnabled = false;
String razorpayKey = "";
String razorpaySecret = "";

String placeholderImage = '';

double getDoubleVal(dynamic input) {
  if(input==null){
    return 0.1;
  }

  if(input is int){
    return double.parse(input.toString());
  }

  if(input is double){
    return input;
  }
  return 0.1;
}

