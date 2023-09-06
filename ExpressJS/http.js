const http = require("http");
const server = http.createServer();
const callback = function(request, response) {
    response.writeHead(200, {
        "Content-Type": "text/plain"
    });
    response.end("Hello world!\n");
};
server.on("request", callback);
server.listen(3000);