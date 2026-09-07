from enum import StrEnum

from pydantic import BaseModel, Field


class AgentRole(StrEnum):
    SUPERVISOR = "supervisor"
    SPECIALIST = "specialist"
    VALIDATOR = "validator"


class AgentDefinition(BaseModel):
    agent_id: str = Field(pattern=r"^[a-z][a-z0-9-]{2,62}$")
    version: str = Field(pattern=r"^\d+\.\d+\.\d+$")
    name: str
    role: AgentRole
    instructions_ref: str
    allowed_tools: list[str] = Field(default_factory=list)
    max_steps: int = Field(default=8, ge=1, le=30)


class AgentBinding(BaseModel):
    agent_id: str
    agent_version: str
    enabled_tools: list[str] = Field(default_factory=list)
    data_policy_ref: str


class ProductDefinition(BaseModel):
    product_id: str = Field(pattern=r"^[a-z][a-z0-9-]{2,62}$")
    name: str
    owner: str
    data_classification: str


class SolutionDefinition(BaseModel):
    solution_id: str = Field(pattern=r"^[a-z][a-z0-9-]{2,62}$")
    product_id: str = Field(pattern=r"^[a-z][a-z0-9-]{2,62}$")
    name: str
    description: str
    agents: list[AgentBinding] = Field(min_length=1)


class RunRequest(BaseModel):
    objective: str = Field(min_length=1, max_length=8_000)
    context: dict[str, str] = Field(default_factory=dict)
