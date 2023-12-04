import azure.functions as func
import datetime
import json
import logging

app = func.FunctionApp()

@app.function_name(name="hello")
@app.route(route="", auth_level=func.AuthLevel.ANONYMOUS)
def HelloWorld(req: func.HttpRequest) -> func.HttpResponse:
    return func.HttpResponse(
        "Hello from the Python Azure Function",
        status_code=200,
        headers={"Content-Type": "text/plain"}
    )
