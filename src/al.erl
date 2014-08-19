-module(al).

-export([onresponse/4]).

-type status() :: cowboy:http_status().
-type headers() :: cowboy:http_headers().
-type req() :: cowboy_req:req().

-spec onresponse(status(), headers(), iodata(), req()) -> req().
onresponse(Status, _Headers, Body, Req) ->
    %% 127.0.0.1 - - [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
    {{IPAddress, _}, Req2} = cowboy_req:peer(Req),
    {Method, Req3} = cowboy_req:method(Req2),
    {Version, Req4} = cowboy_req:version(Req3),
    {Path, Req5} = cowboy_req:path(Req4),
    {Qs, Req6} = cowboy_req:qs(Req5),
    IPString = inet_parse:ntoa(IPAddress),
    Now = os:timestamp(),
    UTC = calendar:now_to_universal_time(Now),
    DateTime = datetime_to_iso8601(UTC),
    Qs2 = case Qs of
              <<>> ->
                  Qs;
              _ ->
                  [$?, Qs]
          end,
    Size = iolist_size(Body),
    lager:info("~s - - [~s] \"~s ~s~s ~s ~b ~b",
               [IPString, DateTime, Method, Path, Qs2, Version, Status, Size]),
    Req6.

datetime_to_iso8601({{Year, Month, Day}, {Hour, Min, Sec}}) ->
    YYYY = lpad(integer_to_binary(Year), 4, $0),
    MM = lpad(integer_to_binary(Month), 2, $0),
    DD = lpad(integer_to_binary(Day), 2, $0),
    Hh = lpad(integer_to_binary(Hour), 2, $0),
    Mm = lpad(integer_to_binary(Min), 2, $0),
    Ss = lpad(integer_to_binary(Sec), 2, $0),
    <<YYYY/binary, $-, MM/binary, $-, DD/binary, $T, Hh/binary, $:, Mm/binary, $:, Ss/binary, $Z>>.

lpad(Str, Len, Char) when Len >= 0, is_integer(Char) ->
    PadLen = Len - size(Str),
    if
        PadLen > 0 ->
            Padding = duplicate_char(Char, PadLen),
            <<Padding/binary, Str/binary>>;
        true ->
            Str
    end.

duplicate_char(Char, Count) when is_integer(Char) ->
    duplicate_char(Char, Count, <<>>).

duplicate_char(Char, Count, Acc) when Count > 0 ->
    duplicate_char(Char, Count - 1, <<Acc/binary, Char>>);
duplicate_char(_Char, _Len, Acc) ->
    Acc.
