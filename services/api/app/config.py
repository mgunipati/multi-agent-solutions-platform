from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "multi-agent-solutions-api"
    environment: str = "local"
    aws_region: str = "us-west-2"

    model_config = SettingsConfigDict(env_file=".env", env_prefix="KP_")


settings = Settings()
