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

def get_file_hash(file_path):
    """Generate hash for file content comparison"""
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

def file_exists_and_same(source_path, target_path):
    """Check if target file exists and has same content as source"""
    if not os.path.exists(target_path):
        return False
    
    # Compare file sizes first (quick check)
    if os.path.getsize(source_path) != os.path.getsize(target_path):
        return False
    
    # Compare file hashes
    return get_file_hash(source_path) == get_file_hash(target_path)

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
    
    # Find all image files
    image_extensions = {'.jpg', '.jpeg', '.png', '.tiff', '.tif', '.raw', '.cr2', '.orf', '.nef', '.arw', '.dng'}
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
            
            # Create main filename
            main_filename = create_filename(img_time, seq_num if len(burst) > 1 else 1, extension)
            main_target_path = photos_dir / main_filename
            
            # Check if file already exists in main photos directory
            if file_exists_and_same(img_path, main_target_path):
                print(f"? {main_filename}")
                # Still need to create hardlinks in sorted folders
                main_exists = True
            else:
                # Copy to main photos directory
                shutil.copy2(img_path, main_target_path)
                print(f"+ {main_filename}")
                main_exists = False
            
            # Create sorted directory structure
            year_dir = target_parent_path / str(img_time.year)
            month_dir = year_dir / f"{img_time.month:02d}"
            day_dir = month_dir / f"{img_time.day:02d}"
            day_dir.mkdir(parents=True, exist_ok=True)
            
            # Create hardlink in sorted directory
            sorted_filename = create_sorted_filename(img_time, seq_num if len(burst) > 1 else 1, extension)
            sorted_target_path = day_dir / sorted_filename
            
            if not sorted_target_path.exists():
                try:
                    os.link(main_target_path, sorted_target_path)
                except OSError:
                    # If hardlink fails, copy instead
                    shutil.copy2(main_target_path, sorted_target_path)
            elif not main_exists:
                # If sorted file exists but main didn't, it might be a duplicate
                if not file_exists_and_same(main_target_path, sorted_target_path):
                    # Files are different, keep both
                    pass

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
