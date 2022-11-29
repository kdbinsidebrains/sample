.log.msg:{[level;msg]
    h:$[level in `error`fatal; -2; -1];
    h " " sv {$[10=type x; x; -11h=type x; string x; .Q.s1 x]} each (.z.p;upper string level;msg);
 };

.log.error:.log.msg[`error];

.log.warn:.log.msg[`warn];

.log.info:.log.msg[`info];

.log.debug:.log.msg[`debug];
