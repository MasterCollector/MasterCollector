using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;

namespace WoWQuestHarvester
{
    using APIConnectivity;

    internal class Program
    {
        private static int minQuestID = 1;
        private static int maxQuestID = Convert.ToInt32(ConfigurationManager.AppSettings["MaxQuestID"]);
        private static readonly Uri BaseQuestAPIEndpoint = new Uri(ConfigurationManager.AppSettings["BlizzardWoWQuestDataEndpoint"]);
        private static readonly string region = ConfigurationManager.AppSettings["region"];
        private static readonly string locale = ConfigurationManager.AppSettings["locale"];
        private static readonly string nameSpace = ConfigurationManager.AppSettings["namespace"];
        private static readonly List<object> QuestDB = new List<object>();
        private static readonly int SleepTimeInSeconds = Convert.ToInt32(ConfigurationManager.AppSettings["SleepTimeInSeconds"]);

        private static void Main(string[] args)
        {
            // set the min/max IDs for harvesting based on provided console arguments
            for (int i = 0; i < args.Length; i++)
            {
                if (args[i].StartsWith("-min=") && int.TryParse(args[i].Split('=')[1], out int min))
                    minQuestID = min;
                else if (args[i].StartsWith("-max=") && int.TryParse(args[i].Split('=')[1], out int max))
                    maxQuestID = max;
            }
            Console.Out.WriteLine($"Quest Harvester initialized for range {minQuestID} to {maxQuestID}");

            int currentID = minQuestID;
            var httpClient = APIClient.GetClient();
            do
            {
                if (httpClient == null)
                {
                    Console.Out.WriteLine("HTTPClient could not be retrieved. Exiting...");
                    Environment.Exit(0);
                }
                var response = httpClient.GetAsync(new Uri(BaseQuestAPIEndpoint, $"{currentID}").AddParameter("region", region).AddParameter("locale", locale).AddParameter("namespace", nameSpace)).Result;
                switch ((int)response.StatusCode)
                {
                    case 200:   // got a successful response from Blizzard
                        JObject questData = JObject.Parse(response.Content.ReadAsStringAsync().Result);
                        if (questData.ContainsKey("id") && questData.ContainsKey("title"))
                        {
                            var data = ProcessResponse(questData);
                            QuestDB.Add(data);
                            Console.Out.WriteLine($"Quest {currentID}: {questData["title"]}");
                        }
                        currentID++;
                        break;

                    case 404:   // no quest info for this ID, we're okay to move on the the next one
                        currentID++;
                        break;

                    case 429:   // too many requests. We'll sleep here for a bit, dispose the client and then reopen it
                        Console.Out.WriteLine("HTTP status TOO_MANY_REQUESTS (429) detected. Pausing and re-establishing connection...");
                        System.Threading.Thread.Sleep(SleepTimeInSeconds * 1000);
                        httpClient = APIClient.GetClient(dispose: true);
                        break;

                    default:
                        Console.Out.WriteLine($"Unknown response code for quest {currentID}: {response.StatusCode}");
                        currentID++;
                        break;
                }
            } while (currentID <= maxQuestID);
            Console.Out.WriteLine($"Successfully harvested {QuestDB.Count} quests.");
            var finalData = new { questDB = QuestDB };
            File.WriteAllText("questDB.json", JsonConvert.SerializeObject(finalData));
        }

        private static IDictionary<string, object> ProcessResponse(JObject QuestData)
        {
            IDictionary<string, object> data = new Dictionary<string, object>();
            // we always want the ID and title when initiating the questDB
            data.Add("id", QuestData["id"]);
            data.Add("title", QuestData["title"]);

            // quests can have a "category" defined -- possibly for quest storylines? Is this worth tracking at all?

            // now we can check if other valueable properties are present
            if (QuestData.ContainsKey("requirements"))
            {
                var requirements = QuestData["requirements"];
                // determine the minimum level. If it's 1 or less, there's no need to store it
                int minLevel = requirements.SelectToken("min_character_level")?.Value<int>() ?? 0;
                if (minLevel > 1)
                    data.Add("lvl", minLevel);

                // is there a faction requirement? If so, add it.
                var faction = requirements.SelectToken("$.faction.type")?.Value<string>();
                if (!string.IsNullOrWhiteSpace(faction))
                    data.Add("faction", faction);

                // are there race restrictions? If so, add them
                var races = requirements.SelectTokens("$.races[*].id")?.Values<int>();
                if (races?.Count() > 0)
                    data.Add("races", races);

                // are there class restrictions? If so, add them
                var classes = requirements.SelectTokens("$.classes[*].id")?.Values<int>();
                if (classes?.Count() > 0)
                    data.Add("classes", classes);
            }

            if (QuestData.ContainsKey("rewards"))
            {
                // is there one or more item available as a reward? If so, add the list
                var choiceItems = QuestData.SelectTokens("rewards.items.choice_of[*].item.id")?.Values<int>();
                if (choiceItems.Count() > 0)
                    data.Add("itemRewards", choiceItems);

                // is a spell granted as a reward? This is useful for tracking quests that provide a profession recipe/rank
                var singleSpell = QuestData.SelectTokens("rewards.spell.id")?.Values<int>();
                if (singleSpell?.Count() == 1)
                    data.Add("spellRewards", singleSpell);
            }

            return data;
        }
    }
}