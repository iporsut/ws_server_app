-module(ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

init({tcp, http}, _Req, _Opts) ->
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
    {NameBIN , _ } = cowboy_req:qs_val(<<"name">>,Req, <<"">>),
    Name = list_to_atom(binary_to_list(NameBIN)),
    register(Name, self()),
    ets:insert(ws_client, {Name,self()}),
    erlang:start_timer(1000, self(), <<"Hello!">>),
    {ok, Req, Name}.

websocket_handle({text, _Msg}, Req, State) ->
    io:format("Received msg ~p~n", [_Msg]),
    {ok, Req, State};

websocket_handle(_Data, Req, State) ->
    {ok, Req, State}.

websocket_info({text,Msg}, Req, State) ->
    {reply, {text, Msg}, Req, State};

websocket_info(_Info, Req, State) ->
    io:format("~p~n",[_Info]),
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    ets:delete(ws_client, _State),
    io:format("~p~n",[ets:tab2list(ws_client)]),
    ok.
