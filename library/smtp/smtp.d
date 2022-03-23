module smtp;

import std.stdio, std.conv : to;

extern(C) {
    int send_email(const char *, const char *, const char *, const char *);
}

int sendEmail(string rec, string sbj, string msg, string attach = "") @trusted {
    return send_email((rec ~ "\0").ptr, (sbj ~ "\0").ptr, (msg ~ "\0").ptr, attach == "" ? null : (attach ~ "\0").ptr);
}
