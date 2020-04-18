using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace WoWQuestHarvester
{
    internal class Program
    {
        private static readonly string BaseDir = Environment.CurrentDirectory;
        private const string settingsFileName = "clientSettings.txt";
        private static HttpClient httpClient = new HttpClient();
        private static string bearerToken;
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

            SetBearerToken();
            if (string.IsNullOrWhiteSpace(bearerToken))
            {
                Console.Out.WriteLine($"Bearer token could not be set for authentication. Verify your values in {settingsFileName} are correct, then try again.");
                Exit();
            }

            SetHttpClient(bearerToken);
            int currentID = minQuestID;
            do
            {
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
                        SetBearerToken();
                        SetHttpClient(bearerToken);
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
            Exit();
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

        private static void Exit()
        {
            httpClient?.Dispose();
            Environment.Exit(0);
        }

        private static void SetBearerToken()
        {
            string settingsPath = Path.Combine(BaseDir, settingsFileName);
            if (!File.Exists(settingsPath))
            {
                Console.Out.WriteLine($"{settingsFileName} created.");
                File.WriteAllLines(settingsFileName, new string[] { "clientID:", "secret:" });
            }
            string[] keys = File.ReadAllLines(settingsPath);
            string clientID = keys[0].Split(':')[1] ?? null;
            string secret = keys[1].Split(':')[1] ?? null;
            if (string.IsNullOrWhiteSpace(clientID) || string.IsNullOrWhiteSpace(secret))
            {
                Console.Out.WriteLine($"{settingsFileName} must contain a clientID and secret.");
                Exit();
            }

            string oAuthEndpoint = ConfigurationManager.AppSettings["BlizzardOAuthEndpoint"];
            using (var message = new HttpRequestMessage(HttpMethod.Post, oAuthEndpoint))
            {
                message.Content = new StringContent("grant_type=client_credentials");
                message.Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/x-www-form-urlencoded") { CharSet = "UTF-8" };
                message.Headers.TryAddWithoutValidation("Authorization", $"Basic {Convert.ToBase64String(Encoding.UTF8.GetBytes($"{clientID}:{secret}"))}");

                var result = httpClient.SendAsync(message).Result;
                if (result.IsSuccessStatusCode)
                {
                    JObject bearerData = JObject.Parse(result.Content.ReadAsStringAsync().Result);
                    if (bearerData.ContainsKey("error"))
                    {
                        Console.Out.WriteLine($"{bearerData["error"]}: {bearerData["error_description"]}");
                        Exit();
                    }
                    bearerToken = bearerData["access_token"].ToString();
                }
                else
                {
                    Console.Out.WriteLine($"Unsuccessful request for OAuth token: {result.StatusCode}");
                }
            }
        }

        private static void SetHttpClient(string bearerToken)
        {
            httpClient?.Dispose();
            httpClient = new HttpClient();
            httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", bearerToken);
        }
    }
}