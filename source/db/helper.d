module db.helper;

import db.shared_database, std.exception, std.conv : to;
import db.uda, std.traits, d2sqlite3;

class DatabaseHelper {
    public static T [] select(T)(string where = "") @trusted
    {
        T [] result = new T[0];

        string request = "SELECT * FROM " ~ T.stringof;
        if (where != "") request ~= " WHERE " ~ where ~ ";";

        ResultRange res = SharedDatabase.get().databaseInstance.execute(request);

        foreach (Row row; res)
        {
            result ~= serealizeData!T(row);
        }

        return result; 
    }

    public static void remove(T)(T item) @trusted
    {
        string request = "DELETE FROM " ~ T.stringof ~ " WHERE " ~ generateWhere(item);
        SharedDatabase.get().databaseInstance.execute(request);
    }

    public static void update(T)(T last, T second) @trusted
    {
        string request = "UPDATE " ~ T.stringof ~ " SET " ~ genSet(second) ~ " WHERE " ~ generateWhere(last);
        //import std.stdio; writeln("\n\n"); writeln(request);
        SharedDatabase.get().databaseInstance.execute(request);
    }

    public static void insert(T)(T item) @trusted
    {
        string request = "INSERT INTO " ~ T.stringof ~ " " ~ genInsertValues(item);
        SharedDatabase.get().databaseInstance.execute(request);
    }

    public static void exec(string cmd) @trusted
    {
        SharedDatabase.get().databaseInstance.execute(cmd);
    }

    private static string genSet(T)(T item) @trusted
    {
        string result = ""; string [] sets = new string[0];

        foreach (arg; __traits(allMembers, T))
        {
            static if (hasUDA!(__traits (getMember, T, arg), Entry) != false)
            {
            Entry entry = getUDAs!(__traits (getMember, T, arg), Entry)[0];
            if (entry.autoincrement) continue;
            
            string value = "";

            if (is (typeof(__traits (getMember, T, arg)) == string))
            {
                value = "\"" ~ to!string(__traits (getMember, item, arg)) ~ "\"";
            } else value = to!string(__traits (getMember, item, arg));

            value = arg ~ " = " ~ value;
            sets ~= value;
        }}

        for (int i = 0; i < sets.length; i++)
        {
            result ~= sets[i];
            if (i + 1 != sets.length) result ~= ",";
            result ~= " ";
        }

        return result;
    }

    private static string genInsertValues(T)(T item) @trusted
    {
        string [] columns = new string[0];
        string [] values = new string[0];

        foreach (arg; __traits(allMembers, T))
        {
            static if (hasUDA!(__traits (getMember, T, arg), Entry) != false)
            {
                Entry entry = getUDAs!(__traits (getMember, T, arg), Entry)[0];
                if (entry.autoincrement) continue;

                if (is (typeof(__traits (getMember, T, arg)) == string))
                {
                    string value = "'" ~ to!string(__traits (getMember, item, arg)) ~ "'";
                    values ~= value;
                }
                else values ~= to!string(__traits (getMember, item, arg));

                columns ~= arg;
            }
        }

        string result = "(";

        for (int i = 0; i < columns.length; i++)
        {
            result ~= columns[i];
            if (i + 1 != columns.length) result ~= ",";
            result ~= " ";
        } result ~= ") VALUES(";

        for (int i = 0; i < values.length; i++)
        {
            result ~= values[i];
            if (i + 1 != values.length) result ~= ",";
            result ~= " ";
        }

        return result ~ ")";
    }

    private static string generateWhere(T)(T item) @trusted
    {
        import std.array : appender;
        auto whereBuilder = appender!string;

        string [] items = new string[0];

        foreach (arg; __traits(allMembers, T))
        {
            static if (hasUDA!(__traits (getMember, T, arg), Entry) != false)
            {
            string tmp = to!string(__traits(getMember, item, arg));
            if (tmp == "") continue;

            static if (is (typeof(__traits(getMember, item, arg)) == string)) items ~= arg ~ " = \"" ~ tmp ~ "\"";
            else items ~= arg ~ " = " ~ tmp;
        }}

        for(int i = 0; i < items.length; i++)
        {
            whereBuilder.put(items[i]);
            if (i + 1 != items.length) whereBuilder.put(" AND");
            whereBuilder.put(" ");
        }

        return whereBuilder[];
    }

    private static T serealizeData(T)(Row row) @trusted
    {
        string [string] data; T result;

        for (int i = 0; i < row.length(); i++)
        {
            data[row.columnName(i)] = row[row.columnName(i)].as!string;
        }

        foreach (arg; __traits(allMembers, T))
        {
            static if (hasUDA!(__traits (getMember, T, arg), Entry) != false)
            {
                if (arg in data)
                {
                    static if (is (typeof(__traits(getMember, result, arg)) == bool)) 
                        __traits(getMember, result, arg) = data[arg] == "1";
                    else
                        __traits(getMember, result, arg) = to!(typeof(__traits(getMember, result, arg)))(data[arg]);
                }
            }
        }

        return result;
    }
}
