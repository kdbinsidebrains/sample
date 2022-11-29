\l code/u.q
\l code/core.q

.tp.logFile:`;
.tp.logHandle:0Ni;
.tp.logPosition:0N;
.tp.currentDate:0Nd;

.tp.createNewFile:{[dt] $[f~key f:.cfg.tp.getFileName dt; f; .[f; (); :; ()]]};

.tp.startNewDay:{[d]
    eod:.tp.currentDate; .tp.currentDate:d;

    .log.info "Starting new date: ",string d;

    if[not null .tp.logHandle; .log.info "Close previous log file: ",string .tp.logFile; hclose .tp.logHandle];

    .tp.logFile:.tp.createNewFile .tp.currentDate;
    .log.info "Log file: ",string .tp.logFile;

    .tp.logPosition:-11!(-2;.tp.logFile);
    .log.info "Replayed position: ",string .tp.logPosition;

    if[0<=type .tp.logPosition;
       .log.error (string .tp.logFile)," is a corrupt log. Truncate to length ",(string last .tp.logPosition)," and restart"; exit 1;
      ];

    .tp.logHandle:hopen .tp.logFile;
    .log.info "New handle has been opened: ",string .tp.logHandle;

    if[not null eod; .u.end[eod]; .log.info "EndOfDay has been sent: ",string eod;];
 };

.tp.init:{
    .log.info "Starting new TP instance in ",.cfg.tp.path;

    / Init .u lib
    .u.init[];
    / Check schemas. Every must have `time`sym
    if[not min (`time`sym~2#key flip value@)each .u.t; '`timesym];
    / Set attributes
    @[; `sym; `g#] each .u.t;

    .log.info "TP is ready";
 };

.tp.sub:{[tlbs;syms] (.u.sub[tlbs; syms];(.tp.logPosition;.tp.logFile))}

.tp.upd:{[t;d]
    ts:`date$first d[0];

    / We drive new date by data from the feed for consistency
    if[.tp.currentDate<ts; .tp.startNewDay ts];

    .u.pub[t; $[0>type first d; enlist cols[t]!d; flip cols[t]!d]];
    if[.tp.logHandle; .tp.logHandle enlist (`upd;t;d); .tp.logPosition+:1];
 };

.u.upd:{[t;d] `tt set t; `dd set d; .tp.upd[t; d]};

.tp.init[];