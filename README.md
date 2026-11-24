# LAB9 CI/CD com FastAPI

Gabriel Ferreira Moreno · GitHub mrnbiel · Docker Hub gabrielmrn

## Execução local

```sh
python -m pip install -r requirements-dev.txt
python -m pytest
python -m uvicorn app.main:app
```

A API responde em `/` e `/health`. Para executar o contêiner na porta 8080:

```sh
docker build -t senai-fastapi:local .
docker run --rm -p 8080:8000 senai-fastapi:local
```

## Pipeline

Pull requests para `main` executam testes e build sem publicação.
Push em `develop` publica a imagem e implanta em homologação na porta 8080.
Push em `main` publica a imagem e solicita aprovação no Environment
`producao` antes de implantar na porta 80. Os servidores recebem a imagem
pelo digest publicado no mesmo run.

Configure `Required reviewers` e desative o bypass de administradores no
Environment `producao` antes do primeiro push do workflow em `main`.
Restrinja `homologacao` a `develop` e `producao` a `main`.
Proteja `main` para receber alterações via pull request.

Secrets de repositório: `DOCKERHUB_USERNAME` e `DOCKERHUB_TOKEN`.
Em cada Environment, configure `EC2_HOST`, `EC2_USERNAME`, `EC2_SSH_KEY`
e `EC2_KNOWN_HOSTS` com a chave pública do host SSH verificada por canal
independente. O repositório de imagem `gabrielmrn/senai_fastapi` deve ser
público para que as instâncias consigam baixá-la sem credenciais do registro.
