# ==============================================================================
# WORLD EXPANSION TEST SCENE BUILDER
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically generates tests/test_world_expansion.tscn
# ==============================================================================
import os

def build_scene():
    tscn_content = """[gd_scene load_steps=8 format=3 uid="uid://testworldexpansion001"]

[ext_resource type="Script" path="res://tests/test_world_expansion.gd" id="1_test"]
[ext_resource type="PackedScene" uid="uid://ciqrpd5675boy" path="res://player/player.tscn" id="2_player"]
[ext_resource type="PackedScene" path="res://vehicles/sedan/sedan.tscn" id="3_sedan"]
[ext_resource type="Script" path="res://world/world_system.gd" id="4_world"]
[ext_resource type="PackedScene" uid="uid://worldmapui001" path="res://ui/world_map/world_map_ui.tscn" id="5_map"]
[ext_resource type="PackedScene" uid="uid://b5hud001" path="res://ui/hud/hud.tscn" id="6_hud"]

[sub_resource type="Environment" id="Environment_world"]
background_mode = 1
background_color = Color(0.6, 0.72, 0.85, 1)
ambient_light_source = 2
ambient_light_color = Color(0.68, 0.65, 0.62, 1)
ambient_light_energy = 1.0
volumetric_fog_enabled = true
volumetric_fog_density = 0.003
volumetric_fog_albedo = Color(0.72, 0.7, 0.68, 1)

[node name="TestWorldExpansion" type="Node3D"]
script = ExtResource("1_test")

[node name="WorldEnvironment" type="WorldEnvironment" parent="."]
environment = SubResource("Environment_world")

[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(0.866025, -0.353553, 0.353553, 0, 0.707107, 0.707107, -0.5, -0.612372, 0.612372, 0, 40, 0)
shadow_enabled = true

[node name="Player" parent="." instance=ExtResource("2_player")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.5, 0)

[node name="Sedan" parent="." instance=ExtResource("3_sedan")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 8, 0.45, 0)

[node name="WorldSystem" type="Node3D" parent="."]
script = ExtResource("4_world")
cell_size_meters = 512.0
stream_radius_cells = 1

[node name="WorldMapUI" parent="." instance=ExtResource("5_map")]

[node name="HUD" parent="." instance=ExtResource("6_hud")]
"""
    output_path = "tests/test_world_expansion.tscn"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(tscn_content.strip() + "\n")
    print(f"Generated: {output_path}")

if __name__ == "__main__":
    build_scene()
