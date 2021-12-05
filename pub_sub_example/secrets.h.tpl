#include <pgmspace.h>

#define SECRET
#define THING_NAME "${thing_name}"

const char WIFI_SSID[]        = "${wifi_ssid}";
const char WIFI_PASSWORD[]    = "${wifi_password}";
const char AWS_IOT_ENDPOINT[] = "${iot_endpoint}";

// Device Certificate
static const char AWS_CERT_CRT[] PROGMEM = R"KEY(
${device_certificate}
)KEY";

// Device Private Key
static const char AWS_CERT_PRIVATE[] PROGMEM = R"KEY(
${private_key}
)KEY";

// Amazon Root CA 1
static const char AWS_CERT_CA[] PROGMEM = R"EOF(
${ca_cert}
)EOF";
