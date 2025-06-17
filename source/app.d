import std.stdio;
import vibe.http.client;

void main()
{
    writeln("Writing the goggle header...");

    File goggle;
    goggle.open("indieblog.goggle", "w+");

    // Write the goggle header
    goggle.writeln("! name: IndieWeb blogs");
    goggle.writeln(
        "! description: Filter to content from the blogs tracked at indieblog.page. Medium.com results are downranked.");
    goggle.writeln("! public: true");
    goggle.writeln("! author: Loren Burkholder");
    goggle.writeln("! license: GPL 3.0 or later");
    goggle.writeln("! avatar: #95f5e6");
    goggle.writeln();

    // Some static filtering stuff that I stole from the tech blogs example goggle
    // because it looked like a sane default to add
    goggle.writeln("$discard");
    goggle.writeln("$downrank,site=medium.com");
    goggle.writeln();
    goggle.writeln("$boost=1,site=github.io");
    goggle.writeln("$boost=1,site=micro.blog");

    // ...as well as some of my own default ranks
    goggle.writeln("$boost=1,site=bearblog.dev");
    goggle.writeln();

    writeln("Fetching the blog list from https://indieblog.page/export...");

    requestHTTP("https://indieblog.page/export",
        (scope req) { req.method = HTTPMethod.GET; }, (scope res) {
        import std.json;
        import vibe.stream.operations;

        writeln("Writing site list to indieblog.goggle...");

        auto json = res.bodyReader.readAllUTF8().parseJSON();
        foreach (blog; json.array)
        {
            import std.array;
            import std.algorithm;
            import vibe.inet.url;
            import std.conv : to;

            URL url;

            try
            {
                url = URL.fromString(blog["homepage"].str.replace(`\`, ``));
            }
            catch (Exception e)
            {
                writeln("falling back");
                url = URL.fromString(blog["feedurl"].str.replace(`\`, ``));
            }

            if (url.host.startsWith("www."))
                url.host = url.host[4 .. $];

            // Some sites get special handling for their boost level or their URL.
            int boost = 3;
            string finalSite = url.host;

            if (url.host == "medium.com" || url.host == "dev.to")
            {
                // Medium and Dev.to often have lower quality content
                boost = 2;

                // Medium and Dev.to blogs need delineated by their user paths so
                // as not to boost the entirety of those sites
                finalSite ~= url.pathString;
            }

            goggle.writeln("$boost=" ~ boost.to!string ~ ",site=" ~ finalSite);
        }
    });

    writeln("Goggle written to indieblog.goggle");
}
