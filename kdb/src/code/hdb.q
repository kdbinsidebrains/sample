\l code/core.q

.hdb.reload:{
    .log.info "Reloading HDB from ",.cfg.hdb.path;
    system "l ",.cfg.hdb.path;
    .log.info "HDB has been reloaded";
 };

.hdb.reload[];
