using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;
using Microsoft.Extensions.Configuration;

namespace Contoso;

public class StorageService : IStorageService
{
    private readonly BlobContainerClient _containerClientTranscript;

    private readonly BlobContainerClient _containerClientWord;

    public StorageService(IConfiguration configuration)
    {
        BlobServiceClient blobServiceClient = new BlobServiceClient(configuration["StorageConnectionString"]);

        _containerClientTranscript = blobServiceClient.GetBlobContainerClient(configuration["StorageContainerNameTranscription"]);

        _containerClientWord = blobServiceClient.GetBlobContainerClient(configuration["StorageContainerNameWord"]);
    }

    public async Task UploadFileAsync(string fileName, Stream fileStream)
    {
        BlobClient blobClient = _containerClientWord.GetBlobClient(fileName);

        await blobClient.UploadAsync(fileStream, true);
    }

    public async Task<string> GetBlobContentAsync(string filename)
    {
        BlobClient blobClient = _containerClientTranscript.GetBlobClient(filename);

        var blob = await blobClient.OpenReadAsync();

        using (var sr = new StreamReader(blob, System.Text.Encoding.UTF8))
        {
            return await sr.ReadToEndAsync();
        }
    }

    public async Task UploadFileAsync(string fileName, string filepath)
    {
        BlobClient blobClient = _containerClientWord.GetBlobClient(fileName);

        await blobClient.UploadAsync(filepath, true);
    }
}