const { app } = require('@azure/functions');

app.http('json', {
    methods: ['GET'],
    authLevel: 'anonymous',
    handler: async (request, context) => {
      return {
        status: 200,
        body: JSON.stringify({ message: 'Hello World!' }),
        headers: {
          'server': 'azure-functions',
          'content-type': 'application/json'
        }
      };
    }
});
