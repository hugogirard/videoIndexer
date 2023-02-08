using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using Azure.Storage.Blobs.Specialized;
using Microsoft.Extensions.Configuration;

namespace Contoso;

public class StorageService : IStorageService
{
    private readonly BlobContainerClient _containerClient;

    public StorageService(IConfiguration configuration)
    {
        BlobServiceClient blobServiceClient = new BlobServiceClient(configuration["StorageConnectionString"]);

        _containerClient = blobServiceClient.GetBlobContainerClient(configuration["StorageContainerName"]);
    }

    public async Task UploadFileAsync(string fileName, Stream fileStream)
    {
        BlobClient blobClient = _containerClient.GetBlobClient(fileName);

        await blobClient.UploadAsync(fileStream, true);
    }

    public async Task UploadFileAsync(string fileName, string filepath)
    {
        BlobClient blobClient = _containerClient.GetBlobClient(fileName);

        await blobClient.UploadAsync(filepath, true);
    }
}