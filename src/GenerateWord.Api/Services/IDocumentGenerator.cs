namespace Contoso;

public interface IDocumentGenerator
{
    string TemporaryFilename { get; }

    void AddRow(string speakerId, string text);
    void CreateTable();
    void Save();
    void SaveTable();
}
