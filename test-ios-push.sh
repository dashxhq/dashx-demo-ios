#!/bin/sh

TEAM_ID=AS5VW845N7
TOKEN_KEY_FILE_NAME=Keys/Staging_AuthKey_5F56DDLAM2.p8
AUTH_KEY_ID=5F56DDLAM2
TOPIC=com.dashxdemo.app
APNS_HOST_NAME=api.sandbox.push.apple.com

JWT_ISSUE_TIME=$(date +%s)
JWT_HEADER=$(printf '{ "alg": "ES256", "kid": "%s" }' "${AUTH_KEY_ID}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_CLAIMS=$(printf '{ "iss": "%s", "iat": %d }' "${TEAM_ID}" "${JWT_ISSUE_TIME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_HEADER_CLAIMS="${JWT_HEADER}.${JWT_CLAIMS}"
JWT_SIGNED_HEADER_CLAIMS=$(printf "${JWT_HEADER_CLAIMS}" | openssl dgst -binary -sha256 -sign "${TOKEN_KEY_FILE_NAME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
AUTHENTICATION_TOKEN="${JWT_HEADER}.${JWT_CLAIMS}.${JWT_SIGNED_HEADER_CLAIMS}"

DEVICE_TOKEN=11dcd2d3c94f326c28637993dd99deb493fdcf1ebfb5b5e6c54b818c6f536fc8

# PAYLOAD='{
#     "aps": {
#         "alert": {
#             "title": "Test Title 9",
#             "subtitle": "Test Subtitle",
#             "body": "Test Body"
#         },
#         "badge": 10,
#         "category": "GAME_INVITATION",
#         "thread-id": "thread2"
#     },
#     "test-key-1": "foo",
#     "dashx": "{\"id\":\"1\",\"title\":\"Testing 33\",\"body\":\"Really testing\"}"
# }'

# PAYLOAD='{
#     "aps": {
#         "content-available": 1
#     },
#     "test-key-1": "foo",
#     "dashx": "{\"id\":\"1\",\"title\":\"Testing 1\"}"
# }'

# PAYLOAD='{
#     "aps": {
#         "content-available": 1
#     },
#     "test-key-1": "foo",
#     "dashx": "{\"id\":\"1\",\"title\":\"Testing 22\",\"body\":\"Really testing\"}"
# }'

# PAYLOAD='{
#     "aps": {
#         "alert": {
#             "title": "Test Title 1",
#             "subtitle": "Test Subtitle",
#             "body": "Test Body"
#         },
#         "mutable-content": 1
#     },
#     "test-key-1": "foo",
#     "dashx": "{\"id\":\"1\",\"title\":\"Testing 33\",\"body\":\"Really testing\"}"
# }'

PAYLOAD='{
    "aps": {
        "content-available": 1,
        "mutable-content": 1
    },
    "test-key-1": "foo",
    "dashx": "{\"id\":\"1\",\"title\":\"Testing 24\",\"body\":\"Really testing\"}"
}'

# curl -v \
#     --header "apns-topic: $TOPIC" \
#     --header "apns-push-type: alert"\
#     --header "authorization: bearer $AUTHENTICATION_TOKEN" \
#     --data "$PAYLOAD" \
#     --http2 https://${APNS_HOST_NAME}/3/device/${DEVICE_TOKEN}

curl -v \
    --header "apns-topic: $TOPIC" \
    --header "apns-push-type: background"\
    --header "apns-priority: 10"\
    --header "authorization: bearer $AUTHENTICATION_TOKEN" \
    --data "$PAYLOAD" \
    --http2 https://${APNS_HOST_NAME}/3/device/${DEVICE_TOKEN}
