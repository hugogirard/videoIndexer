using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Contoso;

public class DocumentGenerator : IDocumentGenerator
{
    private readonly WordprocessingDocument _document;

    private readonly Table _table;

    private string _filename;

    private readonly ILogger<DocumentGenerator> _logger;

    public string TemporaryFilename => _filename;

    public DocumentGenerator(ILoggerFactory loggerFactory)
    {
        _filename = $"{Guid.NewGuid().ToString()}.docx";
        _logger = loggerFactory.CreateLogger<DocumentGenerator>();

        _logger.LogInformation($"Temp document name: {_filename}");

        _document = WordprocessingDocument.Create(_filename, WordprocessingDocumentType.Document, true);

        MainDocumentPart mainPart = _document.AddMainDocumentPart();
        mainPart.Document = new Document();
        mainPart.Document.AppendChild(new Body());
        _table = new Table();
    }

    public void CreateTable()
    {

        TableStyle tableStyle = new()
        {
            Val = "GridTable1Light-Accent5"

        };
        TableWidth tableWidth = new()
        {
            Width = "0",
            Type = TableWidthUnitValues.Auto
        };
        TableLook tableLook = new()
        {
            Val = "0000",
            FirstRow = new OnOffValue(false),
            LastRow = new OnOffValue(false),
            FirstColumn = new OnOffValue(false),
            LastColumn = new OnOffValue(false),
            NoHorizontalBand = new OnOffValue(false),
            NoVerticalBand = new OnOffValue(false)
        };
        var border = new TableBorders(
            new TopBorder()
            {
                Val =
                new EnumValue<BorderValues>(BorderValues.BasicThinLines),
                Size = 1
            },
            new BottomBorder()
            {
                Val =
                new EnumValue<BorderValues>(BorderValues.BasicThinLines),
                Size = 1
            },
            new LeftBorder()
            {
                Val =
                new EnumValue<BorderValues>(BorderValues.BasicThinLines),
                Size = 1
            },
            new RightBorder()
            {
                Val =
                new EnumValue<BorderValues>(BorderValues.BasicThinLines),
                Size = 1
            },
            new InsideHorizontalBorder()
            {
                Val =
                new EnumValue<BorderValues>(BorderValues.BasicThinLines),
                Size = 1
            },
            new InsideVerticalBorder()
            {
                Val =
                new EnumValue<BorderValues>(BorderValues.BasicThinLines),
                Size = 1
            }
        );
        TableProperties tblProp = new TableProperties(tableStyle, tableWidth, tableLook, border);

        // Append the TableProperties object to the empty table.
        _table.AppendChild<TableProperties>(tblProp);

        // Add 2 columns to the table
        TableGrid tg = new TableGrid(new GridColumn()
        {
            Width = "4675"
        }, new GridColumn()
        {
            Width = "4675"
        });
        _table.AppendChild<TableGrid>(tg);
        CreateHeader();
    }

    public void AddRow(string speakerId, string text)
    {
        TableRow tr = new TableRow();

        // Create a cell.
        TableCell cell1 = new TableCell();

        // Specify the table cell content.
        cell1.Append(new Paragraph(new Run(new Text(speakerId))));

        // Append the table cell to the table row.
        tr.Append(cell1);

        TableCell cell2 = new();

        cell2.Append(new Paragraph(new Run(new Text(text))));

        tr.Append(cell2);

        _table.Append(tr);

    }

    public void SaveTable()
    {
        _document.MainDocumentPart.Document.Body.Append(_table);
    }

    public void Save()
    {
        _document.Save();
        _document.Close();
    }

    private void CreateHeader()
    {
        TableRow tr = new TableRow();

        // Create a cell.
        TableCell headerOne = new TableCell();
        TableCell headerTwo = new TableCell();

        headerOne.Append(new Paragraph(new Run(new Text("SpeakerId"))));
        headerTwo.Append(new Paragraph(new Run(new Text("Text"))));
        tr.Append(headerOne, headerTwo);

        _table.Append(tr);
    }
}
