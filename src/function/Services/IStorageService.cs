namespace Contoso;

public interface IStorageService
{
    Task UploadFileAsync(string fileName, Stream fileStream);
}
