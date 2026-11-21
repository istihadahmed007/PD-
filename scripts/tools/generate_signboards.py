import os
from PIL import Image, ImageDraw, ImageFont

font_path = "C:\\Windows\\Fonts\\NirmalaB.ttf"
if not os.path.exists(font_path):
    font_path = "C:\\Windows\\Fonts\\Nirmala.ttf"

def create_signboard(filename, title, subtitle, bg_color, border_color, title_color, sub_color, width=1024, height=256):
    img = Image.new("RGBA", (width, height), bg_color)
    draw = ImageDraw.Draw(img)
    
    # Outer border
    border_w = 8
    draw.rectangle([border_w, border_w, width - border_w, height - border_w], outline=border_color, width=border_w)
    # Inner thin border
    draw.rectangle([border_w + 6, border_w + 6, width - border_w - 6, height - border_w - 6], outline=(255, 255, 255, 180), width=2)
    
    # Fonts
    title_font = ImageFont.truetype(font_path, 80)
    sub_font = ImageFont.truetype(font_path, 36)
    
    # Draw Title centered
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_w = title_bbox[2] - title_bbox[0]
    title_x = (width - title_w) // 2
    title_y = 35
    
    # Shadow
    draw.text((title_x + 3, title_y + 3), title, font=title_font, fill=(0, 0, 0, 180))
    draw.text((title_x, title_y), title, font=title_font, fill=title_color)
    
    # Draw Subtitle centered
    sub_bbox = draw.textbbox((0, 0), subtitle, font=sub_font)
    sub_w = sub_bbox[2] - sub_bbox[0]
    sub_x = (width - sub_w) // 2
    sub_y = 155
    
    draw.text((sub_x + 2, sub_y + 2), subtitle, font=sub_font, fill=(0, 0, 0, 160))
    draw.text((sub_x, sub_y), subtitle, font=sub_font, fill=sub_color)
    
    out_dir = os.path.join("assets", "textures", "signboards")
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, filename)
    img.save(out_path, "PNG")
    print(f"Generated: {out_path}")

# 1. Police Station (Thana)
create_signboard(
    "sign_police.png",
    "থানা পুলিশ ফাঁড়ি",
    "DHAKA METROPOLITAN POLICE — সেবা ও নিরাপত্তা",
    bg_color=(18, 38, 88),
    border_color=(235, 190, 40),
    title_color=(255, 245, 160),
    sub_color=(255, 255, 255)
)

# 2. Tea Stall (Bismillah Tea Stall)
create_signboard(
    "sign_tea_stall.png",
    "বিসমিল্লাহ টি স্টল",
    "স্পেশাল মালাই চা, দুধ চা, টোস্ট ও গরম সমুচা",
    bg_color=(220, 70, 30),
    border_color=(255, 230, 80),
    title_color=(255, 255, 255),
    sub_color=(255, 240, 180)
)

# 3. Grocery Store (Ma Babar Doa)
create_signboard(
    "sign_grocery.png",
    "মা বাবার দোয়া স্টোর",
    "চাল, ডাল, তেল, চিনি ও যাবতীয় মুদি মালামাল বিক্রয়",
    bg_color=(20, 120, 60),
    border_color=(240, 210, 40),
    title_color=(255, 240, 100),
    sub_color=(255, 255, 255)
)

# 4. Pharmacy (New Dhaka Pharmacy)
create_signboard(
    "sign_pharmacy.png",
    "নিউ ঢাকা ফার্মেসি",
    "দেশী-বিদেশী সকল প্রকার জীবনরক্ষাকারী ঔষধ ও সার্জিক্যাল",
    bg_color=(245, 248, 250),
    border_color=(20, 140, 65),
    title_color=(20, 140, 65),
    sub_color=(40, 60, 80)
)

# 5. Auto Workshop (Bhai Bhai Motors)
create_signboard(
    "sign_workshop.png",
    "ভাই ভাই অটো ওয়ার্কশপ",
    "এখানে রিকশা, সিএনজি ও মোটরসাইকেলের ইঞ্জিন ও পার্টস মেরামত হয়",
    bg_color=(35, 38, 42),
    border_color=(245, 130, 20),
    title_color=(255, 145, 25),
    sub_color=(220, 220, 230)
)

# 6. CNG & Bus Stand
create_signboard(
    "sign_cng_stand.png",
    "পদ্মা-বুড়িগঙ্গা সিএনজি ও বাস স্ট্যান্ড",
    "যাত্রী ছাউনি • টিকিট কাউন্টার • রিকশা টার্মিনাল",
    bg_color=(25, 95, 160),
    border_color=(255, 255, 255),
    title_color=(255, 255, 255),
    sub_color=(255, 230, 120)
)

# 7. Sweetmeat / Mishtanna Bhandar
create_signboard(
    "sign_sweetmeat.png",
    "রাজশাহী মিষ্টান্ন ভাণ্ডার",
    "খাঁটি ছানার মিষ্টি, রসগোল্লা, চমচম ও টাটকা দই",
    bg_color=(170, 25, 45),
    border_color=(240, 190, 50),
    title_color=(255, 235, 120),
    sub_color=(255, 255, 255)
)
print("All signboards created successfully!")
