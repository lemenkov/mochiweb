%%
%% Illustrates difference in QS parsing when you have multibyte characters
%% eg, visit: http://localhost:8000/?foo=progeyö
%%
-module(utf8_querystring).
-export([ start/0, start/1, loop/1
        ]).

-define(LOOP, {?MODULE, loop}).

start() -> start([{port, 8000}]).

start(Options) ->
    mochiweb_http:start([{name, ?MODULE}, {loop, ?LOOP} | Options]).

loop(Req) ->
    Qs   = Req:parse_qs(),
    QsX  = Req:parse_qs_utf8(),
    Foo  = proplists:get_value("foo", Qs),
    FooX = proplists:get_value("foo", QsX),
    Body = [ "parse_qs():", io_lib:format("~p", [Qs]), "<br/>",
             "parse_qs_utf8():", io_lib:format("~p", [QsX]), "<br/>",
             "<hr/>", 
             "'foo' from normal parse_qs():<br/>",
             io_lib:format("~p", [ [a]++Foo ]),
             "<br/><hr/>",
             "'foo' from parse_qs_utf8():<br/>",
             io_lib:format("~p", [ [a]++FooX ])
            ],
    Req:ok({"text/html", Body}).            

