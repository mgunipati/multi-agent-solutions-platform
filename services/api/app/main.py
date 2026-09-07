from fastapi import FastAPI, HTTPException, status

from .config import settings
from .models import AgentDefinition, ProductDefinition, RunRequest, SolutionDefinition
from .registry import registry

app = FastAPI(title=settings.app_name)


@app.get("/health", tags=["operations"])
def health() -> dict[str, str]:
    return {"status": "ok", "environment": settings.environment}


@app.get("/v1/products", response_model=list[ProductDefinition], tags=["control-plane"])
def list_products() -> list[ProductDefinition]:
    return registry.list_products()


@app.post(
    "/v1/products",
    response_model=ProductDefinition,
    status_code=status.HTTP_201_CREATED,
    tags=["control-plane"],
)
def register_product(product: ProductDefinition) -> ProductDefinition:
    return registry.register_product(product)


@app.get("/v1/solutions", response_model=list[SolutionDefinition], tags=["control-plane"])
def list_solutions() -> list[SolutionDefinition]:
    return registry.list()


@app.post(
    "/v1/solutions",
    response_model=SolutionDefinition,
    status_code=status.HTTP_201_CREATED,
    tags=["control-plane"],
)
def register_solution(solution: SolutionDefinition) -> SolutionDefinition:
    if not registry.has_product(solution.product_id):
        raise HTTPException(status_code=422, detail="Product is not registered")
    missing = [
        f"{binding.agent_id}@{binding.agent_version}"
        for binding in solution.agents
        if not registry.has_agent(binding.agent_id, binding.agent_version)
    ]
    if missing:
        raise HTTPException(status_code=422, detail={"unregistered_agents": missing})
    excessive_grants = []
    for binding in solution.agents:
        agent = registry.get_agent(binding.agent_id, binding.agent_version)
        if agent and not set(binding.enabled_tools).issubset(agent.allowed_tools):
            excessive_grants.append(f"{binding.agent_id}@{binding.agent_version}")
    if excessive_grants:
        raise HTTPException(status_code=422, detail={"tool_grants_exceed_agent": excessive_grants})
    return registry.register(solution)


@app.get("/v1/agents", response_model=list[AgentDefinition], tags=["agent-registry"])
def list_agents() -> list[AgentDefinition]:
    return registry.list_agents()


@app.post(
    "/v1/agents",
    response_model=AgentDefinition,
    status_code=status.HTTP_201_CREATED,
    tags=["agent-registry"],
)
def register_agent(agent: AgentDefinition) -> AgentDefinition:
    return registry.register_agent(agent)


@app.post("/v1/solutions/{solution_id}/runs", status_code=status.HTTP_202_ACCEPTED, tags=["runtime"])
def start_run(solution_id: str, request: RunRequest) -> dict[str, str]:
    if registry.get(solution_id) is None:
        raise HTTPException(status_code=404, detail="Solution not found")
    # The durable orchestrator will replace this contract stub.
    return {"solution_id": solution_id, "status": "accepted", "objective": request.objective}
