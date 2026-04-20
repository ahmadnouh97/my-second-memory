from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str
    groq_api_key: str
    google_api_key: str
    app_env: str = "development"
    cors_origins: str = "http://localhost:8100,http://localhost:4200"
    jwt_secret: str = "change-me-in-production"
    jwt_expire_minutes: int = 60 * 24 * 7  # 7 days
    registration_enabled: bool = True
    bcrypt_rounds: int = 12

    @model_validator(mode="after")
    def check_production_secret(self) -> "Settings":
        if self.app_env == "production" and self.jwt_secret == "change-me-in-production":
            raise ValueError("JWT_SECRET must be set to a secure value in production")
        return self

    @property
    def cors_origins_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",")]


settings = Settings()
