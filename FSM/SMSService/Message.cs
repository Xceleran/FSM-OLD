﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace FSM.SMSService
{
    public class Message
    {
        public string From { get; set; }
        public string To { get; set; }
        public string Type { get; set; }
        public string Status { get; set; }
        public string Body { get; set; }
        public DateTime SendDateTime { get; set; }
        public int NumMedia { get; set; }

        public List<string> MediaUrls { get; set; } = new List<string>();
    }
}