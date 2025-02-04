%%--------------------------------------------------------------------
%% Copyright (c) 2025 EMQ Technologies Co., Ltd. All Rights Reserved.
%%--------------------------------------------------------------------

-module(emqx_omp_mysql_schema).

-include_lib("emqx/include/emqx.hrl").
-include_lib("emqx/include/logger.hrl").

-include_lib("typerefl/include/types.hrl").
-include_lib("hocon/include/hoconsc.hrl").

-export([roots/0, fields/1, namespace/0]).


-define(MYSQL_HOST_OPTIONS, #{
    default_port => 3306
}).

namespace() -> mysql.

roots() ->
    [{config, #{type => hoconsc:ref(?MODULE, config)}}].

fields(config) ->
    [{server, server()}] ++
        add_default_username(emqx_connector_schema_lib:relational_db_fields(), []) ++
        emqx_connector_schema_lib:ssl_fields().

add_default_username([{username, OrigUsernameFn} | Tail], Head) ->
    Head ++ [{username, add_default_fn(OrigUsernameFn, <<"root">>)} | Tail];
add_default_username([Field | Tail], Head) ->
    add_default_username(Tail, Head ++ [Field]).

add_default_fn(OrigFn, Default) ->
    fun
        (default) -> Default;
        (Field) -> OrigFn(Field)
    end.

server() ->
    Meta = #{desc => "MySQL server"},
    emqx_schema:servers_sc(Meta, ?MYSQL_HOST_OPTIONS).
