var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers(); // Add controllers (API endpoints)

var app = builder.Build();

app.UseHttpsRedirection();
app.UseAuthorization();

app.MapControllers();

app.Run();
