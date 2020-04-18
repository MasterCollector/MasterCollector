using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.IO;

namespace ItemHarvester
{
    using APIConnectivity;

    internal class Program
    {
        private static int minItemID = 1;
        private static int maxItemID = Convert.ToInt32(ConfigurationManager.AppSettings["MaxItemID"]);
        private static readonly Uri BaseItemAPIEndpoint = new Uri(ConfigurationManager.AppSettings["BlizzardWoWItemDataEndpoint"]);
        private static readonly string region = ConfigurationManager.AppSettings["region"];
        private static readonly string locale = ConfigurationManager.AppSettings["locale"];
        private static readonly string nameSpace = ConfigurationManager.AppSettings["namespace"];
        private static readonly int SleepTimeInSeconds = Convert.ToInt32(ConfigurationManager.AppSettings["SleepTimeInSeconds"]);

        private static void Main(string[] args)
        {
            // set the min/max IDs for harvesting based on provided console arguments
            for (int i = 0; i < args.Length; i++)
            {
                if (args[i].StartsWith("-min=") && int.TryParse(args[i].Split('=')[1], out int min))
                    minItemID = min;
                else if (args[i].StartsWith("-max=") && int.TryParse(args[i].Split('=')[1], out int max))
                    maxItemID = max;
            }
            Console.Out.WriteLine($"Item Harvester initialized for range {minItemID} to {maxItemID}");

            // TODO:: need to add DB file loading/appending so we don't have to reprocess the entire DB every time

            int currentID = minItemID;
            int itemsSaved = 0;
            var httpClient = APIClient.GetClient();
            DateTime start = DateTime.Now;
            using (FileStream fs = new FileStream("itemDB.json", FileMode.Create))
            {
                using (StreamWriter sw = new StreamWriter(fs))
                {
                    sw.Write("{\"itemDB\":[");
                    do
                    {
                        if (httpClient == null)
                        {
                            Console.Out.WriteLine("HTTPClient could not be retrieved. Exiting...");
                            Environment.Exit(0);
                        }
                        var response = httpClient.GetAsync(new Uri(BaseItemAPIEndpoint, $"{currentID}").AddParameter("region", region).AddParameter("locale", locale).AddParameter("namespace", nameSpace)).Result;
                        switch ((int)response.StatusCode)
                        {
                            case 200:   // got a successful response from Blizzard
                                JObject itemData = JObject.Parse(response.Content.ReadAsStringAsync().Result);
                                if (TryProcessResponse(itemData, out IDictionary<string, object> data))
                                {
                                    /* Notes:
                                     * Blizzard, in their infinite wisdom, classifies everything with a quality, item class and subclass, but the values aren't always what you expect when seeing them ingame
                                     * For example: toys are typically classified as "miscellaneous/junk" despite being it really being a type of account-wide collectible item.
                                     *              pets are "miscellaneous/companion pets"
                                     *              mounts are "miscellaneous/mounts"
                                     */
                                    sw.Write($"{(itemsSaved > 0 ? "," : string.Empty)}{JsonConvert.SerializeObject(data)}");
                                    Console.Out.WriteLine($"Item {data["id"]}: {data["name"]}");
                                    itemsSaved++;
                                }
                                else
                                {
                                    Console.Out.WriteLine($"Received a valid response but could not process data for item {currentID}.");
                                }
                                currentID++;
                                break;

                            case 404:   // no info for this ID, we're okay to move on the the next one
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
                    } while (currentID <= maxItemID);
                    sw.Write("]}");
                }
            }
            Console.Out.WriteLine($"Successfully harvested {itemsSaved} items.");
            DateTime end = DateTime.Now;
            Console.Out.WriteLine($"ItemDB harvesting completed in {(end - start).Hours} hour(s), { (end - start).Minutes} minute(s), and { (end - start).Seconds} second(s)");
        }

        private static bool TryProcessResponse(JObject ItemData, out IDictionary<string, object> data)
        {
            data = new Dictionary<string, object>();

            // we always want the ID and name
            data.Add("id", ItemData["id"]);
            data.Add("name", ItemData["name"]);

            long requiredLevel = ItemData.TryGetValue("required_level", out JToken lvl) ? lvl.Value<long>() : 0;
            if (requiredLevel > 1)
                data.Add("lvl", ItemData["required_level"]);

            string itemClass = ItemData.SelectToken("$.item_class.name")?.Value<string>() ?? null;
            if (!string.IsNullOrWhiteSpace(itemClass))
                data.Add("itemClass", itemClass);

            string itemSubClass = ItemData.SelectToken("$.item_subclass.name")?.Value<string>() ?? null;
            if (!string.IsNullOrWhiteSpace(itemSubClass))
                data.Add("itemSubClass", itemSubClass);

            // items should always have a quality
            var quality = ItemData.SelectToken("$.quality.type")?.Value<string>();
            if (!string.IsNullOrEmpty(quality))
                data.Add("quality", quality);

            // TODO: map inventory types to specific ID values
            var inventoryType = ItemData.SelectToken("$.inventory_type.type")?.Value<string>();
            if (!string.IsNullOrWhiteSpace(inventoryType))
                data.Add("inventoryType", inventoryType);

            var bindingType = ItemData.SelectToken("$.preview_item.binding.type")?.Value<string>();
            switch (bindingType)
            {
                case "ON_ACQUIRE":
                    data.Add("bindingType", "BOP");
                    break;

                case "ON_EQUIP":
                    data.Add("bindingType", "BOE");
                    break;

                case "TO_ACCOUNT":
                case "TO_BNETACCOUNT":
                    data.Add("bindingType", "BOA");
                    break;
            }

            return data != null && data.Count > 0;
        }
    }
}