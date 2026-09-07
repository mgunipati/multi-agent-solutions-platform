from .models import AgentDefinition, ProductDefinition, SolutionDefinition


class SolutionRegistry:
    """In-memory contract placeholder; replace with a durable governed registry."""

    def __init__(self) -> None:
        self._solutions: dict[str, SolutionDefinition] = {}
        self._agents: dict[tuple[str, str], AgentDefinition] = {}
        self._products: dict[str, ProductDefinition] = {}

    def list_products(self) -> list[ProductDefinition]:
        return list(self._products.values())

    def register_product(self, product: ProductDefinition) -> ProductDefinition:
        self._products[product.product_id] = product
        return product

    def has_product(self, product_id: str) -> bool:
        return product_id in self._products

    def list_agents(self) -> list[AgentDefinition]:
        return list(self._agents.values())

    def register_agent(self, agent: AgentDefinition) -> AgentDefinition:
        self._agents[(agent.agent_id, agent.version)] = agent
        return agent

    def has_agent(self, agent_id: str, version: str) -> bool:
        return (agent_id, version) in self._agents

    def get_agent(self, agent_id: str, version: str) -> AgentDefinition | None:
        return self._agents.get((agent_id, version))

    def list(self) -> list[SolutionDefinition]:
        return list(self._solutions.values())

    def register(self, solution: SolutionDefinition) -> SolutionDefinition:
        self._solutions[solution.solution_id] = solution
        return solution

    def get(self, solution_id: str) -> SolutionDefinition | None:
        return self._solutions.get(solution_id)


registry = SolutionRegistry()
