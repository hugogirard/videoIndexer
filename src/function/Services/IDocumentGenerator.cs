namespace Contoso;

public interface IDocumentGenerator
{
    void AddRow(string speakerId, string text);
    void CreateTable();
    void Save();
    void SaveTable();

    string TemporaryFilename {get;}

    Stream GetDocumentStream();
}