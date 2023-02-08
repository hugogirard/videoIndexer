namespace Contoso;

public interface IStorageService
{
    Task UploadFileAsync(string fileName, Stream fileStream);
    Task UploadFileAsync(string fileName, string filepath);
    Task<string> GetBlobContentAsync(string filename);
}
