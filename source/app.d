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
    goggle.writeln();

    // Some static filtering stuff that I stole from the tech blogs example goggle because it looked like a sane default to add
    goggle.writeln("$discard");
    goggle.writeln("$downrank,site=medium.com");
    goggle.writeln();
    goggle.writeln("$boost=1,site=github.io");
    goggle.writeln("$boost=1,site=micro.blog");
    goggle.writeln("/blog.$boost=1");
    goggle.writeln("/blog/$boost=1");

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
            
            string host = URL.fromString(blog["feedurl"].str.replace(`\`, ``)).host;
            if (host.endsWith("medium.com"))
                continue;
            if (host.startsWith("www."))
                host = host[4 .. $];
            goggle.writeln("$boost=3,site=" ~ host);
        }
    });

    writeln("Goggle written to indieblog.goggle");
}
