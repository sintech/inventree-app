/*
 * Unit tests for accessing various model classes via the API
 */

import "package:inventree/inventree/model.dart";
import "package:test/test.dart";

import "package:inventree/api.dart";
import "package:inventree/user_profile.dart";
import "package:inventree/inventree/part.dart";


void main() {

  setUp(() async {
    await UserProfileDBManager().addProfile(UserProfile(
      name: "Test Profile",
      server: "http://localhost:12345",
      username: "testuser",
      password: "testpassword",
      selected: true,
    ));

    assert(await UserProfileDBManager().selectProfileByName("Test Profile"));
    assert(await InvenTreeAPI().connectToServer());
  });

  group("Part Tests:", () {

    test("Basics", () async {
      assert(InvenTreePart().URL == "part/");
    });

    test("List Parts", () async {
      List<InvenTreeModel> results;

      // List *all* parts
      results = await InvenTreePart().list();
      assert(results.length == 13);

      for (var result in results) {
        // results must be InvenTreePart instances
        assert(result is InvenTreePart);
      }

      // Filter by category
      results = await InvenTreePart().list(
        filters: {
          "category": "2",
        }
      );

      assert(results.length == 2);
    });

    test("Part Detail", () async {
      final result = await InvenTreePart().get(1);

      assert(result != null);
      assert(result is InvenTreePart);

      if (result != null) {
        InvenTreePart part = result as InvenTreePart;

        // Check some basic properties of the part
        assert(part.name == "M2x4 LPHS");
        assert(part.fullname == "M2x4 LPHS");
        assert(part.description == "M2x4 low profile head screw");
        assert(part.categoryId == 8);
        assert(part.categoryName == "Fasteners");
        assert(part.image == part.thumbnail);
        assert(part.thumbnail == "/static/img/blank_image.thumbnail.png");

        // Stock information
        assert(part.unallocatedStockString == "9000");
        assert(part.inStockString == "9000");
      }

    });

    test("Part Adjust", () async {
      // Test that we can update part data
      final result = await InvenTreePart().get(1);

      assert(result != null);
      assert(result is InvenTreePart);

      if (result != null) {
        InvenTreePart part = result as InvenTreePart;
        assert(part.name == "M2x4 LPHS");

        // Change the name to something else
        assert(await part.update(
          values: {
            "name": "Woogle",
          }
        ));

        assert(await part.reload());
        assert(part.name == "Woogle");

        // And change it back again
        assert(await part.update(
          values: {
            "name": "M2x4 LPHS"
          }
        ));

        assert(await part.reload());
        assert(part.name == "M2x4 LPHS");
      }
    });

  });

}