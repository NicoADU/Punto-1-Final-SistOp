from mangum import Mangum
from fastapi import FastAPI
from fastapi.responses import JSONResponse
 
fastapi = FastAPI(title="Ejemplo FastAPI + Mangum")
 

mangum_handler = Mangum(fastapi, lifespan="off")
 
@fastapi.get("/", response_class=JSONResponse)
def root():
    return {"message": "API funcionando correctamente."}
 
@fastapi.get("/api/hello", response_class=JSONResponse)
def say_hello(name: str = "Mendez"):
    return {"message": f"Hola, {name}! Bienvenido a FastAPI en Lambda."}
 