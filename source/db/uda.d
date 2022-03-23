module db.uda;

public struct Table
{
    string name;
}

public enum EntryType
{
    String,
    Integer,
    Floating,
    Date,
    Time,
    Phone,
    Email,
    Enumeration,
    Link,
    Boolean
}

public struct Entry
{
    string name;
    EntryType type;
    string regexp = "";
    const string [] enum_values = [];
    ulong max_length = 50;
    string link_address = ""; //db_name:entry
    bool sortable = true;
    bool required = true;
    bool primary = false;
    bool autoincrement = false;
}

public static Entry _e(const Entry en) @safe {
    Entry res = Entry(en.name, en.type,
    en.regexp, en.enum_values, en.max_length, en.link_address,
    en.sortable,  en.required,
    en.primary, en.autoincrement);
    return res;
}
