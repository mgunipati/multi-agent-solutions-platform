from fastapi.testclient import TestClient

from app.main import app


def test_register_and_start_solution() -> None:
    client = TestClient(app)
    product = {
        "product_id": "quality-product",
        "name": "Quality Product",
        "owner": "quality-platform-team",
        "data_classification": "confidential",
    }
    assert client.post("/v1/products", json=product).status_code == 201
    agent = {
        "agent_id": "review-supervisor",
        "version": "1.0.0",
        "name": "Review Supervisor",
        "role": "supervisor",
        "instructions_ref": "prompts/review-supervisor/v1",
        "allowed_tools": ["document-search"],
    }
    assert client.post("/v1/agents", json=agent).status_code == 201
    definition = {
        "solution_id": "quality-review",
        "product_id": "quality-product",
        "name": "Quality Review",
        "description": "Coordinates evidence review and validation.",
        "agents": [
            {
                "agent_id": "review-supervisor",
                "agent_version": "1.0.0",
                "enabled_tools": ["document-search"],
                "data_policy_ref": "policies/quality-review/dev",
            }
        ],
    }
    assert client.post("/v1/solutions", json=definition).status_code == 201
    response = client.post(
        "/v1/solutions/quality-review/runs", json={"objective": "Review the evidence"}
    )
    assert response.status_code == 202
    assert response.json()["status"] == "accepted"
