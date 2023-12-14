import azure.functions as func
import json

app = func.FunctionApp()

@app.route(route="json", auth_level=func.AuthLevel.ANONYMOUS)
def handle_json(req: func.HttpRequest) -> func.HttpResponse:
    body = json.dumps({ "message": "Hello, world!" })
    return func.HttpResponse(
        body=body,
        status_code=200,
        headers={ 
          "server": "azure-functions" 
        },
        mimetype="application/json",
    )