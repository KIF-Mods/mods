import os
from PIL import Image

INPUT_DIR = "."
OUTPUT_DIR = "./output"

os.makedirs(OUTPUT_DIR, exist_ok=True)

for file in os.listdir(INPUT_DIR):
    if file.lower().endswith(".png"):
        input_path = os.path.join(INPUT_DIR, file)
        output_path = os.path.join(OUTPUT_DIR, file)

        try:
            with Image.open(input_path) as img:
                img.convert("RGBA")

                if img.width > 128 or img.height > 128:
                    img.thumbnail((128,128), Image.NEAREST)

                    canvas = Image.new("RGBA", (128,128), (0,0,0,0))

                    x = (128 - img.width) // 2
                    y = (128 - img.height) // 2

                    canvas.paste(img, (x,y))
                    canvas.save(output_path, "PNG")

        except Exception as e:
            print(f"Error processing {file}: {e}")