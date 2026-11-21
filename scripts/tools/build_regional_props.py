# ==============================================================================
# REGIONAL MODULAR PROPS GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically builds 3D modular architectural & foliage assets for
#          the 7 geographical regions of Bangladesh.
# ==============================================================================
import os

def create_prop(filepath, content):
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content.strip() + "\n")
    print(f"Created Prop: {filepath}")

def build_all_props():
    # 1. Brick Kiln (Rajshahi)
    create_prop("environment/architecture/brick_kiln.tscn", """[gd_scene load_steps=4 format=3 uid="uid://brickkiln001"]

[sub_resource type="StandardMaterial3D" id="Mat_Brick"]
albedo_color = Color(0.68, 0.28, 0.22, 1)
roughness = 0.95

[sub_resource type="StandardMaterial3D" id="Mat_Base"]
albedo_color = Color(0.35, 0.32, 0.3, 1)

[sub_resource type="CylinderShape3D" id="CylShape_kiln"]
height = 24.0
radius = 2.4

[node name="BrickKiln" type="StaticBody3D"]

[node name="KilnBase" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2.5, 0)
size = Vector3(18, 5, 14)
material = SubResource("Mat_Base")

[node name="Chimney" type="CSGCylinder3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 14, 0)
radius = 2.2
height = 24.0
sides = 16
cone = true
material = SubResource("Mat_Brick")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 12, 0)
shape = SubResource("CylShape_kiln")
""")

    # 2. Padma Truss Bridge Span
    create_prop("environment/infrastructure/padma_truss_bridge.tscn", """[gd_scene load_steps=4 format=3 uid="uid://padmatruss001"]

[sub_resource type="StandardMaterial3D" id="Mat_TrussSteel"]
albedo_color = Color(0.35, 0.55, 0.65, 1)
metallic = 0.8
roughness = 0.4

[sub_resource type="StandardMaterial3D" id="Mat_Deck"]
albedo_color = Color(0.2, 0.22, 0.24, 1)
roughness = 0.85

[sub_resource type="BoxShape3D" id="BoxShape_deck"]
size = Vector3(16, 2.5, 60)

[node name="PadmaTrussBridge" type="StaticBody3D"]

[node name="Deck" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0)
size = Vector3(16, 2, 60)
material = SubResource("Mat_Deck")

[node name="TrussLeft" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -7.5, 7, 0)
size = Vector3(1.2, 10, 60)
material = SubResource("Mat_TrussSteel")

[node name="TrussRight" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 7.5, 7, 0)
size = Vector3(1.2, 10, 60)
material = SubResource("Mat_TrussSteel")

[node name="PierPillar" type="CSGCylinder3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -8, 0)
radius = 4.0
height = 16.0
sides = 12
material = SubResource("Mat_Deck")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.25, 0)
shape = SubResource("BoxShape_deck")
""")

    # 3. Mango Tree (Rajshahi)
    create_prop("environment/foliage/mango_tree.tscn", """[gd_scene load_steps=4 format=3 uid="uid://mangotree001"]

[sub_resource type="StandardMaterial3D" id="Mat_Trunk"]
albedo_color = Color(0.38, 0.26, 0.18, 1)

[sub_resource type="StandardMaterial3D" id="Mat_Canopy"]
albedo_color = Color(0.18, 0.52, 0.22, 1)
roughness = 0.8

[sub_resource type="CylinderShape3D" id="Cyl_trunk"]
height = 4.0
radius = 0.5

[node name="MangoTree" type="StaticBody3D"]

[node name="Trunk" type="CSGCylinder3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2, 0)
radius = 0.45
height = 4.0
sides = 8
material = SubResource("Mat_Trunk")

[node name="Canopy" type="CSGSphere3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 5.5, 0)
radius = 3.2
radial_segments = 10
rings = 6
material = SubResource("Mat_Canopy")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2, 0)
shape = SubResource("Cyl_trunk")
""")

    # 4. Tea Estate Bungalow (Sylhet)
    create_prop("environment/architecture/tea_bungalow.tscn", """[gd_scene load_steps=4 format=3 uid="uid://teabungalow001"]

[sub_resource type="StandardMaterial3D" id="Mat_WoodWall"]
albedo_color = Color(0.85, 0.82, 0.75, 1)

[sub_resource type="StandardMaterial3D" id="Mat_GreenRoof"]
albedo_color = Color(0.12, 0.38, 0.22, 1)

[sub_resource type="BoxShape3D" id="Box_bungalow"]
size = Vector3(16, 6, 12)

[node name="TeaBungalow" type="StaticBody3D"]

[node name="Plinth" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.5, 0)
size = Vector3(17, 1, 13)
material = SubResource("Mat_WoodWall")

[node name="Walls" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3, 0)
size = Vector3(15, 4, 11)
material = SubResource("Mat_WoodWall")

[node name="PitchedRoof" type="CSGBox3D" parent="."]
transform = Transform3D(0.965926, 0.258819, 0, -0.258819, 0.965926, 0, 0, 0, 1, 0, 6.2, 0)
size = Vector3(12, 2, 14)
material = SubResource("Mat_GreenRoof")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3, 0)
shape = SubResource("Box_bungalow")
""")

    # 5. Tea Bush (Sylhet)
    create_prop("environment/foliage/tea_bush.tscn", """[gd_scene load_steps=3 format=3 uid="uid://teabush001"]

[sub_resource type="StandardMaterial3D" id="Mat_Tea"]
albedo_color = Color(0.14, 0.58, 0.25, 1)
roughness = 0.9

[sub_resource type="BoxShape3D" id="Box_bush"]
size = Vector3(1.8, 1.2, 1.8)

[node name="TeaBush" type="StaticBody3D"]

[node name="BushMesh" type="CSGSphere3D" parent="."]
transform = Transform3D(1.2, 0, 0, 0, 0.8, 0, 0, 0, 1.2, 0, 0.6, 0)
radius = 0.8
radial_segments = 8
rings = 6
material = SubResource("Mat_Tea")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.6, 0)
shape = SubResource("Box_bush")
""")

    # 6. Container Stack (Chattogram)
    create_prop("environment/infrastructure/container_stack.tscn", """[gd_scene load_steps=4 format=3 uid="uid://containerstack001"]

[sub_resource type="StandardMaterial3D" id="Mat_ContBlue"]
albedo_color = Color(0.15, 0.35, 0.72, 1)

[sub_resource type="StandardMaterial3D" id="Mat_ContRed"]
albedo_color = Color(0.72, 0.18, 0.15, 1)

[sub_resource type="BoxShape3D" id="Box_stack"]
size = Vector3(8.5, 7.5, 12.5)

[node name="ContainerStack" type="StaticBody3D"]

[node name="Box1" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -2, 1.3, 0)
size = Vector3(3.8, 2.6, 12.2)
material = SubResource("Mat_ContBlue")

[node name="Box2" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 2, 1.3, 0)
size = Vector3(3.8, 2.6, 12.2)
material = SubResource("Mat_ContRed")

[node name="Box3" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3.9, 0)
size = Vector3(3.8, 2.6, 12.2)
material = SubResource("Mat_ContBlue")

[node name="Box4" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 6.5, 0)
size = Vector3(3.8, 2.6, 12.2)
material = SubResource("Mat_ContRed")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3.75, 0)
shape = SubResource("Box_stack")
""")

    # 7. Port Gantry Crane (Chattogram)
    create_prop("environment/infrastructure/port_gantry_crane.tscn", """[gd_scene load_steps=3 format=3 uid="uid://portgantry001"]

[sub_resource type="StandardMaterial3D" id="Mat_GantryYellow"]
albedo_color = Color(0.92, 0.72, 0.12, 1)

[sub_resource type="BoxShape3D" id="Box_gantry"]
size = Vector3(18, 22, 10)

[node name="PortGantryCrane" type="StaticBody3D"]

[node name="LegLeft" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -8, 10, 0)
size = Vector3(1.5, 20, 2)
material = SubResource("Mat_GantryYellow")

[node name="LegRight" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 8, 10, 0)
size = Vector3(1.5, 20, 2)
material = SubResource("Mat_GantryYellow")

[node name="TopBoom" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 20, 0)
size = Vector3(26, 2, 2.5)
material = SubResource("Mat_GantryYellow")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 11, 0)
shape = SubResource("Box_gantry")
""")

    # 8. Tourist Resort Hotel (Cox's Bazar)
    create_prop("environment/architecture/resort_hotel.tscn", """[gd_scene load_steps=4 format=3 uid="uid://resorthotel001"]

[sub_resource type="StandardMaterial3D" id="Mat_WhiteStucco"]
albedo_color = Color(0.92, 0.92, 0.94, 1)

[sub_resource type="StandardMaterial3D" id="Mat_BlueGlass"]
albedo_color = Color(0.2, 0.55, 0.85, 1)

[sub_resource type="BoxShape3D" id="Box_hotel"]
size = Vector3(28, 20, 18)

[node name="ResortHotel" type="StaticBody3D"]

[node name="MainBuilding" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 10, 0)
size = Vector3(26, 20, 16)
material = SubResource("Mat_WhiteStucco")

[node name="GlassFront" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 10, 8.2)
size = Vector3(20, 16, 0.4)
material = SubResource("Mat_BlueGlass")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 10, 0)
shape = SubResource("Box_hotel")
""")

    # 9. Mangrove Tree with Stilt Roots (Sundarbans)
    create_prop("environment/foliage/mangrove_tree.tscn", """[gd_scene load_steps=4 format=3 uid="uid://mangrovetree001"]

[sub_resource type="StandardMaterial3D" id="Mat_MudBark"]
albedo_color = Color(0.28, 0.22, 0.16, 1)

[sub_resource type="StandardMaterial3D" id="Mat_MangroveLeaves"]
albedo_color = Color(0.12, 0.42, 0.18, 1)

[sub_resource type="CylinderShape3D" id="Cyl_mangrove"]
height = 6.0
radius = 1.8

[node name="MangroveTree" type="StaticBody3D"]

[node name="StiltRoot1" type="CSGCylinder3D" parent="."]
transform = Transform3D(0.866025, 0.5, 0, -0.5, 0.866025, 0, 0, 0, 1, -1, 1.2, 0)
radius = 0.2
height = 2.8
material = SubResource("Mat_MudBark")

[node name="StiltRoot2" type="CSGCylinder3D" parent="."]
transform = Transform3D(0.866025, -0.5, 0, 0.5, 0.866025, 0, 0, 0, 1, 1, 1.2, 0)
radius = 0.2
height = 2.8
material = SubResource("Mat_MudBark")

[node name="Trunk" type="CSGCylinder3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3.5, 0)
radius = 0.35
height = 3.5
material = SubResource("Mat_MudBark")

[node name="Canopy" type="CSGSphere3D" parent="."]
transform = Transform3D(1.4, 0, 0, 0, 0.8, 0, 0, 0, 1.4, 0, 5.5, 0)
radius = 2.4
material = SubResource("Mat_MangroveLeaves")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 3, 0)
shape = SubResource("Cyl_mangrove")
""")

    # 10. Thatched Hut (Rural Plains)
    create_prop("environment/architecture/thatched_hut.tscn", """[gd_scene load_steps=4 format=3 uid="uid://thatchedhut001"]

[sub_resource type="StandardMaterial3D" id="Mat_ClayWall"]
albedo_color = Color(0.65, 0.55, 0.42, 1)

[sub_resource type="StandardMaterial3D" id="Mat_StrawRoof"]
albedo_color = Color(0.72, 0.62, 0.28, 1)

[sub_resource type="BoxShape3D" id="Box_hut"]
size = Vector3(6, 4, 5)

[node name="ThatchedHut" type="StaticBody3D"]

[node name="MudWalls" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.25, 0)
size = Vector3(5.5, 2.5, 4.5)
material = SubResource("Mat_ClayWall")

[node name="StrawRoof" type="CSGBox3D" parent="."]
transform = Transform3D(0.965926, 0.258819, 0, -0.258819, 0.965926, 0, 0, 0, 1, 0, 3.2, 0)
size = Vector3(4.8, 1.5, 5.2)
material = SubResource("Mat_StrawRoof")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2, 0)
shape = SubResource("Box_hut")
""")

if __name__ == "__main__":
    build_all_props()
