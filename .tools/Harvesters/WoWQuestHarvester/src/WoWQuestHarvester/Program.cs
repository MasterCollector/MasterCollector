using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;
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
        private static readonly Dictionary<int, object> QuestDB = new Dictionary<int, object>();
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
                            int id = Convert.ToInt32(questData["id"]);
                            QuestDB.Add(id, new
                            {
                                text = questData["title"],
                                lvl = questData.ContainsKey("reqLevel") ? questData["reqLevel"] : 0,
                            });
                            Console.Out.WriteLine($"Quest {currentID}: {questData["title"]}");
                        }
                        currentID++;
                        break;

                    case 404:   // no quest info for this ID, we're okay to move on the the next one
                        QuestDB.Add(currentID, new { });
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