var http = require('http');
var fs = require('fs');
var url = require("url");
var p = require("path");

var fpath = '/usr/local/tomcat/logs';


//var filesList = geFileList(fpath);

function sendError(errCode, errString, response)
{
  response.writeHead(errCode, {"Content-Type": "text/plain"});
  response.write(errString + "\n");
  response.end();
  return;
}

function geFileList(path)
{
 	var filesList = [];
 	readFile(path,filesList);
 	return filesList;i

}
function readFile(path,filesList)
{
 files = fs.readdirSync(path);//需要用到同步读取
 files.forEach(walk);
 function walk(file)
 { 
  states = fs.statSync(path+'/'+file);   
  if(states.isDirectory())
  {
   readFile(path+'/'+file,filesList);
  }
  else
  { 
   //创建一个对象保存信息
   var obj = new Object();
   obj.size = states.size;//文件大小，以字节为单位
   obj.name = file;//文件名
   obj.path = path+'/'+file; //文件绝对路径
   filesList.push(obj);
  }  
}
}



function getFile(exists, response, localpath)
{
  if(!exists) return sendError(404, '404 Not Found', response);
  fs.readFile(localpath, "binary",
    function(err, file){ sendFile(err, file, response);});
}


function sendFile(err, file, response)
{
  if(err) return sendError(500, err, response);
  response.writeHead(200);
response.write("<br/><a href='/'>BACK LOGS SERVICE HOME PAGE</a><br/>");
  response.write(file, "binary");
  response.end();
} 



var server = http.createServer(function (request, response) {
        //response.writeHead(200, {"Content-Type": "text/plain"});
//var v = request.url.replace("/query?file=",'');
response.writeHead(200, {'Content-type' : 'text/html'});

//response.write("<br/><a href='/'>BACK LOGS SERVICE HOME PAGE</a>");
var urlpath = url.parse(request.url).pathname;
  var localpath = fpath+""+urlpath;//p.join(process.cwd(), urlpath);
console.log(localpath);
  fs.exists(localpath, function(result) { getFile(result, response, localpath)  
return;
});

//return;

/*
fs.exists(fpath+""+v, function (exists) {
//  util.debug(exists ? "it's there" : "no file!");
if(exists == true){
//response.write("file has");
var file = fs.readFileSync(fpath + ''+v, 'binary');
//response.end("sdfsdf");
// res.setHeader('Content-Length', file.length);
//  res.write(file, 'utf-8');
 // res.end();
response.writeHead(200);
  response.write(file, "binary");
  response.end();
}
});
*/
if(urlpath=="/"){

var filesList = geFileList(fpath);
	var str='';
for(var i=0;i<filesList.length;i++)
{
 var item = filesList[i];
 var desc ="<a href='./"+item.name+"' >"+item.name + " "+"----- file size:"+(item.size/1024).toFixed(2) +"/kb </a><br/>";
 str+=desc +"\n";
}	
	response.write(str+"<br/><a href='/'>BACK LOGS SERVICE HOME PAGE</a>");
}
});
server.listen(8088);

console.log("Server running at http://127.0.0.1:88/");
