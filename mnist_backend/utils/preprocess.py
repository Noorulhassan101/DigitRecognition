import base64
import io
import numpy as np
from PIL import Image, ImageChops

def preprocess_image(base64_str: str) -> np.ndarray:
    """
    Takes a base64 encoded image string (data:image/png;base64,...),
    decodes it, extracts the white stroke on black background, processes
    the bounding box, and creates a normalized (1, 28, 28, 1) tensor.
    """
    if ',' in base64_str:
        base64_str = base64_str.split(',')[1]
        
    image_data = base64.b64decode(base64_str)
    
    # From Flutter we will export as PNG with transparent background and white strokes
    img_rgba = Image.open(io.BytesIO(image_data))
    
    # Create black background and paste the drawn image using alpha channel
    background = Image.new('RGB', img_rgba.size, (0, 0, 0))
    if img_rgba.mode in ('RGBA', 'LA') or (img_rgba.mode == 'P' and 'transparency' in img_rgba.info):
        background.paste(img_rgba, mask=img_rgba.split()[-1])
    else:
        background.paste(img_rgba)
        
    image = background.convert('L')
    
    # Get bounding box to crop the digit
    bbox = image.getbbox()
    if bbox:
        image = image.crop(bbox)
    else:
        # Empty canvas
        return np.zeros((1, 28, 28, 1), dtype=np.float32)
        
    # Resize keeping aspect ratio padding with black
    max_dim = max(image.size)
    padded_img = Image.new('L', (max_dim, max_dim), 0)
    
    offset = ((max_dim - image.size[0]) // 2, (max_dim - image.size[1]) // 2)
    padded_img.paste(image, offset)
    
    # Resize to 20x20 then pad to 28x28 like actual MNIST
    image = padded_img.resize((20, 20), resample=Image.Resampling.LANCZOS)
    
    final_img = Image.new('L', (28, 28), 0)
    final_img.paste(image, (4, 4))
    
    # Convert to array, normalize
    img_array = np.array(final_img).astype('float32') / 255.0
    
    # Shape for model input (1, 28, 28, 1)
    img_array = np.expand_dims(img_array, axis=0)
    img_array = np.expand_dims(img_array, axis=-1)
    
    return img_array
