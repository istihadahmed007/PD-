# ==============================================================================
# BANGLADESHI PEDESTRIAN SCENE GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Programmatically constructs characters/pedestrians/bangladeshi_pedestrian.tscn
# ==============================================================================
import os

def generate_pedestrian_scene():
    output_path = r"characters/pedestrians/bangladeshi_pedestrian.tscn"
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    content = """[gd_scene format=3 uid="uid://d3pedestrian001"]

[ext_resource type="Script" path="res://characters/pedestrians/bangladeshi_pedestrian.gd" id="1_pedestrian"]
[ext_resource type="AudioStream" path="res://audio/city/pedestrian_shout_1.wav" id="2_shoutaudio"]

[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_ped"]
radius = 0.35
height = 1.75

[sub_resource type="StandardMaterial3D" id="Mat_SkinTone"]
albedo_color = Color(0.72, 0.52, 0.38, 1)
roughness = 0.75

[sub_resource type="StandardMaterial3D" id="Mat_WhiteTupi"]
albedo_color = Color(0.96, 0.96, 0.96, 1)
roughness = 0.8

[sub_resource type="StandardMaterial3D" id="Mat_DefaultTorso"]
albedo_color = Color(0.85, 0.22, 0.2, 1)
roughness = 0.8

[sub_resource type="StandardMaterial3D" id="Mat_DefaultLegs"]
albedo_color = Color(0.18, 0.24, 0.38, 1)
roughness = 0.85

[sub_resource type="Animation" id="Animation_idle"]
resource_name = "idle"
length = 2.0
loop_mode = 1
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("VisualRoot/Torso:position")
tracks/0/interp = 2
tracks/0/loop_wrap = true
tracks/0/keys = {
"times": PackedFloat32Array(0, 1.0, 2.0),
"transitions": PackedFloat32Array(1, 1, 1),
"update": 0,
"values": [Vector3(0, 1.05, 0), Vector3(0, 1.07, 0), Vector3(0, 1.05, 0)]
}

[sub_resource type="Animation" id="Animation_walk"]
resource_name = "walk"
length = 0.8
loop_mode = 1
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("VisualRoot:position")
tracks/0/interp = 2
tracks/0/loop_wrap = true
tracks/0/keys = {
"times": PackedFloat32Array(0, 0.2, 0.4, 0.6, 0.8),
"transitions": PackedFloat32Array(1, 1, 1, 1, 1),
"update": 0,
"values": [Vector3(0, 0, 0), Vector3(0, 0.05, 0), Vector3(0, 0, 0), Vector3(0, 0.05, 0), Vector3(0, 0, 0)]
}

[sub_resource type="Animation" id="Animation_run"]
resource_name = "run"
length = 0.5
loop_mode = 1
tracks/0/type = "value"
tracks/0/imported = false
tracks/0/enabled = true
tracks/0/path = NodePath("VisualRoot:position")
tracks/0/interp = 2
tracks/0/loop_wrap = true
tracks/0/keys = {
"times": PackedFloat32Array(0, 0.12, 0.25, 0.38, 0.5),
"transitions": PackedFloat32Array(1, 1, 1, 1, 1),
"update": 0,
"values": [Vector3(0, 0, 0), Vector3(0, 0.1, 0), Vector3(0, 0, 0), Vector3(0, 0.1, 0), Vector3(0, 0, 0)]
}

[sub_resource type="AnimationLibrary" id="AnimationLibrary_ped"]
_data = {
"idle": SubResource("Animation_idle"),
"run": SubResource("Animation_run"),
"walk": SubResource("Animation_walk")
}

[node name="BangladeshiPedestrian" type="CharacterBody3D" groups=["pedestrians"]]
collision_layer = 8
collision_mask = 7
script = ExtResource("1_pedestrian")

[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.88, 0)
shape = SubResource("CapsuleShape3D_ped")

[node name="VehicleDetector" type="RayCast3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.8, 0)
target_position = Vector3(0, 0, -4.5)
collision_mask = 4

[node name="ShoutAudio" type="AudioStreamPlayer3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.5, 0)
stream = ExtResource("2_shoutaudio")
volume_db = 1.0
max_distance = 35.0

[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {
"": SubResource("AnimationLibrary_ped")
}

[node name="VisualRoot" type="Node3D" parent="."]

[node name="Head" type="CSGBox3D" parent="VisualRoot"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.55, 0)
size = Vector3(0.26, 0.28, 0.26)
material = SubResource("Mat_SkinTone")

[node name="TupiHat" type="CSGCylinder3D" parent="VisualRoot/Head"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.16, 0)
visible = false
radius = 0.14
height = 0.08
sides = 12
material = SubResource("Mat_WhiteTupi")

[node name="Torso" type="CSGBox3D" parent="VisualRoot"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.05, 0)
size = Vector3(0.5, 0.65, 0.3)
material = SubResource("Mat_DefaultTorso")

[node name="Legs" type="CSGBox3D" parent="VisualRoot"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.42, 0)
size = Vector3(0.46, 0.75, 0.28)
material = SubResource("Mat_DefaultLegs")

[node name="Dupatta" type="CSGBox3D" parent="VisualRoot"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1.15, -0.05)
visible = false
size = Vector3(0.54, 0.55, 0.34)
material = SubResource("Mat_WhiteTupi")
"""

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated {output_path} successfully.")

if __name__ == "__main__":
    generate_pedestrian_scene()
