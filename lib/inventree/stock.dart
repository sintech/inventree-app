import "dart:async";

import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:inventree/helpers.dart";
import "package:inventree/inventree/part.dart";
import "package:flutter/cupertino.dart";

import "package:inventree/inventree/model.dart";
import "package:inventree/l10.dart";

import "package:inventree/api.dart";


class InvenTreeStockItemTestResult extends InvenTreeModel {

  InvenTreeStockItemTestResult() : super();

  InvenTreeStockItemTestResult.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  @override
  String get URL => "stock/test/";

  @override
  Map<String, dynamic> formFields() {
    return {
      "stock_item": {
        "hidden": true
      },
      "test": {},
      "result": {},
      "value": {},
      "notes": {},
      "attachment": {},
    };
  }

  String get key => (jsondata["key"] ?? "") as String;

  String get testName => (jsondata["test"] ?? "") as String;

  bool get result => (jsondata["result"] ?? false) as bool;

  String get value => (jsondata["value"] ?? "") as String;

  String get attachment => (jsondata["attachment"] ?? "") as String;

  String get date => (jsondata["date"] ?? "") as String;

  @override
  InvenTreeStockItemTestResult createFromJson(Map<String, dynamic> json) {
    var result = InvenTreeStockItemTestResult.fromJson(json);
    return result;
  }

}


class InvenTreeStockItem extends InvenTreeModel {

  InvenTreeStockItem() : super();

  InvenTreeStockItem.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  // Stock status codes
  static const int OK = 10;
  static const int ATTENTION = 50;
  static const int DAMAGED = 55;
  static const int DESTROYED = 60;
  static const int REJECTED = 65;
  static const int LOST = 70;
  static const int RETURNED = 85;

  String statusLabel(BuildContext context) {

    // TODO: Delete me - The translated status values are provided by the API!

    switch (status) {
      case OK:
        return L10().ok;
      case ATTENTION:
        return L10().attention;
      case DAMAGED:
        return L10().damaged;
      case DESTROYED:
        return L10().destroyed;
      case REJECTED:
        return L10().rejected;
      case LOST:
        return L10().lost;
      case RETURNED:
        return L10().returned;
      default:
        return status.toString();
    }
  }

  // Return color associated with stock status
  Color get statusColor {
    switch (status) {
      case OK:
        return Colors.black;
      case ATTENTION:
        return Color(0xFFfdc82a);
      case DAMAGED:
      case DESTROYED:
      case REJECTED:
        return Color(0xFFe35a57);
      case LOST:
      default:
        return Color(0xFFAAAAAA);
    }
  }

  @override
  String get URL => "stock/";

  // URLs for performing stock actions

  static String transferStockUrl() => "stock/transfer/";

  static String countStockUrl() => "stock/count/";

  static String addStockUrl() => "stock/add/";

  static String removeStockUrl() => "stock/remove/";

  @override
  String get WEB_URL => "stock/item/";

  @override
  Map<String, dynamic> formFields() {
    return {
      "part": {},
      "location": {},
      "quantity": {},
      "status": {},
      "batch": {},
      "packaging": {},
      "link": {},
    };
  }

  @override
  Map<String, String> defaultGetFilters() {

    return {
      "part_detail": "true",
      "location_detail": "true",
      "supplier_detail": "true",
      "cascade": "false"
    };
  }

  @override
  Map<String, String> defaultListFilters() {

    return {
      "part_detail": "true",
      "location_detail": "true",
      "supplier_detail": "true",
      "cascade": "false",
      "in_stock": "true",
    };
  }

  List<InvenTreePartTestTemplate> testTemplates = [];

  int get testTemplateCount => testTemplates.length;

  // Get all the test templates associated with this StockItem
  Future<void> getTestTemplates({bool showDialog=false}) async {
    await InvenTreePartTestTemplate().list(
      filters: {
        "part": "${partId}",
      },
    ).then((var templates) {
      testTemplates.clear();

      for (var t in templates) {
        if (t is InvenTreePartTestTemplate) {
          testTemplates.add(t);
        }
      }
    });
  }

  List<InvenTreeStockItemTestResult> testResults = [];

  int get testResultCount => testResults.length;

  Future<void> getTestResults() async {

    await InvenTreeStockItemTestResult().list(
      filters: {
        "stock_item": "${pk}",
        "user_detail": "true",
      },
    ).then((var results) {
      testResults.clear();

      for (var r in results) {
        if (r is InvenTreeStockItemTestResult) {
          testResults.add(r);
        }
      }
    });
  }

  String get uid => (jsondata["uid"] ?? "") as String;

