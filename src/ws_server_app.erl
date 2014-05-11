-module(ws_server_app).
-behaviour(application).

-export([start/2, stop/1, start_all/0]).

-define(C_ACCEPTORS,  100).

start_all() ->
    application:start(ranch),
    application:start(crypto),
    application:start(cowlib),
    application:start(cowboy),
    application:start(hello_cowboy).

start(_StartType, _StartArgs) ->
    ets:new(ws_client, [set, named_table, public]),
    Routes    = routes(),
    Dispatch  = cowboy_router:compile(Routes),
    Port      = port(),
    TransOpts = [{port, Port}],
    ProtoOpts = [{env, [{dispatch, Dispatch}]}],
    {ok, _}   = cowboy:start_http(http, ?C_ACCEPTORS, TransOpts, ProtoOpts),
    ws_server_sup:start_link().

stop(_State) ->
    ok.

routes() ->
    [
     {'_', [
            {"/", ws_handler, []}
           ]}
    ].

port() ->
    case os:getenv("PORT") of
        false ->
            {ok, Port} = application:get_env(http_port),
            Port;
        Other ->
            list_to_integer(Other)
    end.
