using Microsoft.Extensions.Options;
using Example.Api.Configuration;

namespace Example.Api.Services;

public class Service(IOptions<MySettings> options) : IService
{
    public string GetMessage()
    {
        return options.Value.Message;
    }
}