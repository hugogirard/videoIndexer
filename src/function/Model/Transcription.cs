﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Contoso;

public class Transcription
{
    public IEnumerable<Video> Videos { get; set; }
}

public class Video
{
    public Insight Insights { get; set; }
}

public class Insight
{
    public IEnumerable<Transcript> Transcript { get; set; }
}

public class Transcript
{
    public int SpeakerId { get; set; }

    public string Text { get; set; }
}
