namespace Contoso;

public class GenerateFileViewModel
{
    public string Filename { get; set; }

    public Transcription Transcription { get; set; }

    public GenerateFileViewModel(string filename, Transcription transcription)
    {
        Filename = filename;
        Transcription = transcription;
    }

}