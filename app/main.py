from fastapi import FastAPI

app = FastAPI(title="SENAI FastAPI")


@app.get("/")
def home() -> dict[str, str]:
    return {"message": "SENAI FastAPI"}


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "healthy"}
