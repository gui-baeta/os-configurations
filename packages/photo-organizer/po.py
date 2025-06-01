#!/usr/bin/env python3

import os
import sys
import shutil
import argparse
from datetime import datetime
from pathlib import Path
from PIL import Image
from PIL.ExifTags import TAGS
import hashlib
import time
from zoneinfo import ZoneInfo
import subprocess

image_extensions = {'.jpg', '.jpeg', '.png', '.tiff', '.tif', '.raw', '.cr2', '.orf', '.nef', '.arw', '.dng'}

def get_system_timezone():
    """Get the system timezone"""
    try:
        # Try to get timezone from timedatectl (Linux)
        result = subprocess.run(['timedatectl', 'show', '--property=Timezone', '--value'], 
                              capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    
    try:
        # Fallback: read from /etc/timezone (Debian/Ubuntu)
        with open('/etc/timezone', 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        pass
    
    try:
        # Fallback: resolve /etc/localtime symlink
        localtime_path = os.readlink('/etc/localtime')
        if '/zoneinfo/' in localtime_path:
            return localtime_path.split('/zoneinfo/', 1)[1]
    except (OSError, IndexError):
        pass
    
    # Final fallback: use time module
    if time.daylight:
        return time.tzname[1]
    else:
        return time.tzname[0]

def get_image_datetime(image_path, timezone_info=None):
    """Extract datetime from image EXIF data and apply timezone if provided"""
    try:
        with Image.open(image_path) as img:
            exif_data = img._getexif()
            if exif_data:
                for tag_id, value in exif_data.items():
                    tag = TAGS.get(tag_id, tag_id)
                    if tag == "DateTime" or tag == "DateTimeOriginal":
                        dt = datetime.strptime(value, "%Y:%m:%d %H:%M:%S")
                        if timezone_info:
                            # Assume the EXIF datetime is in UTC and convert to target timezone
                            dt_utc = dt.replace(tzinfo=ZoneInfo('UTC'))
                            dt = dt_utc.astimezone(timezone_info)
                        return dt
    except Exception:
        pass
    
    # Fallback to file modification time
    dt = datetime.fromtimestamp(os.path.getmtime(image_path))
    if timezone_info:
        # Convert from system timezone to target timezone
        dt_local = dt.replace(tzinfo=ZoneInfo(get_system_timezone()))
        dt = dt_local.astimezone(timezone_info)
    return dt

def get_image_content_hash(file_path):
    """Generate hash for image content only, ignoring metadata"""
    try:
        with Image.open(file_path) as img:
            # Convert to RGB to normalize format and remove metadata
            if img.mode != 'RGB':
                # For images with transparency or other modes, we need to handle them carefully
                if img.mode in ('RGBA', 'LA'):
                    # Create white background for transparent images
                    background = Image.new('RGB', img.size, (255, 255, 255))
                    if img.mode == 'RGBA':
                        background.paste(img, mask=img.split()[-1])  # Use alpha channel as mask
                    else:  # LA mode
                        background.paste(img.convert('RGB'))
                    img = background
                else:
                    img = img.convert('RGB')
            
            # Get raw image data without any metadata
            import io
            img_buffer = io.BytesIO()
            img.save(img_buffer, format='PNG', optimize=False)  # PNG to avoid JPEG compression differences
            img_data = img_buffer.getvalue()
            
            # Hash the raw image data
            return hashlib.md5(img_data).hexdigest()
    except Exception as e:
        print(f"Warning: Could not hash image content for {file_path}, falling back to file hash: {e}", file=sys.stderr)
        # Fallback to file hash if image processing fails
        return get_file_hash(file_path)

def get_file_hash(file_path):
    """Generate hash for entire file content (fallback method)"""
    hash_md5 = hashlib.md5()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def group_images_by_burst(image_files, timezone_info=None):
    """Group images by burst sequences (photos within 1 second of each other)"""
    # Get datetime for each image
    images_with_time = []
    for img_path in image_files:
        try:
            dt = get_image_datetime(img_path, timezone_info)
            images_with_time.append((img_path, dt))
        except Exception as e:
            print(f"Warning: Could not process {img_path}: {e}", file=sys.stderr)
            continue
    
    # Sort by datetime
    images_with_time.sort(key=lambda x: x[1])
    
    # Group into bursts
    bursts = []
    current_burst = []
    
    for img_path, img_time in images_with_time:
        if not current_burst:
            current_burst = [(img_path, img_time)]
        else:
            # Check if this image is within 1 second of the last image in current burst
            if hasattr(img_time, 'timestamp') and hasattr(current_burst[-1][1], 'timestamp'):
                time_diff = abs(img_time.timestamp() - current_burst[-1][1].timestamp())
            else:
                time_diff = abs((img_time - current_burst[-1][1]).total_seconds())
            
            if time_diff <= 1.0:
                current_burst.append((img_path, img_time))
            else:
                # Start new burst
                bursts.append(current_burst)
                current_burst = [(img_path, img_time)]
    
    if current_burst:
        bursts.append(current_burst)
    
    return bursts

def create_filename(dt, seq_num, extension):
    """Create filename in format YYYY_MM_DD___HHhMMm___N.ext"""
    base_name = dt.strftime("%Y_%m_%d___%Hh%Mm")
    return f"{base_name}___{seq_num}{extension}"

def create_sorted_filename(dt, seq_num, extension):
    """Create filename for sorted folders (without date part)"""
    time_part = dt.strftime("%Hh%Mm")
    return f"{time_part}___{seq_num}{extension}"

def find_existing_image_by_content(source_path, target_dir):
    """Find if an image with the same content already exists in target directory"""
    if not target_dir.exists():
        return None
    
    source_hash = get_image_content_hash(source_path)
    
    # Check all files in target directory
    for existing_file in target_dir.iterdir():
        if existing_file.is_file() and existing_file.suffix.lower() in image_extensions:
            if get_image_content_hash(existing_file) == source_hash:
                return existing_file
    
    return None

def image_content_matches(source_path, target_path):
    """Check if two images have the same content (ignoring metadata)"""
    if not os.path.exists(target_path):
        return False
    
    return get_image_content_hash(source_path) == get_image_content_hash(target_path)

def ask_yes_no(question, default=False):
    """Ask a yes/no question and return True/False"""
    suffix = " (y/N): " if not default else " (Y/n): "
    while True:
        response = input(question + suffix).strip().lower()
        if response in ['y', 'yes']:
            return True
        elif response in ['n', 'no']:
            return False
        elif response == '':
            return default
        else:
            print("Please answer 'y' or 'n'")

def determine_timezone(args):
    """Determine which timezone to use based on arguments and user input"""
    # If UTC flag is set, don't use any timezone conversion
    if args.utc:
        print("Using UTC time from metadata (no timezone conversion)")
        return None
    
    # If timezone is explicitly provided
    if args.timezone:
        try:
            timezone_info = ZoneInfo(args.timezone)
            print(f"Using timezone: {args.timezone}")
            return timezone_info
        except Exception as e:
            print(f"Error: Invalid timezone '{args.timezone}': {e}")
            sys.exit(1)
    
    # If system timezone flag is set
    if args.system_timezone:
        try:
            system_tz = get_system_timezone()
            timezone_info = ZoneInfo(system_tz)
            print(f"Using system timezone: {system_tz}")
            return timezone_info
        except Exception as e:
            print(f"Error: Could not use system timezone: {e}")
            sys.exit(1)
    
    # Interactive mode: ask user what to do
    print("No timezone specified.")
    
    # Try to detect system timezone and ask if user wants to use it
    try:
        system_tz = get_system_timezone()
        print(f"Detected system timezone: {system_tz}")
        if ask_yes_no(f"Use system timezone ({system_tz})?"):
            timezone_info = ZoneInfo(system_tz)
            print(f"Using system timezone: {system_tz}")
            return timezone_info
    except Exception as e:
        print(f"Could not detect system timezone: {e}")
    
    # Ask if user wants to use UTC
    if ask_yes_no("Use UTC time from metadata (no timezone conversion)?"):
        print("Using UTC time from metadata")
        return None
    
    # Ask user to specify timezone
    while True:
        tz_input = input("Please enter timezone (e.g., Europe/Lisbon, America/New_York): ").strip()
        if not tz_input:
            print("Timezone cannot be empty")
            continue
        try:
            timezone_info = ZoneInfo(tz_input)
            print(f"Using timezone: {tz_input}")
            return timezone_info
        except Exception as e:
            print(f"Invalid timezone '{tz_input}': {e}")
            if ask_yes_no("Try again?", default=True):
                continue
            else:
                print("Exiting...")
                sys.exit(1)

def process_images(source_dir, target_parent_dir, timezone_info=None):
    """Main processing function"""
    source_path = Path(source_dir)
    target_parent_path = Path(target_parent_dir)
    
    # Create photos directory
    photos_dir = target_parent_path / "photos"
    photos_dir.mkdir(parents=True, exist_ok=True)
    
    image_files = []
    
    for file_path in source_path.rglob('*'):
        if file_path.is_file() and file_path.suffix.lower() in image_extensions:
            image_files.append(file_path)
    
    if not image_files:
        print("No image files found in source directory")
        return
    
    # Group images into bursts
    bursts = group_images_by_burst(image_files, timezone_info)
    
    # Process each burst
    for burst in bursts:
        for seq_num, (img_path, img_time) in enumerate(burst, 1):
            extension = img_path.suffix
            
            # Check if this image already exists anywhere in photos directory
            existing_file = find_existing_image_by_content(img_path, photos_dir)
            if existing_file:
                print(f"? {existing_file.name} (content already exists)")
                continue
            
            # Create main filename
            main_filename = create_filename(img_time, seq_num if len(burst) > 1 else 1, extension)
            main_target_path = photos_dir / main_filename
            
            # If filename exists but content is different, find a new sequence number
            original_seq_num = seq_num if len(burst) > 1 else 1
            while main_target_path.exists() and not image_content_matches(img_path, main_target_path):
                original_seq_num += 1
                main_filename = create_filename(img_time, original_seq_num, extension)
                main_target_path = photos_dir / main_filename
            
            # Copy to main photos directory
            if not main_target_path.exists():
                shutil.copy2(img_path, main_target_path)
                print(f"+ {main_filename}")
                main_exists = False
            else:
                print(f"? {main_filename} (identical content)")
                main_exists = True
            
            # Create sorted directory structure
            year_dir = target_parent_path / str(img_time.year)
            month_dir = year_dir / f"{img_time.month:02d}"
            day_dir = month_dir / f"{img_time.day:02d}"
            day_dir.mkdir(parents=True, exist_ok=True)
            
            # Create hardlink in sorted directory
            sorted_filename = create_sorted_filename(img_time, original_seq_num, extension)
            sorted_target_path = day_dir / sorted_filename
            
            if not sorted_target_path.exists():
                try:
                    os.link(main_target_path, sorted_target_path)
                except OSError:
                    # If hardlink fails, copy instead
                    shutil.copy2(main_target_path, sorted_target_path)

def main():
    parser = argparse.ArgumentParser(description='Organize photos with burst detection and date-based sorting')
    parser.add_argument('source_dir', help='Source directory containing images')
    parser.add_argument('target_parent_dir', help='Target parent directory (photos folder will be created inside)')
    
    # Timezone options
    tz_group = parser.add_mutually_exclusive_group()
    tz_group.add_argument('-u', '--utc', action='store_true', 
                         help='Use UTC time from metadata (no timezone conversion)')
    tz_group.add_argument('-t', '--timezone', type=str, 
                         help='Specify timezone (e.g., Europe/Lisbon, America/New_York)')
    tz_group.add_argument('-s', '--system-timezone', action='store_true',
                         help='Use system timezone')
    
    args = parser.parse_args()
    
    if not os.path.isdir(args.source_dir):
        print(f"Error: Source directory '{args.source_dir}' does not exist")
        sys.exit(1)
    
    # Determine timezone
    timezone_info = determine_timezone(args)
    
    try:
        process_images(args.source_dir, args.target_parent_dir, timezone_info)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
