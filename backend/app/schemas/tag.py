from pydantic import BaseModel


class TagCount(BaseModel):
    tag: str
    count: int


class RenameTagRequest(BaseModel):
    new_name: str
