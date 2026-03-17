
﻿using ShopBackend.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.UseUrls("http://0.0.0.0:5000");

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ===== FIX CORS =====
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy => policy
            .AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader());
});
// ====================

builder.Services.AddDbContext<AppDbContext>(options =>
options.UseMySql(
builder.Configuration.GetConnectionString("Default"),
ServerVersion.AutoDetect(
builder.Configuration.GetConnectionString("Default")
)));

var app = builder.Build();

// ===== CẤU HÌNH PATH ẢNH =====
app.UseStaticFiles();

string uploadPath;

if (app.Environment.IsDevelopment())
{
    uploadPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/uploads");
}
else
{
    uploadPath = "C:/server/uploads";
}

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadPath),
    RequestPath = "/uploads"
});
// ==============================


// ===== BẬT CORS =====
app.UseCors("AllowAll");
// ====================

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

//app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
