export async function handleRequest(request) {
  return {
    status: 200,
    headers: {
      "server": "spin",
      "content-type": "application/json"
    },
    body: JSON.stringify({ message: "Hello, world!" })
  }
}
