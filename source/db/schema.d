module db.schema;

import db.uda, std.traits, std.conv : to;

class Schema(T) if (hasUDA!(T, Table))
{
    private string create_request;
    private ulong columns_number;

    private this(string cmd, ulong n) @safe pure nothrow
    {
        create_request = cmd; columns_number = n;
    }

    public static Schema buildSchema(T)()
    {
        import std.array : appender;
        auto buffer = appender!(char[])();

        auto udas = getUDAs!(T, Table);
        if (udas.length == 0) return null;

        buffer.put("CREATE TABLE IF NOT EXISTS ");
        buffer.put(T.stringof); buffer.put(" (");

        string [] entries = new string[0];

        foreach (arg; __traits (allMembers, T))
        {
            static if (hasUDA!(__traits (getMember, T, arg), Entry) == false) continue;
            else entries ~= genTableEntriesDefinition!arg();
        }

        for (int i = 0; i < entries.length; i++)
        {
            buffer.put(entries[i]);
            if (i + 1 != entries.length) buffer.put(",");
            buffer.put(" ");
        } buffer.put(");");

        return new Schema(to!string(buffer.data), entries.length);
    }

    private static string genTableEntriesDefinition(string arg)()
    {
        auto udas = getUDAs!(__traits (getMember, T, arg), Entry);
        static if (udas.length != 1) return ``;

        import std.array : appender; 
        Entry data = udas[0]; auto buffer = appender!(char[])();

        buffer.put(arg); buffer.put(" ");
        switch (data.type)
        {
            case EntryType.Boolean: buffer.put("BOOLEAN "); break;
            case EntryType.Integer: buffer.put("INTEGER "); break;
            case EntryType.Floating: buffer.put("DOUBLE "); break;
            default:
                buffer.put("VARCHAR ("); buffer.put( to!string(data.max_length));
                buffer.put(") ");
        }

        if (data.type == EntryType.Link)
        {
            import std.array : split;
            buffer.put("REFERENCES "); buffer.put(data.link_address.split(":")[0]);
            buffer.put("("); buffer.put(data.link_address.split(":")[1]); buffer.put( ") ");
            buffer.put("ON UPDATE CASCADE ON DELETE SET NULL ");
        }

        if (data.required) buffer.put("NOT NULL ");
        if (data.primary) buffer.put("PRIMARY KEY ");
        if (data.autoincrement) buffer.put("AUTOINCREMENT ");

        return to!string(buffer.data);
    }

    @property string createRequest() @safe pure nothrow { return create_request; }
    @property ulong columnsNumber() @safe pure nothrow { return columns_number; }
}
