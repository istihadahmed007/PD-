# ==============================================================================
# ECONOMY TEST SCENE BUILDER
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically generates tests/test_economy_system.tscn
# ==============================================================================
import os

def build_scene():
    tscn_content = """[gd_scene load_steps=12 format=3 uid="uid://testeconomysys001"]

[ext_resource type="Script" path="res://tests/test_economy_system.gd" id="1_test"]
[ext_resource type="PackedScene" uid="uid://ciqrpd5675boy" path="res://player/player.tscn" id="2_player"]
[ext_resource type="PackedScene" path="res://vehicles/sedan/sedan.tscn" id="3_sedan"]
[ext_resource type="PackedScene" uid="uid://economyui001" path="res://ui/economy/economy_ui_controller.tscn" id="4_ui"]
[ext_resource type="PackedScene" uid="uid://b5hud001" path="res://ui/hud/hud.tscn" id="5_hud"]
[ext_resource type="PackedScene" uid="uid://shopstation001" path="res://scripts/economy/shop_station.tscn" id="6_station"]
[ext_resource type="PackedScene" uid="uid://atmterminal001" path="res://scripts/economy/atm_terminal.tscn" id="7_atm"]
[ext_resource type="PackedScene" uid="uid://safehouseprop001" path="res://scripts/economy/safehouse_property.tscn" id="8_safehouse"]
[ext_resource type="PackedScene" uid="uid://itempickup3d001" path="res://scripts/economy/item_pickup_3d.tscn" id="9_pickup"]

[sub_resource type="Environment" id="Environment_sun"]
background_mode = 1
background_color = Color(0.55, 0.72, 0.9, 1)
ambient_light_source = 2
ambient_light_color = Color(0.65, 0.68, 0.75, 1)
ambient_light_energy = 1.0

[sub_resource type="StandardMaterial3D" id="Mat_Ground"]
albedo_color = Color(0.18, 0.2, 0.22, 1)
roughness = 0.9

[node name="TestEconomySystem" type="Node3D"]
script = ExtResource("1_test")

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_sun")

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.866025, -0.353553, 0.353553, 0, 0.707107, 0.707107, -0.5, -0.612372, 0.612372, 0, 20, 0)
shadow_enabled = true

[node name="Ground" type="CSGBox3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, -0.25, 0)
use_collision = true
size = Vector3(140, 0.5, 140)
material = SubResource("Mat_Ground")

[node name="Player" parent="." instance=ExtResource("2_player")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.2, 0)

[node name="Sedan" parent="." instance=ExtResource("3_sedan")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 10, 0.45, -12)

[node name="EconomyUIController" parent="." instance=ExtResource("4_ui")]

[node name="HUD" parent="." instance=ExtResource("5_hud")]

[node name="Stations" type="Node3D" parent="."]

[node name="TongStation" parent="Stations" instance=ExtResource("6_station")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -12, 0, -8)
station_type = 0
shop_title = "Mama Tong Cha Stall"
bangla_title = "মামা টং চা দোকান"
shopkeeper_name = "Kalu Mama"
items_for_sale = Array[String](["cha", "singara", "samucha", "speed_drink", "kacchi_biryani"])

[node name="GeneralStation" parent="Stations" instance=ExtResource("6_station")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -12, 0, 6)
station_type = 1
shop_title = "Bismillah General Store"
bangla_title = "বিসমিল্লাহ জেনারেল স্টোর"
shopkeeper_name = "Gaffar Bhai"
items_for_sale = Array[String](["medkit", "repair_kit", "money_wad", "cha", "singara"])

[node name="FashionStation" parent="Stations" instance=ExtResource("6_station")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -12, 0, 20)
station_type = 2
shop_title = "Lalbagh Tailors & Desi Fashion"
bangla_title = "লালবাগ টেইলার্স"
shopkeeper_name = "Master Rafiq"

[node name="GarageStation" parent="Stations" instance=ExtResource("6_station")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 12, 0, -20)
station_type = 3
shop_title = "Bhai Bhai Auto Workshop Bay"
bangla_title = "ভাই ভাই অটো ওয়ার্কশপ"
shopkeeper_name = "Kabir Ustad"

[node name="AtmTerminal" parent="Stations" instance=ExtResource("7_atm")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -2, 0, 16)

[node name="SafehouseProperty" parent="Stations" instance=ExtResource("8_safehouse")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 16, 0, 16)
property_id = "safehouse_buriganga"
property_name = "Buriganga Riverview Flat"
price_bdt = 25000

[node name="GroundPickups" type="Node3D" parent="."]

[node name="PickupSingara" parent="GroundPickups" instance=ExtResource("9_pickup")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3, 0.1, 3)
item_id = "singara"
quantity = 3

[node name="PickupSpeed" parent="GroundPickups" instance=ExtResource("9_pickup")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5, 0.1, 3)
item_id = "speed_drink"
quantity = 2

[node name="PickupMoney" parent="GroundPickups" instance=ExtResource("9_pickup")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3, 0.1, 5)
item_id = "money_wad"
quantity = 1

[node name="PickupMedkit" parent="GroundPickups" instance=ExtResource("9_pickup")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5, 0.1, 5)
item_id = "medkit"
quantity = 1

[node name="PickupRepairKit" parent="GroundPickups" instance=ExtResource("9_pickup")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 7, 0.1, 5)
item_id = "repair_kit"
quantity = 1
"""
    output_path = "tests/test_economy_system.tscn"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(tscn_content)
    print(f"Generated: {output_path}")

if __name__ == "__main__":
    build_scene()
