# NOTES

## Level 1: what the wire looks like

GET /users returns 200 and a JSON list of 10 users. GET /users/1 returns 200 and one object. Content-Type: application/json; charset=utf-8.

Nested objects: `address` and `company`. `address.geo` is nested twice (user -> address -> geo). Every value in the response is present, so nothing is null in the real data. I treat only `website` as optional (String?).

User:

| field | JSON type | Dart type | nullable? |
| --- | --- | --- | --- |
| id | number | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| address | object | Address | no |
| phone | string | String | no |
| website | string | String? | yes (the only optional field I allow) |
| company | object | record (name, catchPhrase) | no |

Address:

| field | JSON type | Dart type | nullable? |
| --- | --- | --- | --- |
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object | Geo | no |

Geo (nested twice, address.geo). The server sends numbers as strings, for example "-37.3159":

| field | JSON type | Dart type | nullable? |
| --- | --- | --- | --- |
| lat | string | double (double.parse) | no |
| lng | string | double (double.parse) | no |

Company: `name` and `catchPhrase` are strings and are kept in the record. `bs` is a string that the app ignores.

## Level 1: statuses

- GET /users/999: 404 Not Found, body `{}` (2 bytes). The repository maps it to NotFoundException.
- POST /users with a JSON body and Content-Type: application/json: 201 Created. The server returns what I sent plus `"id": 11` (and a `location` header with /users/11). It adds nothing else.
- GET /users?id=3: 200, the answer is a list with one object, not an object.

## Level 5: two kinds of "no network"

- Airplane mode: the Offline view appeared in about 1 second. The OS knows there is no route, so SocketException is immediate.
- Wi-Fi without internet (simulated with the host 10.255.255.1, packets leave and never return): the Offline view appeared after about 10 seconds. That is the 10-second timeout in ApiClient._send; without it the spinner would spin for minutes.

Both cases end in the same screen (NoConnectionException -> Offline with Retry).