using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()    
    .ConfigureServices(s => 
    { 
        s.AddScoped<IDocumentGenerator, DocumentGenerator>();
        s.AddSingleton<IStorageService, StorageService>();
    })
    .Build();

host.Run();
