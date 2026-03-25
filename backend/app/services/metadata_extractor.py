import re
from dataclasses import dataclass, field
from urllib.parse import urlparse

import requests
import trafilatura
import yt_dlp
from bs4 import BeautifulSoup

YOUTUBE_DOMAINS = {"youtube.com", "youtu.be", "www.youtube.com", "m.youtube.com"}
INSTAGRAM_DOMAINS = {"instagram.com", "www.instagram.com"}
LINKEDIN_DOMAINS = {"linkedin.com", "www.linkedin.com"}
GITHUB_DOMAINS = {"github.com", "www.github.com"}
FACEBOOK_DOMAINS = {"facebook.com", "www.facebook.com", "fb.com", "m.facebook.com"}
TIKTOK_DOMAINS = {"tiktok.com", "www.tiktok.com", "vm.tiktok.com", "vt.tiktok.com"}
REDDIT_DOMAINS = {"reddit.com", "www.reddit.com", "old.reddit.com", "new.reddit.com"}

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    )
}


@dataclass
class RawMetadata:
    url: str
    content_type: str  # youtube | instagram | linkedin | github | facebook | tiktok | reddit | other
    raw_title: str | None = None
    description: str | None = None
    thumbnail_url: str | None = None
    content: str | None = None  # article body
    extra: dict = field(default_factory=dict)


def detect_content_type(url: str) -> str:
    domain = urlparse(url).netloc.lower()
    if domain in YOUTUBE_DOMAINS:
        return "youtube"
    if domain in INSTAGRAM_DOMAINS:
        return "instagram"
    if domain in LINKEDIN_DOMAINS:
        return "linkedin"
    if domain in GITHUB_DOMAINS:
        return "github"
    if domain in FACEBOOK_DOMAINS:
        return "facebook"
    if domain in TIKTOK_DOMAINS:
        return "tiktok"
    if domain in REDDIT_DOMAINS:
        return "reddit"
    return "other"


def extract_metadata(url: str) -> RawMetadata:
    content_type = detect_content_type(url)
    if content_type == "youtube":
        return _extract_youtube(url)
    if content_type == "instagram":
        return _extract_instagram(url)
    if content_type == "linkedin":
        return _extract_linkedin(url)
    if content_type == "github":
        return _extract_github(url)
    if content_type == "facebook":
        return _extract_facebook(url)
    if content_type == "tiktok":
        return _extract_tiktok(url)
    if content_type == "reddit":
        return _extract_reddit(url)
    return _extract_opengraph(url, content_type="other")


def _youtube_video_id(url: str) -> str | None:
    for pattern in (r"youtu\.be/([^?&/]+)", r"[?&]v=([^?&]+)"):
        m = re.search(pattern, url)
        if m:
            return m.group(1)
    return None


def _extract_youtube(url: str) -> RawMetadata:
    ydl_opts = {
        "quiet": True,
        "no_warnings": True,
        "skip_download": True,
        "extract_flat": False,
        "ignoreerrors": False,
    }
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            thumbnail = None

            if info.get("thumbnail"):
                thumbnail = info.get("thumbnail")
            elif info.get("thumbnails"):
                thumbnail = info["thumbnails"][-1].get("url")
            else:
                thumbnail = f"https://i.ytimg.com/vi/{info.get('id')}/maxresdefault.jpg"

            return RawMetadata(
                url=url,
                content_type="youtube",
                raw_title=info.get("title"),
                description=info.get("description", "")[:2000],
                thumbnail_url=thumbnail,
                extra={
                    "uploader": info.get("uploader"),
                    "duration": info.get("duration"),
                    "view_count": info.get("view_count"),
                    "upload_date": info.get("upload_date"),
                    "tags": info.get("tags", [])[:20],
                },
            )
    except Exception:
        pass

    # Fallback: YouTube oEmbed API (no key required)
    return _extract_youtube_oembed(url)


def _extract_youtube_oembed(url: str) -> RawMetadata:
    video_id = _youtube_video_id(url)
    try:
        resp = requests.get(
            "https://www.youtube.com/oembed",
            params={"url": url, "format": "json"},
            headers=HEADERS,
            timeout=10,
        )
        resp.raise_for_status()
        data = resp.json()
        thumbnail = data.get("thumbnail_url") or (
            f"https://i.ytimg.com/vi/{video_id}/hqdefault.jpg" if video_id else None
        )
        return RawMetadata(
            url=url,
            content_type="youtube",
            raw_title=data.get("title"),
            thumbnail_url=thumbnail,
            extra={"uploader": data.get("author_name")},
        )
    except Exception as exc:
        # Last resort: build thumbnail from video ID
        thumbnail = f"https://i.ytimg.com/vi/{video_id}/hqdefault.jpg" if video_id else None
        return RawMetadata(url=url, content_type="youtube", thumbnail_url=thumbnail, extra={"error": str(exc)})


def _extract_instagram(url: str) -> RawMetadata:
    # Try yt-dlp first (works for public posts without login)
    ydl_opts = {"quiet": True, "no_warnings": True, "skip_download": True}
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            thumbnail = info.get("thumbnail")
            return RawMetadata(
                url=url,
                content_type="instagram",
                raw_title=info.get("title") or info.get("description", "")[:100],
                description=info.get("description", "")[:2000],
                thumbnail_url=thumbnail,
                extra={"uploader": info.get("uploader")},
            )
    except Exception:
        pass

    # Fallback: OpenGraph scraping
    return _extract_opengraph(url, content_type="instagram")


def _extract_linkedin(url: str) -> RawMetadata:
    return _extract_opengraph(url, content_type="linkedin")


def _extract_github(url: str) -> RawMetadata:
    return _extract_opengraph(url, content_type="github")


def _extract_facebook(url: str) -> RawMetadata:
    return _extract_opengraph(url, content_type="facebook")


def _extract_tiktok(url: str) -> RawMetadata:
    # Try yt-dlp first (works for public TikTok videos)
    ydl_opts = {"quiet": True, "no_warnings": True, "skip_download": True}
    try:
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(url, download=False)
            return RawMetadata(
                url=url,
                content_type="tiktok",
                raw_title=info.get("title") or info.get("description", "")[:100],
                description=info.get("description", "")[:2000],
                thumbnail_url=info.get("thumbnail"),
                extra={"uploader": info.get("uploader")},
            )
    except Exception:
        pass

    return _extract_opengraph(url, content_type="tiktok")


def _extract_reddit(url: str) -> RawMetadata:
    return _extract_opengraph(url, content_type="reddit")


def _extract_opengraph(url: str, content_type: str = "other") -> RawMetadata:
    try:
        response = requests.get(url, headers=HEADERS, timeout=10)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, "lxml")

        def og(prop: str) -> str | None:
            tag = soup.find("meta", property=f"og:{prop}") or soup.find("meta", attrs={"name": prop})
            return tag.get("content") if tag else None

        title = og("title") or (soup.title.string.strip() if soup.title else None)
        description = og("description")
        thumbnail = og("image")

        return RawMetadata(
            url=url,
            content_type=content_type,
            raw_title=title,
            description=description,
            thumbnail_url=thumbnail,
        )
    except Exception as exc:
        return RawMetadata(url=url, content_type=content_type, extra={"error": str(exc)})
