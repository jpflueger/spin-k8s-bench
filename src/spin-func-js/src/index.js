export async function handleRequest(request) {
    console.log(`Url: ${request.headers['spin-full-url']}`);
    return {
        status: 200,
        headers: { "foo": "bar" },
        body: "Hello from JS-SDK"
    }
}
