import re
from urllib.parse import urlparse, parse_qs

def extract_youtube_video_id(url):
    """Extract YouTube video ID from various YouTube URL formats"""
    if not url:
        return None
    
    # YouTube URL patterns
    patterns = [
        r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)',
        r'youtube\.com\/v\/([^&\n?#]+)',
        r'youtube\.com\/watch\?.*v=([^&\n?#]+)',
    ]
    
    for pattern in patterns:
        match = re.search(pattern, url)
        if match:
            return match.group(1)
    
    return None

def get_youtube_embed_url(url):
    """Convert YouTube URL to embed URL"""
    video_id = extract_youtube_video_id(url)
    if video_id:
        return f"https://www.youtube.com/embed/{video_id}"
    return url

def get_youtube_thumbnail_url(url):
    """Get YouTube video thumbnail URL"""
    video_id = extract_youtube_video_id(url)
    if video_id:
        return f"https://img.youtube.com/vi/{video_id}/maxresdefault.jpg"
    return None

def is_youtube_url(url):
    """Check if URL is a YouTube URL"""
    if not url:
        return False
    
    youtube_domains = ['youtube.com', 'youtu.be', 'www.youtube.com', 'm.youtube.com']
    parsed_url = urlparse(url)
    return parsed_url.netloc.lower() in youtube_domains