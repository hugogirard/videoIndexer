using Contoso;
using Newtonsoft.Json;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSingleton<IStorageService, StorageService>();
builder.Services.AddScoped<IDocumentGenerator, DocumentGenerator>();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI(s => 
{
    s.RoutePrefix = string.Empty;
    s.SwaggerEndpoint("/swagger/v1/swagger.json", "v1");
});

app.UseHttpsRedirection();

app.MapPost("/api/generate/{filename}", async (IStorageService storageService, IDocumentGenerator documentGenerator, string filename) =>
{
    string content = await storageService.GetBlobContentAsync(filename);

    var transcription = JsonConvert.DeserializeObject<Transcription>(content);

    documentGenerator.CreateTable();

    foreach (var transcript in transcription.Videos.First().Insights.Transcript)
    {
        documentGenerator.AddRow(transcript.SpeakerId.ToString(),transcript.Text);
    }
                
    documentGenerator.SaveTable();
    documentGenerator.Save();
    
    string wordDocumentName = $"{Path.GetFileNameWithoutExtension(filename)}.docx";

    await storageService.UploadFileAsync(wordDocumentName,documentGenerator.TemporaryFilename);

    File.Delete(documentGenerator.TemporaryFilename);

    return new GenerateFileViewModel(wordDocumentName, transcription);    
})
.WithName("GenerateWordDocument")
.WithOpenApi();

app.Run();

