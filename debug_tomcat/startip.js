http = require("http"),
path = require("path"),
url = require("url"),
fs = require("fs");

function sendError(errCode, errString, response)
{
  response.writeHead(errCode, {"Content-Type": "text/plain"});
  response.write(errString + "\n");
  response.end();
  return;
}

function sendFile(err, file, response)
{
  if(err) return sendError(500, err, response);
  response.writeHead(200);
  response.write(file, "binary");
  response.end();
}

function getFile(exists, response, localpath)
{
  if(!exists) return sendError(404, '404 Not Found', response);
  fs.readFile(localpath, "binary",
   function(err, file){ sendFile(err, file, response);});
}

function getFilename(request, response)
{
  var urlpath = url.parse(request.url).pathname; // following domain or IP and port
  var localpath = path.join(process.cwd(), urlpath); // if we are at root
  path.exists(localpath, function(result) { getFile(result, response, localpath)});
}

var server = http.createServer(getFilename);
server.listen(1000);
console.log("Server available..."); 
