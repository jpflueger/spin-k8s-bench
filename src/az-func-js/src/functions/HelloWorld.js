const { app } = require('@azure/functions');
app.http('hello', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
        return {
            status: 200,
            headers: { "foo": "bar" },
            body: `Hello from JS Azure Function`
        };
    }
});
