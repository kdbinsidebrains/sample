/ Works in two mode:
/ 1) RDB/PDB mode: 2 parameters are required here: TP and HDB ports
/ 2) If only one parameter - replay mode

\l code/core.q

/ Set compression levels (gzip doesn't work on the box for now)
.z.zd:17 1 0;

.pdb.tables:tables[];
.pdb.hdbInstance:`;

.pdb.upd:{[t;d]
    t insert d;
 };

.pdb.end:{[dt]
    .log.info "End of the day. Start rollover process: ",string dt;
    .pdb.eod_table[dt;] each .pdb.tables;
    .log.info "Rollover has been finished";
    @[.pdb.notifyRollover; .pdb.hdbInstance; {.log.warn "HDB reload can't be done",x}];
    .log.info "End of the day finished";
 };

.pdb.notifyRollover:{[inst]
    if[null inst; :()];

    .log.info "Norify HDB: ",string inst;
    h:hopen inst;
    @[h; ".hdb.reload[]"; {.log.warn "HDB can't process reload",x}];
    hclose h;
    .log.info "HDB has been notified";
 };

.pdb.eod_table:{[dt;tbl]
    .log.info "Processing table ",string tbl;
    tdata:select from tbl where not dt=`date$time;
    .log.info " filtered: ",string count tdata;
    oldd:update `p#sym from `sym`time xasc get delete from tbl where not dt=`date$time;
    tbl set oldd;
    .log.info " sorder: ",string count oldd;
    .Q.dpft[hsym `$.cfg.hdb.path; dt; `sym; tbl];
    .log.info " stored";
    tbl set tdata;
    .log.info " cleaned";
    `OK};

.pdb.replayTp:{[tbls;file] (.[; (); :;] .) each tbls; if[null first file; :()]; -11!file}

.pdb.startPdb:{[tp;hdb]
    .log.info "Starting PDB mode: tp - ",tp,", hdb - ",hdb;
    r:(hopen hsym `$tp)".tp.sub[`;`]";
    .log.info "Replayed log file ",string[r[1] [0]],"@",string[r[1] [1]]," with tables: ",.Q.s1[r[0; ; 0]];
    .pdb.replayTp . r;
    .log.info "Log file has been replayed";
    .pdb.hdbInstance:hsym `$hdb;
 };

.pdb.replayFile:{
 };

.pdb.replayFolder:{
    tplogs:hsym `$.cfg.tp.path,/:string asc {x where x like "*",.cfg.tp.ext} key hsym `$.cfg.tp.path;
    {.log.info "Replaying tp log",string x; -11!x} each tplogs;
    /    .pdb.eod[];
    .log.info "finished";
    `OK};

.pdb.startReplay:{[file]
    .log.info "Starting in replay mode";
    .pdb.replayFile[file]
 };

/ Define system function here
upd:{[t;d] .pdb.upd[t; d]};
.u.end:{[d] .pdb.end d};

.pdb.startPdb[.z.x 0; .z.x 1];