# Auto Batching Public API Endpoints

## Authentication

All endpoints require authentication via one of:
- **Merchant API Key** (`merchantApiKeyStrategy`)
- **Access Token** (`accessTokenStrategy`)
- **Firebase Token** (`firebaseTokenStrategy`)
- **Internal API Key** (`internalApiKeyStrategy`)

Authorized roles: `Admin`, `Merchant`, `MerchantStaff`, `MerchantApi`, `internal-api-key`.

For Admin and internal-api-key callers, `merchantId` can be provided as a query parameter. For Merchant/MerchantStaff/MerchantApi callers, `merchantId` is derived from the authentication token.

All endpoints load the location and verify merchant ownership, returning 404 if the location is not found or does not belong to the authenticated merchant.

---

## Endpoints

All endpoints exist under both `/api/v1_0` and `/api/v2` with identical behavior unless noted.

---

### 1. Get Auto-Batch Settings

**`GET /locations/{locationId}/auto-batch/settings`**

Retrieves the auto-batch configuration and fulfillment slots for a merchant location.

#### Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `locationId` | string (UUID) | yes | Merchant location ID |

#### Query Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `merchantId` | string (UUID) | no | Required for Admin/internal-api-key callers |

#### Response `200 OK`

```json
{
  "data": {
    "locationId": "string (UUID)",
    "settings": {
      "autoBatchingEnabled": "boolean",
      "includeBatchPickupTimeShipments": "boolean",
      "includeDraftShipments": "boolean",
      "usePickupTimeStaggering": "boolean",
      "blackoutSchedule": {
        "blackoutDates": ["string (YYYY-MM-DD) or { start: string, end: string }"],
        "enabledHolidays": ["string"],
        "customHolidays": [
          {
            "id": "string",
            "name": "string",
            "monthDay": "string",
            "enabled": "boolean"
          }
        ]
      },
      "enableNextBusinessDayScheduling": "boolean"
    },
    "slots": [
      {
        "id": "string (UUID)",
        "weekday": "string (monday|tuesday|wednesday|thursday|friday|saturday|sunday)",
        "ordersPreparedBy": "string (HH:mm or 'just_in_time')",
        "preparationTimeValue": "integer",
        "preparationTimeUnit": "string (minutes|hours|days)",
        "keepShipmentsAsDrafts": "boolean",
        "enabled": "boolean",
        "sortIndex": "integer",
        "orderCutoffWeekday": "string (weekday name)",
        "orderCutoffTime": "string (HH:mm)"
      }
    ]
  }
}
```

#### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized - missing or invalid authentication |
| 404 | Location not found or does not belong to the merchant |
| 500 | Internal server error |

---

### 2. List Auto-Batch Runs

**`GET /locations/{locationId}/auto-batch/runs`**

Lists auto-batch runs for a location, grouped by day and slot. Supports viewing today's runs or a full week.

#### Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `locationId` | string (UUID) | yes | Merchant location ID |

#### Query Parameters

| Name | Type | Required | Default | Validation | Description |
|------|------|----------|---------|------------|-------------|
| `range` | string | yes | - | `today` or `week` | Time range to query |
| `weekStart` | string (YYYY-MM-DD) | conditional | - | Required when `range=week` | Start of the week to query |
| `page` | integer | no | 1 | 1–100000 | Page number (v2 auto-converts from string) |
| `pageSize` | integer | no | - | 1–200 | Page size (v2 auto-converts from string) |
| `merchantId` | string (UUID) | no | - | - | Required for Admin/internal-api-key callers |

#### Response `200 OK`

```json
{
  "data": {
    "locationId": "string (UUID)",
    "range": "string (today|week)",
    "weekStart": "string (YYYY-MM-DD) or null",
    "days": [
      {
        "off": "boolean",
        "runDate": "string (YYYY-MM-DD)",
        "weekday": "string",
        "slots": [
          {
            "fulfillmentSlotId": "string (UUID)",
            "weekday": "string",
            "ordersPreparedBy": "string (HH:mm or 'just_in_time')",
            "orderCutoffWeekday": "string",
            "orderCutoffTime": "string (HH:mm)",
            "status": "string (waiting|preparing|batching|completed|failed|skipped|disabled)",
            "nextRunAt": "string (ISO 8601 datetime) or null",
            "recentRun": null
          }
        ]
      }
    ]
  }
}
```

The `recentRun` field, when not null, has this shape:

```json
{
  "runId": "string (UUID)",
  "shipmentCount": "integer",
  "error": "string or null",
  "hasResults": "boolean",
  "createdAt": "string (ISO 8601 datetime)",
  "completedAt": "string (ISO 8601 datetime) or null"
}
```

**Slot status values:**
- `waiting` — run has not started yet
- `preparing` — run created, shipments being prepared
- `batching` — batch operation is in progress
- `completed` — run finished successfully
- `failed` — run encountered an error
- `skipped` — run was skipped (e.g. no shipments)
- `disabled` — slot is disabled

#### Error Responses

| Status | Description |
|--------|-------------|
| 400 | Invalid parameters (e.g. missing `weekStart` when `range=week`) |
| 401 | Unauthorized |
| 404 | Location not found or does not belong to the merchant |
| 500 | Internal server error |

---

### 3. Get Auto-Batch Run Detail

**`GET /locations/{locationId}/auto-batch/runs/{runId}`**

Retrieves details of a specific auto-batch run.

#### Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `locationId` | string (UUID) | yes | Merchant location ID |
| `runId` | string (UUID) | yes | Auto-batch run ID |

#### Query Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `merchantId` | string (UUID) | no | Required for Admin/internal-api-key callers |

#### Response `200 OK`

