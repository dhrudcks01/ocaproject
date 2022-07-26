using System;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Enums;
using Newtonsoft.Json;
using Microsoft.OpenApi.Models;
using System.Net;




namespace OCAProject
{
    public class PingHttpTrigger
    {

        private readonly IMyService _service;
        public PingHttpTrigger(IMyService service){
             this._service = service ?? throw new ArgumentNullException(nameof(service));
        }

        [FunctionName(nameof(PingHttpTrigger))] // 문자열로 하드코딩하는 것보다 참조하기 편해짐

        [OpenApiOperation(operationId: "Ping", tags: new[] {"greeting"})] 
        [OpenApiSecurity(schemeName: "function_key", schemeType: SecuritySchemeType.ApiKey, Name = "x-functions-key", In = OpenApiSecurityLocationType.Header)]
        [OpenApiParameter(name: "name", In = ParameterLocation.Query, Required=true, Description ="Name of ther pers")]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "application/json", bodyType: typeof(ResponseMessage), Description="Greeting Message")]
        
        public IActionResult Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "ping")] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string name = req.Query["name"];

            var result = this._service.GetMessage(name);

            var res = new ResponseMessage() { Message = result};

            return new OkObjectResult(res);
        }
    }

    public class ResponseMessage
    {
        [JsonProperty("response_message")]
        public string Message { get; set; }
    }
   

    public interface IMyService
    {
        string GetMessage(string name);
    }

    public class MyService : IMyService
    {
        public string GetMessage(string name)
        {
            string responseMessage = string.IsNullOrEmpty(name)
                ? "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."
                : $"Hello, {name}. This HTTP triggered function executed successfully.";

            return responseMessage;
        }
    } 
}
