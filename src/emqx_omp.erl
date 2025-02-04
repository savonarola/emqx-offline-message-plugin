%%--------------------------------------------------------------------
%% Copyright (c) 2025 EMQ Technologies Co., Ltd. All Rights Reserved.
%%--------------------------------------------------------------------

-module(emqx_omp).

-include("emqx_omp.hrl").
-include_lib("emqx/include/emqx.hrl").
-include_lib("emqx/include/logger.hrl").

-export([
    load/1,
    unload/0
]).

-export([
    on_config_changed/2
]).

%%--------------------------------------------------------------------
%% Load/Unload
%%--------------------------------------------------------------------

-spec load(map()) -> ok | error.
load(#{<<"mysql">> := RawConfig0}) ->
    ?SLOG(info, #{msg => "omp_load", raw_config => RawConfig0}),
    emqx_metrics_worker:create_metrics(
        ?METRICS_WORKER, message_acked, [success, fail]
    ),
    emqx_metrics_worker:create_metrics(
        ?METRICS_WORKER, session_subscribed, [success, fail]
    ),

    #{
        <<"delete_message_sql">> := _DeleteMessageSql,
        <<"insert_message_sql">> := _InsertMessageSql,
        <<"select_message_sql">> := _SelectMessageSql
    } = RawConfig0,

    RawConfig1 = maps:without(
        [<<"delete_message_sql">>, <<"insert_message_sql">>, <<"select_message_sql">>, <<"enable">>], RawConfig0
    ),

    {ok, #{config := Config}} = emqx_hocon:check(
        emqx_omp_mysql_schema,
        #{<<"config">> => RawConfig1},
        #{atom_key => true}),

    ResourceOpts = #{
        start_after_created => true
    },
    ResourceGroup = <<"omp">>,
    ResourceId = <<"omp_mysql">>,
    Module = emqx_mysql,

    Result = emqx_resource:create_local(
        ResourceId,
        ResourceGroup,
        Module,
        Config,
        ResourceOpts
    ),

    ?SLOG(info, #{msg => "omp_load", config => Config, result => Result}),

    ok.

-spec unload() -> ok | error.
unload() ->
    ok.

%%--------------------------------------------------------------------
%% EMQX Plugin callbacks
%%--------------------------------------------------------------------

-spec on_config_changed(map(), map()) -> ok.
on_config_changed(OldConf, NewConf) ->
    ?SLOG(info, #{
        msg => "offline_message_plugin_config_changed", old_conf => OldConf, new_conf => NewConf
    }),
    ok.

%%--------------------------------------------------------------------
%% Action
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% Internal functions
%%--------------------------------------------------------------------
