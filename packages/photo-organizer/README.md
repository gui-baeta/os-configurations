# Photo Organizer

A Python script for organizing photos with burst detection, timezone handling,
and automatic date-based sorting.

## Features

- ** Smart Burst Detection**: Automatically groups photos taken within 1 second of each other
- ** Timezone Support**: Converts UTC EXIF timestamps to your local timezone with multiple options
- ** Dual Organization System**:
  - Main photos directory with with time and date in the name
  - Date-sorted directories (YYYY/MM/DD) with hardlinks for efficient storage
- ** Duplicate Protection**: Uses content hashing to prevent overwrites of existing files
- ** Wide Format Support**: Handles JPEG, PNG, TIFF, and RAW formats (CR2, NEF, ARW, DNG)
- ** Efficient Storage**: Creates hardlinks instead of duplicates when possible
- ** Non-destructive**: Copies files, never moves or deletes originals

## Installation

### Using Nix (Recommended)

```bash
# Run directly with nix-shell from this directory
nix-shell --run "po --help"

# Or enter development environment
nix-shell
po source_dir target_dir
```

### Manual Installation

Requires Python 3.9+ and Pillow:

```bash
pip install Pillow
python po source_dir target_dir
```

## Usage

```bash
po <source_directory> <target_parent_directory> [OPTIONS]
```

### Timezone Options

| Option | Description |
|--------|-------------|
| `-u, --utc` | Use UTC time from metadata (no conversion) |
| `-t, --timezone TIMEZONE` | Specify timezone (e.g., `Europe/Lisbon`, `America/New_York`) |
| `-s, --system-timezone` | Use system timezone |
| (no option) | Interactive mode - prompts for timezone preference |

### Examples

```bash
# Use specific timezone
po ~/camera-photos ~/organized-photos --timezone Europe/Lisbon

# Use UTC timestamps (no conversion)
po ~/camera-photos ~/organized-photos --utc

# Use system timezone automatically
po ~/camera-photos ~/organized-photos --system-timezone

# Interactive mode (asks for timezone preference)
po ~/camera-photos ~/organized-photos
```

## File Organization

### Naming Convention

- **Main photos**: `YYYY_MM_DD___HHhMMm___N.ext`
- **Sorted folders**: `HHhMMm___N.ext`

Where:
- `N` is the sequence number for burst photos (1, 2, 3...)
- Single photos use sequence number 1
- `___` (triple underscore) separates date, time, and sequence

### Directory Structure

```
target_directory/
├── photos/                           # Main photos directory
│   ├── 2024_03_15___14h30m___1.jpg   # Single photo
│   ├── 2024_03_15___16h45m___1.jpg   # Burst photo 1
│   └── 2024_03_15___16h45m___2.jpg   # Burst photo 2
├── 2024/                             # Year-based organization
│   └── 03/                           # Month
│       └── 15/                       # Day
│           ├── 14h30m___1.jpg        # Hardlinks to main photos
│           ├── 16h45m___1.jpg
│           └── 16h45m___2.jpg
```

## Output

The script provides clear feedback during operation:

- `+ filename` - New file added
- `? filename` - File already exists (skipped)

## Interactive Timezone Selection

When no timezone option is provided, the script will:

1. **Auto-detect** system timezone and ask if you want to use it
2. **Offer UTC option** if system timezone is declined
3. **Prompt for manual entry** with validation if needed
4. **Retry mechanism** for invalid timezone entries

## Burst Detection

Photos are automatically grouped into bursts based on timing:

- Photos taken within **1 second** of each other are considered a burst
- Useful for HDR, bracketing, or rapid-fire photography
- Each photo in a burst gets a sequential number (1, 2, 3...)

## Supported Formats

| Format | Extensions |
|--------|------------|
| JPEG | `.jpg`, `.jpeg` |
| PNG | `.png` |
| TIFF | `.tiff`, `.tif` |
| RAW | `.raw`, `.cr2`, `.nef`, `.arw`, `.dng` |

## Technical Details

### Dependencies
- **Python 3.9+** (for zoneinfo support)
- **Pillow** (for EXIF data extraction)

### EXIF Handling
- Extracts timestamps from `DateTime` or `DateTimeOriginal` EXIF tags
- Falls back to file modification time if EXIF unavailable
- Assumes EXIF timestamps are in UTC (common camera behavior)

### Safety Features
- **Content comparison** using MD5 hashing prevents accidental overwrites
- **Hardlink fallback** to copying if filesystem doesn't support hardlinks
- **Preserves timestamps** and file metadata
- **Non-destructive operation** - originals remain untouched

## License

MIT License - feel free to use and modify as needed.

## Contributing

Issues and pull requests welcome! Please ensure any changes maintain backward compatibility and include appropriate tests.
