package server

import (
	"flag"
)

type Options struct {
	httpAddr   string
	httpsAddr  string
	tunnelAddr string
	domain     string
	tlsCrt     string
	tlsKey     string
	logto      string
	loglevel   string
}

func parseArgs() *Options {
	httpAddr := flag.String("httpAddr", ":80", "监听 HTTP 连接的端口号, 不指定则禁用")
	httpsAddr := flag.String("httpsAddr", ":443", "监听 HTTPS 连接的端口号, 不指定则禁用")
	tunnelAddr := flag.String("tunnelAddr", ":4443", "监听客户端的端口号")
	domain := flag.String("domain", "zach-rock.com", "部署的域名")
	tlsCrt := flag.String("tlsCrt", "", "TLS 的 crt 文件地址")
	tlsKey := flag.String("tlsKey", "", "TLS 的 key 文件地址")
	logto := flag.String("log", "stdout", "指定一个写日志的地址。 'stdout' 表示写到终端上；'none' 表示不写日志。 ")
	loglevel := flag.String("log-level", "DEBUG", "日志记录等级. 可选项: DEBUG, INFO, WARNING, ERROR")
	flag.Parse()

	return &Options{
		httpAddr:   *httpAddr,
		httpsAddr:  *httpsAddr,
		tunnelAddr: *tunnelAddr,
		domain:     *domain,
		tlsCrt:     *tlsCrt,
		tlsKey:     *tlsKey,
		logto:      *logto,
		loglevel:   *loglevel,
	}
}
