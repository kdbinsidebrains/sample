.cfg.dataHome:ssr[getenv `SAMPLE_DATA; "\\"; "/"];

.cfg.tp.ext:".tpl";
.cfg.tp.path:.cfg.dataHome,"/tp";
.cfg.tp.getFileName:{[dt] `$":",.cfg.tp.path,"/",string[dt],.cfg.tp.ext}

.cfg.hdb.path:.cfg.dataHome,"/hdb";

.cfg.cache.path:.cfg.dataHome,"/cache";
