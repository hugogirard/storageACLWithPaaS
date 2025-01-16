using Azure.Core;
using Azure.Identity;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Configuration;



var builder = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile("appsettings.json", optional: false)
                    .AddUserSecrets<Program>();
var configuration = builder.Build();



var useManagedIdentity = configuration.GetValue<bool>("useManagedIdentity");

BlobServiceClient service = null;

if (useManagedIdentity)
{
    string managedIdentityId = configuration["ManagedIdentityResourceId"] ?? string.Empty;

    if (string.IsNullOrEmpty(managedIdentityId))
    {
        Console.WriteLine("Managed identity ID is empty");
        return;
    }

    TokenCredential credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
    {
        ManagedIdentityClientId = managedIdentityId
    });
    string serviceUrl = configuration["BlobServiceUri"] ?? string.Empty;

    if (string.IsNullOrEmpty(serviceUrl))
    {
        Console.WriteLine("Blob service URL is empty");
        return;
    }

    // Create a client that can authenticate using our token credential
    service = new BlobServiceClient(new Uri(serviceUrl), credential);
}
else
{
    var cnxString = configuration["StrCnxString"];

    if (string.IsNullOrEmpty(cnxString))
    {
        Console.WriteLine("Connection string is empty");
        return;
    }
    else
    {
        service = new BlobServiceClient(cnxString);
    }
}

// Validate if we are authenticated
var response = await service.GetPropertiesAsync();

if (response.GetRawResponse().Status == 200)
{
    Console.WriteLine("Authenticated");
}
else
{
    Console.WriteLine("Not authenticated");
}
