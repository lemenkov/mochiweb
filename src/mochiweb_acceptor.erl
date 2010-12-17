%% @author Bob Ippolito <bob@mochimedia.com>
%% @copyright 2010 Mochi Media, Inc.

%% @doc MochiWeb acceptor.

-module(mochiweb_acceptor).
-author('bob@mochimedia.com').

-include("internal.hrl").

-export([start_link/4, init/4]).

start_link(Server, Listen, Loop, SocketOpts) ->
    proc_lib:spawn_link(?MODULE, init, [Server, Listen, Loop, SocketOpts]).

init(Server, Listen, Loop, SocketOpts) ->
    T1 = now(),
    case catch mochiweb_socket:accept(Listen) of
        {ok, Socket} ->
            gen_server:cast(Server, {accepted, self(), timer:now_diff(now(), T1)}),
            call_loop_opts(Loop, Socket, SocketOpts);
        {error, closed} ->
            exit(normal);
        {error, timeout} ->
            init(Server, Listen, Loop, SocketOpts);
        {error, esslaccept} ->
            exit(normal);
        Other ->
            error_logger:error_report(
              [{application, mochiweb},
               "Accept failed error",
               lists:flatten(io_lib:format("~p", [Other]))]),
            exit({error, accept_failed})
    end.

call_loop_opts(Loop, Socket, []) ->
    call_loop(Loop, Socket);
call_loop_opts(Loop, Socket, SocketOpts) ->
    inet:setopts(Socket, SocketOpts),
    call_loop(Loop, Socket).

call_loop({M, F}, Socket) ->
    M:F(Socket);
call_loop({M, F, A}, Socket) ->
    erlang:apply(M, F, [Socket | A]);
call_loop(Loop, Socket) ->
    Loop(Socket).

%%
%% Tests
%%
-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.
