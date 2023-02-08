using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Contoso
{
    public class GenerateTemplate
    {
        private readonly ILogger _logger;
        private readonly IDocumentGenerator _documentGenerator;
        private readonly IStorageService _storageService;

        public GenerateTemplate(ILoggerFactory loggerFactory, 
                                IDocumentGenerator documentGenerator,
                                IStorageService storageService)
        {
            _logger = loggerFactory.CreateLogger<GenerateTemplate>();
            _documentGenerator = documentGenerator;
            _storageService = storageService;
        }

        [Function("GenerateTemplate")]
        public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Function, "post", Route = "generate/{container}/{filename}")] HttpRequestData req, string filename,
                                                [BlobInput("{container}/{filename}", Connection = "StorageConnectionString")] string myBlob)
        {

            try
            {
                _logger.LogInformation($"File {filename} ready to process");

                if (string.IsNullOrEmpty(myBlob))
                {
                    _logger.LogError($"Blob is empty");
                    return req.CreateResponse(HttpStatusCode.NotFound);
                }

                var transcription = JsonConvert.DeserializeObject<Transcription>(myBlob);

                if (transcription == null)
                {
                    _logger.LogError($"File {filename} is not a valid transcription");
                    return req.CreateResponse(HttpStatusCode.BadRequest);
                }

                _logger.LogInformation("Generating document in memory");

                _documentGenerator.CreateTable();

                foreach (var transcript in transcription.Videos.First().Insights.Transcript)
                {
                    _documentGenerator.AddRow(transcript.SpeakerId.ToString(),transcript.Text);
                }
                
                _logger.LogInformation("Getting document stream");
                
                _documentGenerator.SaveTable();
                _documentGenerator.Save();

                var documentStream = _documentGenerator.GetDocumentStream();

                _logger.LogInformation($"Document stream lenght: {documentStream.Length}");

                string wordDocumentName = $"{Path.GetFileNameWithoutExtension(filename)}.docx";

                _logger.LogInformation("Uploading document to storage");
                
                await _storageService.UploadFileAsync(wordDocumentName,documentStream);

                return req.CreateResponse(HttpStatusCode.OK);                
            }
            catch (System.Exception ex)
            {
                _logger.LogError(ex,ex.Message);
                return req.CreateResponse(HttpStatusCode.BadRequest);                       
            }

        }
    }
}
