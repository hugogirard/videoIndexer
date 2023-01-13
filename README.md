# Introduction

This GitHub repository provides an example of using Azure Video Indexer to have the transcript from an audio file.  Behind the scene, Azure Video Indexer use multiples others Azure Services, in this case we are interested by Speech To Text.

You can always do the same only using Speech To Text from an audio file, in this scenario we are using Azure Video Indexer to leverage the UI that come with the Azure Video Indexer [website](https://www.videoindexer.ai/).

# Prerequisites

You will need to have a OneDrive for business account to run this sample.  This is needed to save the Word Template to convert the JSON transcript to word document.  If you don't have this kind of account you can always create everything but just deactivate the workflow called **ConvertToWord**

# Architecture

This GitHub provides 3 workflows leveraging Azure Logic App.  One that will send the audio file to Azure Video Indexer to extract the transcript from the audio file.

The first Logic App will provide a callback (webhook) to Azure Video Indexer, this webhook is another Logic App that will retrieve the transcription from the audio file and save it in CosmosDB.

Once you have the data in Cosmos you can leverage Power BI or Cognitives Search to give more insights on the data.

Here the architecture diagram:

![architecture](https://raw.githubusercontent.com/hugogirard/videoIndexer/main/diagram/architecture.png)

# Fork the repository

The first step is to fork the repository

# Create GitHub Secrets

You will need to create some [GitHub repository secrets](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-encrypted-secrets-for-your-repository-and-organization-for-codespaces#adding-secrets-for-a-repository) first.  Here the list of secrets you will need to create.

| Secret Name | Value | Link
|-------------|-------|------|
| AZURE_CREDENTIALS | The service principal credentials needed in the Github Action | [GitHub Action](https://github.com/marketplace/actions/azure-login)
| AZURE_SUBSCRIPTION | The subscription ID where the resources will be created |
| PA_TOKEN | Needed to create GitHub repository secret within the GitHub action |  [Github Action](https://github.com/gliech/create-github-secret-action) |
| RESOURCE_GROUP_NAME | The name of the resource group where all resources will be created |
| LOCATION | The location where all the resources will be created |
| OFFICE_ONLINE_ACCOUNT | You need an office 365 account to connect to onedrive for business, this is the email associated to it

# Create the Azure Resources

Now is time to run the first GitHub actions, go to the Actions tab and run the **Create Azure Resources** action.

# Deploy the Logic App

Once the creation of the resources are done you can now run the next GitHub action called **Deploy Logic App**.

# Fix the connection for office 365

You will need to fix the connection to office 365, for this go to the Azure Portal where all the resource where deployed.  

# Upload your audio file into your Azure Storage

The repository creates 3 Azure Storage, one for the Logic App, one needed for Video Indexer and the last one to save the transcription file and to upload the audio file.

One of the storage has a Tags like this.

![architecture](https://raw.githubusercontent.com/hugogirard/videoIndexer/main/images/tags.png)

This storage contains 2 folder, one called **audio** and one called **transcript**.  Go to the **audio** folder and upload your audio file there.

Now right click the 3 elipses to the right and select **Generate SAS**

![architecture](https://raw.githubusercontent.com/hugogirard/videoIndexer/main/images/sas.png)

Click the **Generate SAS Token** and Url button and copy **the Blob SAS Url** value

# Find the URL to the Logic App Workflow

Go to the Azure Portal where the Logic App is deployed, you will see 3 workflows.

![architecture](https://raw.githubusercontent.com/hugogirard/videoIndexer/main/images/workflows.png)

Click on the IndexAudio one, copy the **Workflow URL**

![architecture](https://raw.githubusercontent.com/hugogirard/videoIndexer/main/images/workflowurl.png)

# Open Postman

Now you need to do an HTTP request to the Logic App, in this example we are using Postman but any other tools will work.

![architecture](https://raw.githubusercontent.com/hugogirard/videoIndexer/main/images/workflowurl.png)

The two important fields here are language and videoUrl, if the audio file contains multiple language you can leverage the preview feature, in this case the value will be **multi**.

To see the list of language supported refer to the [API reference](https://api-portal.videoindexer.ai/api-details#api=Operations&operation=Upload-Video)

For the **videoUrl** is the SAS of the blob copied before.

Now just send the POST request and wait the indexing to be completed

# See the progress of the indexing

You can see the progress of the indexing of the audio file by going to the **Video Indexer portal**.  To do so, just go to the Azure Video Indexer created by the repository and click the Video Indexer portal.

Be sure to select the good resource in the Video Indexer Portal by clicking the icon in the top menu.  You need to be sure to not select the trial version and the proper resource created before.

![architecture](https://raw.githubusercontent.com/hugogirard/videoIndexer/main/images/selectindexer.png)

![architecture](https://raw.githubusercontent.com/hugogirard/videoIndexer/main/images/indexing.png)

Once is completed, the workflow IndexingCompleted will be called, this one will save the transcription into CosmosDB and insert it to Azure Service Bus.

The ConvertToWord workflow will get the message from the queue and convert the JSON into a word document.

