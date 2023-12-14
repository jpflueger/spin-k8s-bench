from spin_http import Response
import json

def handle_request(request):
    body = json.dumps({ "message": "Hello, world!" })
    return Response(200,
                    {
                      "server": "spin",
                      "content-type": "application/json"
                    },
                    bytes(body, "utf-8"))