```json
{
  "data": {
    "locationId": "string (UUID)",
    "runId": "string (UUID)",
    "runDate": "string (YYYY-MM-DD)",
    "fulfillmentSlotId": "string (UUID)",
    "orderCutoffTime": "string (HH:mm)",
    "ordersPreparedByTime": "string (HH:mm)",
    "orderCutoffWeekday": "string",
    "readyWeekday": "string",
    "status": "string (preparing|batching|completed|failed|skipped)",
    "shipmentCount": "integer",
    "createdShipmentCount": "integer",
    "failedShipmentCount": "integer",
    "runError": "string or null",
    "completedAt": "string (ISO 8601 datetime) or null"
  }
}
```

#### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized |
| 404 | Location or run not found |
| 500 | Internal server error |

---

### 4. List Auto-Batch Run Created Shipments

**`GET /locations/{locationId}/auto-batch/runs/{runId}/created-shipments`**

Returns a paginated list of shipment IDs that were successfully created by an auto-batch run.

#### Path Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `locationId` | string (UUID) | yes | Merchant location ID |
| `runId` | string (UUID) | yes | Auto-batch run ID |

#### Query Parameters

| Name | Type | Required | Default | Validation | Description |
|------|------|----------|---------|------------|-------------|
| `page` | integer | no | 1 | 1–100000 | Page number |
| `pageSize` | integer | no | 50 | 1–200 | Results per page |
| `merchantId` | string (UUID) | no | - | - | Required for Admin/internal-api-key callers |

#### Response `200 OK`

```json
{
  "data": {
    "data": [
      {
        "shipmentId": "string"
      }
    ],
    "total": "integer",
    "page": "integer",
    "pageSize": "integer"
  }
}
```

#### Error Responses

| Status | Description |
|--------|-------------|
| 401 | Unauthorized |
| 404 | Location or run not found |
| 500 | Internal server error |

---

### 5. List Auto-Batch Run Failed Shipments

**`GET /locations/{locationId}/auto-batch/runs/{runId}/failed-shipments`**

Returns a paginated list of shipment IDs that failed during an auto-batch run.

#### Path Parameters

Same as created-shipments endpoint.

#### Query Parameters

Same as created-shipments endpoint (`page`, `pageSize`, `merchantId`).

#### Response `200 OK`

Same shape as created-shipments endpoint.

#### Error Responses

Same as created-shipments endpoint.

---

## Data Model Reference

### AutoBatchSettings

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `autoBatchingEnabled` | boolean | `false` | Whether auto-batching is active for this location |
| `includeBatchPickupTimeShipments` | boolean | `true` | Include shipments with batch pickup times |
| `includeDraftShipments` | boolean | `false` | Include draft shipments in auto-batch runs |
| `usePickupTimeStaggering` | boolean | `false` | Stagger pickup times across batches |
| `blackoutSchedule` | BlackoutSchedule | `{}` | Dates/holidays when auto-batching is paused |
| `enableNextBusinessDayScheduling` | boolean | `false` | Schedule runs for next business day |

### FulfillmentSlot

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Slot identifier |
| `weekday` | string | Day of week (monday–sunday) |
| `ordersPreparedBy` | string | Time orders must be prepared by (HH:mm) or `just_in_time` |
| `preparationTimeValue` | integer | Numeric preparation time |
| `preparationTimeUnit` | string | Unit: `minutes`, `hours`, or `days` |
| `keepShipmentsAsDrafts` | boolean | Keep created shipments as drafts |
| `enabled` | boolean | Whether this slot is active |
| `sortIndex` | integer | Display ordering |
| `orderCutoffWeekday` | string | Weekday of order cutoff |
| `orderCutoffTime` | string | Time of order cutoff (HH:mm) |

### AutoBatchRun

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Run identifier |
| `runDate` | string (YYYY-MM-DD) | Date the run is scheduled for |
| `fulfillmentSlotId` | UUID | Associated fulfillment slot |
| `orderCutoffTime` | string (HH:mm) | Order cutoff time snapshot |
| `ordersPreparedByTime` | string (HH:mm) | Prepared-by time snapshot |
| `orderCutoffWeekday` | string | Order cutoff weekday snapshot |
| `readyWeekday` | string | Ready weekday snapshot |
| `status` | string | `preparing`, `batching`, `completed`, `failed`, or `skipped` |
| `shipmentCount` | integer | Total shipments in run |
| `createdShipmentCount` | integer | Successfully created shipments |
| `failedShipmentCount` | integer | Failed shipments |
| `error` | string or null | Error message if run failed |
| `completedAt` | ISO 8601 datetime or null | When the run completed |

### Validation Constants

| Constant | Value |
|----------|-------|
| `MAX_SLOTS_PER_WEEKDAY` | 10 |
| `MIN_PREPARATION_TIME_MINUTES` | 45 |
| `SHIPMENT_READY_LATEST_TIME` | `17:00` |
| `VALID_WEEKDAYS` | `monday` through `sunday` |
| `VALID_PREPARATION_UNITS` | `minutes`, `hours`, `days` |
| Preparation time limits (minutes) | min: 45, max: 1440, increment: 15 |
| Preparation time limits (hours) | min: 1, max: 24 |
| Preparation time limits (days) | min: 1, max: 6 |

---

## Notes

- All five endpoints are **read-only** (GET). Write operations (upsert settings, trigger manual run) exist only in the internal API.
- The existing OpenAPI spec at `packages/system-tests/src/tests/v2/openapi.json` does not yet include any auto-batch paths.
- Both v1.0 and v2 expose identical auto-batch endpoints. The v2 versions use `numberParamsConverter` middleware to automatically convert string query parameters (`page`, `pageSize`) to integers.
