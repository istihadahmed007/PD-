# ==============================================================================
# CHARACTER PORTRAIT & BADGE GENERATOR
# Project: Bangladesh Open-World Action Game (DTA: Dhaka Theft Auto)
# Purpose: Synthesizes character dialogue badges and questgiver icons using Pillow.
# ==============================================================================
import os
from PIL import Image, ImageDraw, ImageFont

font_path = "C:\\Windows\\Fonts\\NirmalaB.ttf"
if not os.path.exists(font_path):
    font_path = "C:\\Windows\\Fonts\\Nirmala.ttf"

out_dir = os.path.join("assets", "textures", "characters")
os.makedirs(out_dir, exist_ok=True)

def generate_portrait(filename, char_name, title, bg_color, border_color, accent_color, initials):
    size = 256
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Outer circle border
    draw.ellipse([8, 8, size - 8, size - 8], fill=bg_color, outline=border_color, width=8)
    # Inner ring
    draw.ellipse([20, 20, size - 20, size - 20], outline=(255, 255, 255, 120), width=3)
    
    # Character silhouette / abstract avatar
    # Head & shoulders
    draw.ellipse([88, 55, 168, 135], fill=accent_color)
    draw.ellipse([50, 145, 206, 260], fill=accent_color)
    
    # Initials badge on chest
    font_large = ImageFont.truetype(font_path, 44)
    font_small = ImageFont.truetype(font_path, 22)
    
    b_init = draw.textbbox((0, 0), initials, font=font_large)
    w_init = b_init[2] - b_init[0]
    draw.text(((size - w_init) // 2, 70), initials, font=font_large, fill=(255, 255, 255))
    
    # Lower name banner ribbon
    draw.rectangle([18, 195, size - 18, 240], fill=(15, 18, 24, 230), outline=border_color, width=2)
    b_name = draw.textbbox((0, 0), char_name, font=font_small)
    w_name = b_name[2] - b_name[0]
    draw.text(((size - w_name) // 2, 204), char_name, font=font_small, fill=(255, 235, 120))
    
    path = os.path.join(out_dir, filename)
    img.save(path, "PNG")
    print(f"Generated portrait: {path}")

if __name__ == "__main__":
    generate_portrait("portrait_joy.png", "JOY (জয়নাল)", "Protagonist", (28, 45, 75), (240, 180, 40), (45, 80, 130), "JA")
    generate_portrait("portrait_kabir.png", "KABIR USTAD", "Master Mechanic", (60, 45, 30), (220, 140, 50), (95, 70, 45), "KM")
    generate_portrait("portrait_nila.png", "NILA (সাংবাদিক)", "Investigative Press", (25, 60, 60), (40, 200, 180), (40, 100, 100), "NC")
    generate_portrait("portrait_mahfuz.png", "SI MAHFUZ", "DMP Police Thana", (18, 30, 65), (230, 200, 50), (35, 55, 110), "MR")
    generate_portrait("portrait_tariq.png", "GHASHI TARIQ", "Syndicate Enforcer", (70, 20, 20), (230, 40, 40), (120, 35, 35), "GT")
    generate_portrait("portrait_rahmat.png", "RAHMAT CHACHA", "Union Elder", (35, 50, 35), (100, 200, 100), (55, 85, 55), "RC")
    print("All character portraits successfully generated!")
