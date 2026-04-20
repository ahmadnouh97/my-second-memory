import httpx
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import Response

from app.auth import get_current_user

router = APIRouter(dependencies=[Depends(get_current_user)])

_HEADERS = {"User-Agent": "Mozilla/5.0"}


@router.get("/image")
async def proxy_image(url: str = Query(...)):
    """Fetch an external image server-side and return it.

    Needed for Flutter web: browsers block cross-origin image loads from
    CDNs (e.g. Instagram's fbcdn.net) that don't send CORS headers.
    """
    async with httpx.AsyncClient(follow_redirects=True, timeout=10) as client:
        try:
            res = await client.get(url, headers=_HEADERS)
            res.raise_for_status()
        except httpx.HTTPError as exc:
            raise HTTPException(status_code=502, detail=f"Failed to fetch image: {exc}")

    content_type = res.headers.get("content-type", "image/jpeg")
    return Response(content=res.content, media_type=content_type)
