module db.shared_database;

import d2sqlite3, defines;

class SharedDatabase
{
    private this()
    {
        databaseInstance = Database(SQLITE3_DB_PATH);
    }

    private static bool instantiated_;

    private __gshared SharedDatabase instance_;

    static SharedDatabase get()
    {
        if (!instantiated_)
        {
            synchronized(SharedDatabase.classinfo)
            {
                if (!instance_)
                {
                    instance_ = new SharedDatabase();
                }

                instantiated_ = true;
            }
        }

        return instance_;
    }

    public Database databaseInstance;
}
