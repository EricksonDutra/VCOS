# VCOS Backend

API do VCOS criada com FastAPI, preparada para rodar localmente e em VPS com Docker.

## Requisitos

- Python 3.12+
- Docker e Docker Compose para o fluxo recomendado

## Rodando com Docker

Na raiz do projeto:

```bash
docker compose up -d --build
```

Teste a API:

```bash
curl http://localhost:8000/api/v1/health
```

Documentacao interativa:

```text
http://localhost:8000/docs
```

## Rodando sem Docker

Dentro da pasta `backend/`:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
uvicorn app.main:app --reload
```

## Endpoints iniciais

```text
GET    /api/v1/health
GET    /api/v1/sales
POST   /api/v1/sales
GET    /api/v1/sales/{sale_id}
PUT    /api/v1/sales/{sale_id}
DELETE /api/v1/sales/{sale_id}

GET    /api/v1/expenses
POST   /api/v1/expenses
GET    /api/v1/expenses/{expense_id}
PUT    /api/v1/expenses/{expense_id}
DELETE /api/v1/expenses/{expense_id}

GET    /api/v1/settings
PUT    /api/v1/settings
```

Por padrao, o ambiente local usa SQLite em `backend/vcos.db`. Na VPS, troque `DATABASE_URL` no `backend/.env` para o banco de producao.

## Deploy inicial em VPS

Fluxo sugerido:

```bash
git clone <seu-repositorio>
cd vcos
cp backend/.env.example backend/.env
docker compose up -d --build
```

Depois, coloque Caddy ou Nginx na frente para dominio e HTTPS.
