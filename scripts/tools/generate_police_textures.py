# ==============================================================================
# POLICE TEXTURE & SIGNBOARD GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Synthesizes high-resolution textures for DMP Police vehicles,
#          roadblock checkpoints, barrier hazard stripes, and restricted signs.
# ==============================================================================
import os
from PIL import Image, ImageDraw, ImageFont

font_path = "C:\\Windows\\Fonts\\NirmalaB.ttf"
if not os.path.exists(font_path):
    font_path = "C:\\Windows\\Fonts\\Nirmala.ttf"

out_dir = os.path.join("assets", "textures", "signboards")
os.makedirs(out_dir, exist_ok=True)

def create_police_decal(filename):
    # Police Door Livery Decal (512x256)
    img = Image.new("RGBA", (512, 256), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Navy blue badge background with gold border
    draw.rounded_rectangle([10, 10, 502, 246], radius=24, fill=(16, 32, 75, 240), outline=(235, 195, 45, 255), width=6)
    # Inner gold border
    draw.rounded_rectangle([20, 20, 492, 236], radius=16, outline=(255, 255, 255, 180), width=2)
    
    font_title = ImageFont.truetype(font_path, 42)
    font_sub = ImageFont.truetype(font_path, 34)
    font_small = ImageFont.truetype(font_path, 22)
    
    # Title: ঢাকা মেট্রোপলিটন পুলিশ
    t1 = "ঢাকা মেট্রোপলিটন পুলিশ"
    b1 = draw.textbbox((0, 0), t1, font=font_title)
    draw.text(((512 - (b1[2] - b1[0])) // 2, 32), t1, font=font_title, fill=(255, 245, 150))
    
    # English: DHAKA POLICE - DMP
    t2 = "DMP POLICE 999"
    b2 = draw.textbbox((0, 0), t2, font=font_sub)
    draw.text(((512 - (b2[2] - b2[0])) // 2, 102), t2, font=font_sub, fill=(255, 255, 255))
    
    # Motto: শান্তি ও নিরাপত্তা
    t3 = "শান্তি শৃঙ্খলা প্রগতি"
    b3 = draw.textbbox((0, 0), t3, font=font_small)
    draw.text(((512 - (b3[2] - b3[0])) // 2, 180), t3, font=font_small, fill=(210, 230, 255))
    
    path = os.path.join(out_dir, filename)
    img.save(path, "PNG")
    print(f"Generated decal: {path}")

def create_checkpoint_sign(filename):
    # 1024x256 Roadblock Checkpoint Sign
    width = 1024
    height = 256
    img = Image.new("RGBA", (width, height), (160, 25, 25, 255))
    draw = ImageDraw.Draw(img)
    
    # Yellow outer and inner border
    draw.rectangle([8, 8, width - 8, height - 8], outline=(255, 220, 0), width=10)
    draw.rectangle([22, 22, width - 22, height - 22], outline=(255, 255, 255), width=3)
    
    font_title = ImageFont.truetype(font_path, 72)
    font_sub = ImageFont.truetype(font_path, 38)
    
    t1 = "ডিএমপি পুলিশ চেকপোস্ট — থামুন"
    b1 = draw.textbbox((0, 0), t1, font=font_title)
    draw.text(((width - (b1[2] - b1[0])) // 2, 36), t1, font=font_title, fill=(255, 255, 255))
    
    t2 = "DMP POLICE CHECKPOINT — SLOW DOWN FOR INSPECTION"
    b2 = draw.textbbox((0, 0), t2, font=font_sub)
    draw.text(((width - (b2[2] - b2[0])) // 2, 155), t2, font=font_sub, fill=(255, 235, 100))
    
    path = os.path.join(out_dir, filename)
    img.save(path, "PNG")
    print(f"Generated checkpoint sign: {path}")

def create_hazard_barrier_stripes(filename):
    # 512x128 Red and White reflective diagonal stripes for barricades
    w = 512
    h = 128
    img = Image.new("RGBA", (w, h), (240, 240, 240, 255))
    draw = ImageDraw.Draw(img)
    stripe_w = 48
    for x in range(-h, w + h, stripe_w * 2):
        points = [
            (x, 0),
            (x + stripe_w, 0),
            (x + stripe_w - h, h),
            (x - h, h)
        ]
        draw.polygon(points, fill=(200, 30, 30, 255))
    # Border
    draw.rectangle([0, 0, w - 1, h - 1], outline=(40, 40, 40, 255), width=3)
    path = os.path.join(out_dir, filename)
    img.save(path, "PNG")
    print(f"Generated barrier stripe: {path}")

def create_restricted_sign(filename):
    # 512x256 Restricted Area sign for Thana Armory/Lockup
    w = 512
    h = 256
    img = Image.new("RGBA", (w, h), (20, 20, 24, 255))
    draw = ImageDraw.Draw(img)
    draw.rectangle([6, 6, w - 6, h - 6], outline=(220, 40, 40), width=8)
    
    font_title = ImageFont.truetype(font_path, 46)
    font_sub = ImageFont.truetype(font_path, 26)
    
    t1 = "সংরক্ষিত এলাকা"
    b1 = draw.textbbox((0, 0), t1, font=font_title)
    draw.text(((w - (b1[2] - b1[0])) // 2, 35), t1, font=font_title, fill=(255, 60, 60))
    
    t2 = "অননুমোদিত প্রবেশ সম্পূর্ণ নিষেধ"
    b2 = draw.textbbox((0, 0), t2, font=font_sub)
    draw.text(((w - (b2[2] - b2[0])) // 2, 115), t2, font=font_sub, fill=(255, 230, 230))
    
    t3 = "RESTRICTED AREA - POLICE ONLY"
    b3 = draw.textbbox((0, 0), t3, font=font_sub)
    draw.text(((w - (b3[2] - b3[0])) // 2, 175), t3, font=font_sub, fill=(255, 200, 50))
    
    path = os.path.join(out_dir, filename)
    img.save(path, "PNG")
    print(f"Generated restricted sign: {path}")

if __name__ == "__main__":
    create_police_decal("police_car_decal.png")
    create_checkpoint_sign("sign_checkpoint.png")
    create_hazard_barrier_stripes("checkpoint_barrier_stripes.png")
    create_restricted_sign("sign_restricted_armory.png")
