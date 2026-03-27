using ShopBackend.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.UseUrls("http://0.0.0.0:5000");

// ===== ADD SERVICES =====
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ===== CORS =====
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader();
    });
});

// ===== DATABASE =====
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(
        builder.Configuration.GetConnectionString("Default"),
        ServerVersion.AutoDetect(
            builder.Configuration.GetConnectionString("Default")
        )
    )
);

var app = builder.Build();

// ===== BẬT CORS =====
app.UseCors("AllowAll");

// ===== STATIC FILE (wwwroot mặc định) =====
app.UseStaticFiles();

// ===== CẤU HÌNH FOLDER ẢNH =====
string uploadPath;

if (app.Environment.IsDevelopment())
{
    uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/uploads");
}
else
{
    uploadPath = "C:/server/uploads";
}

// ===== STATIC FILE CHO /uploads + FIX CORS =====
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadPath),
    RequestPath = "/uploads",

    OnPrepareResponse = ctx =>
    {
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Headers", "*");
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Methods", "*");
    }
});

// ===== DEV TOOL =====
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
