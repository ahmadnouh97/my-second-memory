from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str
    groq_api_key: str
    google_api_key: str
    app_env: str = "development"
    cors_origins: str = "http://localhost:8100,http://localhost:4200"
    tag_normalize_threshold: float = 0.88
    tag_consolidate_threshold: float = 0.85

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",")]


settings = Settings()
