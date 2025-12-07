using Example.Api.Configuration;
using Example.Api.Services;

var builder = WebApplication.CreateBuilder(args)
    .Configure();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapGet("/message", (IService service) =>
    {
        return service.GetMessage();
    })
    .WithName("GetMessage");

app.Run();