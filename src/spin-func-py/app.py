from spin_http import Response


def handle_request(request):
    print(f"Url: {request.headers['spin-full-url']}")
    return Response(200,
                    {"content-type": "text/plain"},
                    bytes(f"Hello from the Python SDK", "utf-8"))