  int get status => (jsondata["status"] ?? -1) as int;

  String get packaging => (jsondata["packaging"] ?? "") as String;

  String get batch => (jsondata["batch"] ?? "") as String;

  int get partId => (jsondata["part"] ?? -1) as int;
  
  String get purchasePrice => (jsondata["purchase_price"] ?? "") as String;

  bool get hasPurchasePrice {

    String pp = purchasePrice;

    return pp.isNotEmpty && pp.trim() != "-";
  }

  int get purchaseOrderId => (jsondata["purchase_order"] ?? -1) as int;

  int get trackingItemCount => (jsondata["tracking_items"] ?? 0) as int;

  // Date of last update
  DateTime? get updatedDate {
    if (jsondata.containsKey("updated")) {
      return DateTime.tryParse((jsondata["updated"] ?? "") as String);
    } else {
      return null;
    }
  }

  String get updatedDateString {
    var _updated = updatedDate;

    if (_updated == null) {
      return "";
    }

    final DateFormat _format = DateFormat("yyyy-MM-dd");

    return _format.format(_updated);
  }

  DateTime? get stocktakeDate {
    if (jsondata.containsKey("stocktake_date")) {
      return DateTime.tryParse((jsondata["stocktake_date"] ?? "") as String);
    } else {
      return null;
    }
  }

  String get stocktakeDateString {
    var _stocktake = stocktakeDate;

    if (_stocktake == null) {
      return "";
    }

    final DateFormat _format = DateFormat("yyyy-MM-dd");

    return _format.format(_stocktake);
  }

  String get partName {

    String nm = "";

    // Use the detailed part information as priority
    if (jsondata.containsKey("part_detail")) {
      nm = (jsondata["part_detail"]["full_name"] ?? "") as String;
    }

    // Backup if first value fails
    if (nm.isEmpty) {
      nm = (jsondata["part__name"] ?? "") as String;
    }

    return nm;
  }

  String get partDescription {
    String desc = "";

    // Use the detailed part description as priority
    if (jsondata.containsKey("part_detail")) {
      desc = (jsondata["part_detail"]["description"] ?? "") as String;
    }

    if (desc.isEmpty) {
      desc = (jsondata["part__description"] ?? "") as String;
    }

    return desc;
  }

  String get partImage {
    String img = "";

    if (jsondata.containsKey("part_detail")) {
      img = (jsondata["part_detail"]["thumbnail"] ?? "") as String;
    }

    if (img.isEmpty) {
      img = (jsondata["part__thumbnail"] ?? "") as String;
    }

    return img;
  }

  /*
   * Return the Part thumbnail for this stock item.
   */
  String get partThumbnail {

    String thumb = "";

    thumb = (jsondata["part_detail"]?["thumbnail"] ?? "") as String;

    // Use "image" as a backup
    if (thumb.isEmpty) {
      thumb = (jsondata["part_detail"]?["image"] ?? "") as String;
    }

    // Try a different approach
    if (thumb.isEmpty) {
      thumb = (jsondata["part__thumbnail"] ?? "") as String;
    }

    // Still no thumbnail? Use the "no image" image
    if (thumb.isEmpty) thumb = InvenTreeAPI.staticThumb;

    return thumb;
  }

  int get supplierPartId => (jsondata["supplier_part"] ?? -1) as int;

  String get supplierImage {
    String thumb = "";

    if (jsondata.containsKey("supplier_detail")) {
      thumb = (jsondata["supplier_detail"]["supplier_logo"] ?? "") as String;
    }

    return thumb;
  }

  String get supplierName {
    String sname = "";

    if (jsondata.containsKey("supplier_detail")) {
      sname = (jsondata["supplier_detail"]["supplier_name"] ?? "") as String;
    }

    return sname;
  }

  String get units {
    return (jsondata["part_detail"]?["units"] ?? "") as String;
  }

  String get supplierSKU {
    String sku = "";

    if (jsondata.containsKey("supplier_detail")) {
      sku = (jsondata["supplier_detail"]["SKU"] ?? "") as String;
    }

    return sku;
  }

  String get serialNumber => (jsondata["serial"] ?? "") as String;

  double get quantity => double.tryParse(jsondata["quantity"].toString()) ?? 0;

  String quantityString({bool includeUnits = false}){

    String q = simpleNumberString(quantity);

    if (includeUnits && units.isNotEmpty) {
      q += " ${units}";
    }

    return q;
  }

  int get locationId => (jsondata["location"] ?? -1) as int;

  bool isSerialized() => serialNumber.isNotEmpty && quantity.toInt() == 1;

