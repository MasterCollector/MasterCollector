using Newtonsoft.Json.Linq;
using System;
using System.Configuration;
using System.IO;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;

namespace APIConnectivity
{
    public static class APIClient
    {
        private static readonly string BaseDir = Environment.CurrentDirectory;
        private const string settingsFileName = "clientSettings.txt";
        private static HttpClient client = null;

        public static HttpClient GetClient(bool dispose = false)
        {
            if (dispose)
            {
                client?.Dispose();
                client = null;
            }

            if (client != null)
                return client;

            client = new HttpClient();
            string token = GetBearerToken(client);
            if (!string.IsNullOrWhiteSpace(token))
            {
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            }
            else
            {
                client?.Dispose();
                client = null;
            }
            return client;
        }

        private static string GetBearerToken(HttpClient client)
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
                return null;
            }

            string oAuthEndpoint = ConfigurationManager.AppSettings["BlizzardOAuthEndpoint"];
            using (var message = new HttpRequestMessage(HttpMethod.Post, oAuthEndpoint))
            {
                message.Content = new StringContent("grant_type=client_credentials");
                message.Content.Headers.ContentType = new MediaTypeWithQualityHeaderValue("application/x-www-form-urlencoded") { CharSet = "UTF-8" };
                message.Headers.TryAddWithoutValidation("Authorization", $"Basic {Convert.ToBase64String(Encoding.UTF8.GetBytes($"{clientID}:{secret}"))}");

                var result = client.SendAsync(message).Result;
                if (result.IsSuccessStatusCode)
                {
                    JObject bearerData = JObject.Parse(result.Content.ReadAsStringAsync().Result);
                    if (bearerData.ContainsKey("error"))
                    {
                        Console.Out.WriteLine($"{bearerData["error"]}: {bearerData["error_description"]}");
                        return null;
                    }
                    return bearerData["access_token"].ToString();
                }
                else
                {
                    Console.Out.WriteLine($"Unsuccessful request for OAuth token: {result.StatusCode}");
                }
            }
            return null;
        }
    }
}