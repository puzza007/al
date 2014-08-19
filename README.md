al
==

Apache Logger Onresponse Function For Cowboy

```erlang
	{ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [
		{compress, true},
		{env, [{dispatch, Dispatch}]},
		{onresponse, fun al:onresponse/4}
	]),
```

Log lines look like

```
=INFO REPORT==== 19-Aug-2014::14:44:32 ===
127.0.0.1 - - [2014-08-19T12:44:32Z] "GET /flange?bar=foo HTTP/1.1 404 0
=INFO REPORT==== 19-Aug-2014::14:45:49 ===
127.0.0.1 - - [2014-08-19T12:45:49Z] "GET / HTTP/1.1 200 510
```