  String serialOrQuantityDisplay() {
    if (isSerialized()) {
      return "SN ${serialNumber}";
    }

    return simpleNumberString(quantity);
  }

  String get locationName {
    String loc = "";

    if (locationId == -1 || !jsondata.containsKey("location_detail")) return "Unknown Location";

    loc = (jsondata["location_detail"]["name"] ?? "") as String;

    // Old-style name
    if (loc.isEmpty) {
      loc = (jsondata["location__name"] ?? "") as String;
    }

    return loc;
  }

  String get locationPathString {

    if (locationId == -1 || !jsondata.containsKey("location_detail")) return L10().locationNotSet;

    String _loc = (jsondata["location_detail"]["pathstring"] ?? "") as String;

    if (_loc.isNotEmpty) {
      return _loc;
    } else {
      return locationName;
    }
  }

  String get displayQuantity {
    // Display either quantity or serial number!

    if (serialNumber.isNotEmpty) {
      return "SN: $serialNumber";
    } else {
      return simpleNumberString(quantity);
    }
  }

  @override
  InvenTreeModel createFromJson(Map<String, dynamic> json) {
    return InvenTreeStockItem.fromJson(json);
  }

  /*
   * Perform stocktake action:
   *
   * - Add
   * - Remove
   * - Count
   */
  // TODO: Remove this function when we deprecate support for the old API
  Future<bool> adjustStock(BuildContext context, String endpoint, double q, {String? notes, int? location}) async {

    // Serialized stock cannot be adjusted (unless it is a "transfer")
    if (isSerialized() && location == null) {
      return false;
    }

    // Cannot handle negative stock
    if (q < 0) {
      return false;
    }

    Map<String, dynamic> data = {};

    // Note: Format of adjustment API was updated in API v14
    if (InvenTreeAPI().supportModernStockTransactions()) {
      // Modern (> 14) API
      data = {
        "items": [
          {
            "pk": "${pk}",
            "quantity": "${quantity}",
          }
        ],
      };
    } else {
      // Legacy (<= 14) API
      data = {
        "item": {
          "pk": "${pk}",
          "quantity": "${quantity}",
        },
      };
    }

    data["notes"] = notes ?? "";

    if (location != null) {
      data["location"] = location;
    }

    // Expected API return code depends on server API version
    final int expected_response = InvenTreeAPI().supportModernStockTransactions() ? 201 : 200;

    var response = await api.post(
      endpoint,
      body: data,
      expectedStatusCode: expected_response,
    );

    return response.isValid();
  }

  // TODO: Remove this function when we deprecate support for the old API
  Future<bool> countStock(BuildContext context, double q, {String? notes}) async {

    final bool result = await adjustStock(context, "/stock/count/", q, notes: notes);

    return result;
  }

  // TODO: Remove this function when we deprecate support for the old API
  Future<bool> addStock(BuildContext context, double q, {String? notes}) async {

    final bool result = await adjustStock(context,  "/stock/add/", q, notes: notes);

    return result;
  }

  // TODO: Remove this function when we deprecate support for the old API
  Future<bool> removeStock(BuildContext context, double q, {String? notes}) async {

    final bool result = await adjustStock(context, "/stock/remove/", q, notes: notes);

    return result;
  }

  // TODO: Remove this function when we deprecate support for the old API
  Future<bool> transferStock(BuildContext context, int location, {double? quantity, String? notes}) async {

    double q = this.quantity;

    if (quantity != null) {
      q = quantity;
    }

    final bool result = await adjustStock(
      context,
      "/stock/transfer/",
      q,
      notes: notes,
      location: location,
    );

    return result;
  }
}


class InvenTreeStockLocation extends InvenTreeModel {

  InvenTreeStockLocation() : super();

  InvenTreeStockLocation.fromJson(Map<String, dynamic> json) : super.fromJson(json);

  @override
  String get URL => "stock/location/";

  String get pathstring => (jsondata["pathstring"] ?? "") as String;

  @override
  Map<String, dynamic> formFields() {
    return {
      "name": {},
      "description": {},
      "parent": {},
    };
  }

  String get parentpathstring {
    // TODO - Drive the refactor tractor through this
    List<String> psplit = pathstring.split("/");

    if (psplit.isNotEmpty) {
      psplit.removeLast();
    }

    String p = psplit.join("/");

    if (p.isEmpty) {
      p = "Top level stock location";
    }

    return p;
  }

  int get itemcount => (jsondata["items"] ?? 0) as int;

  @override
  InvenTreeModel createFromJson(Map<String, dynamic> json) {

    var loc = InvenTreeStockLocation.fromJson(json);

    return loc;
  }
}