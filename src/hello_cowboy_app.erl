-module(hello_cowboy_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start_all/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start_all() ->
    application:start(ranch),
    application:start(crypto),
    application:start(cowlib),
    application:start(cowboy),
    application:start(hello_cowboy).

start(_StartType, _StartArgs) ->
    ets:new(ws_client, [set, named_table, public]),
    Dispatch = cowboy_router:compile([
				      {'_', [{'_', hello_handler, []}]}
				     ]),
    cowboy:start_http(my_http_listener, 100,
		      [{port, 8080}],
		      [{env, [{dispatch, Dispatch}]}]
		     ),
    hello_cowboy_sup:start_link().

stop(_State) ->
    ok.
