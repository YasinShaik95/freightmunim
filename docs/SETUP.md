# docs/SETUP.md

## Tools

| Tool | Version | Why we need it | Install |
|---|---|---|---|
| .NET SDK | 10.x.x | Builds and runs all services | dotnet.microsoft.com |
| Docker Desktop | x.x.x | Runs PostgreSQL, RabbitMQ, Valkey | `brew install --cask docker-desktop` |
| PostgreSQL | 18.x | Local database client tooling | (installed manually) |
| pgAdmin | 4.x | Inspect tables and outbox rows | pgadmin.org |
| Git | x.x.x | Version control | `brew install git` |
| GitHub CLI | x.x.x | Repo, issues, auth | `brew install gh` |
| VS Code | x.x.x | Editor and debugger | `brew install --cask visual-studio-code` |
| Aspire CLI | x.x.x | Local orchestration and dashboard | `curl -sSL https://aspire.dev/install.sh \| bash` |
| Postman | x.x.x | API testing | `brew install --cask postman` |
| Mailpit | x.x.x | Catches test emails | `brew install mailpit` |

## Verify your setup

```bash
dotnet --version
docker run --rm hello-world
gh auth status
aspire --version
```

## Notes
- PostgreSQL port: local server uses 5432; Aspire containers must not use it.
- Postman collections are exported to /tests/postman.