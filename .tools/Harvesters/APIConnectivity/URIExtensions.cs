using System;
using System.Web;

namespace APIConnectivity
{
    public static class URIExtensions
    {
        public static Uri AddParameter(this Uri uri, string key, string value)
        {
            var uriBuilder = new UriBuilder(uri);
            var query = HttpUtility.ParseQueryString(uriBuilder.Query);
            query[key] = value;
            uriBuilder.Query = query.ToString();

            return uriBuilder.Uri;
        }
    }
}