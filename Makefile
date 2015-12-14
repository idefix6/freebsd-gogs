# Created by: Yuri Victorovich <yuri@rawbw.com>
# $FreeBSD$

PORTNAME=		gogs
PORTVERSION=		0.151211
DISTVERSIONPREFIX=	v
CATEGORIES=		devel www

MAINTAINER=		yuri@rawbw.com
COMMENT=		Painless self-hosted Git service

LICENSE=		MIT
LICENSE_FILE=		${WRKSRC}/src/${GO_MAIN_PATH}/LICENSE

RUN_DEPENDS=		git:${PORTSDIR}/devel/git
REDIS_RUN_DEPENDS=	redis>=0:${PORTSDIR}/databases/redis
MEMCACHE_RUN_DEPENDS=	memcached>=0:${PORTSDIR}/databases/memcached

OPTIONS_DEFINE=		REDIS MEMCACHED PAM CERT
OPTIONS_RADIO=		DATABASE WEB
OPTIONS_RADIO_DATABASE=	MYSQL SQLITE PGSQL
OPTIONS_RADIO_WEB=	NOWEB NGINX APACHE24
OPTIONS_DEFAULT=	SQLITE NOWEB
MEMCACHED_DESC=		Build with MemCached support
CERT_DESC=		Generate self-signed certificates support
DATABASE_DESC=		Selection for database support
MYSQL_DESC=		MySQL Database Support
SQLITE_DESC=		SQLite Database Support
PGSQL_DESC=		Postgres SQL Database Support
WEB_DESC=		Webserver Support
NOWEB_DESC=			Do not depend on webserver to start gogs webfrontend
NGINX_DESC=		Nginx support
APACHE24_DESC=		Apache24 support

USE_GITHUB=		yes
GH_TUPLE+=		gogits:gogs:4d31eb2
GH_TUPLE+=		codegangsta:cli:0302d39:cli:gh
GH_TUPLE+=		go-macaron:binding:2502aaf:binding:gh
GH_TUPLE+=		go-macaron:cache:5617353:cache:gh
GH_TUPLE+=		go-macaron:captcha:8aa5919:captcha:gh
GH_TUPLE+=		go-macaron:csrf:715bca0:csrf:gh
GH_TUPLE+=		go-macaron:gzip:4938e9b:gzip:gh
GH_TUPLE+=		go-macaron:i18n:d2d3329:i18nM:gh
GH_TUPLE+=		go-macaron:inject:c5ab7bf:inject:gh
GH_TUPLE+=		go-macaron:session:66031fc:session:gh
GH_TUPLE+=		go-macaron:toolbox:ab30a81:toolbox:gh
GH_TUPLE+=		go-sql-driver:mysql:d512f20:mysql:gh
GH_TUPLE+=		go-xorm:core:acb6f00:core:gh
GH_TUPLE+=		go-xorm:xorm:a8fba4d:xorm:gh
GH_TUPLE+=		gogits:chardet:2404f77:chardet:gh
GH_TUPLE+=		gogits:git-shell:1ffc4bc:git-shell:gh
GH_TUPLE+=		gogits:go-gogs-client:4b541fa:go-gogs-client:gh
GH_TUPLE+=		issue9:identicon:f8c0d2c:identicon:gh
GH_TUPLE+=		kardianos:minwinsvc:cad6b2b:minwinsvc:gh
GH_TUPLE+=		klauspost:compress:42eb574:compress:gh
GH_TUPLE+=		klauspost:cpuid:eebb3ea:cpuid:gh
GH_TUPLE+=		klauspost:crc32:0aff1ea:crc32:gh
GH_TUPLE+=		lib:pq:11fc39a:pq:gh
GH_TUPLE+=		mcuadros:go-version:d52711f:go-version:gh
GH_TUPLE+=		microcosm-cc:bluemonday:4ac6f27:bluemonday:gh
GH_TUPLE+=		msteinert:pam:02ccfbf:pam:gh
GH_TUPLE+=		nfnt:resize:dc93e1b:resize:gh
GH_TUPLE+=		russross:blackfriday:3c4a488:blackfriday:gh
GH_TUPLE+=		shurcooL:sanitized_anchor_name:10ef21a:sanitized_anchor_name:gh
GH_TUPLE+=		Unknwon:cae:7f5e046:cae:gh
GH_TUPLE+=		Unknwon:com:28b053d:com:gh
GH_TUPLE+=		Unknwon:i18n:3b48b66:i18nU:gh
GH_TUPLE+=		Unknwon:paginater:7748a72:paginater:gh
# pkg
GH_TUPLE+=		go-asn1-ber:asn1-ber:4e86f43:asn1-ber:v1:pkg
GH_TUPLE+=		go-gomail:gomail:19acfc2:gomail:v2:pkg
GH_TUPLE+=		go-ini:ini:a4e5487:ini:v1:pkg
GH_TUPLE+=		go-ldap:ldap:e9a325d:ldap:v2:pkg
GH_TUPLE+=		go-macaron:macaron:1c6dd87:macaron:v1:pkg
GH_TUPLE+=		go-bufio:bufio:fe7b595:bufio:v1:pkg
# DB types
SQLITE_GH_TUPLE=	mattn:go-sqlite3:5651a9d:sqlite3:gh
#REDIS_GH_TUPLE+=	go-redis:redis:e617904:redis:v2:pkg
GH_TUPLE+=		go-redis:redis:e617904:redis:v2:pkg
#MEMCACHE_GH_TUPLE+=	bradfitz:gomemcache:72a6864:gomemcache:gh
GH_TUPLE+=		bradfitz:gomemcache:72a6864:gomemcache:gh

SUB_FILES=		gogs gogs-service pkg-message
SUB_LIST=		LOCALBASE=${LOCALBASE} PORTNAME=${PORTNAME} USER=${USER}
#PLIST_SUB_USER_GROUP=	USER="${USER}" GROUP="${GROUP}"

USES=				go
GO_MAIN_PATH=		github.com/gogits/gogs
GO_BASE=			21af302:net 87ad79f:text 7b85b09:crypto
SQLITE_GO_TAGS=		sqlite
REDIS_GO_TAGS=		redis
PAM_GO_TAGS=		pam
CERT_GO_TAGS=		cert
PGSQL_USES=		pgsql
MYSQL_GO_TAGS=		mysql

.include <bsd.port.options.mk>

# Default requirement for gogs rc script
_REQUIRE=		DAEMON NETWORKING

.if ${PORT_OPTIONS:MMYSQL}
_REQUIRE+=		mysql
.endif

.if ${PORT_OPTIONS:MPOSTGRESQL}
_REQUIRE+=		postgres
.endif

.if ${PORT_OPTIONS:MNGINX}
_REQUIRE+=		nginx
.endif

.if ${PORT_OPTIONS:MAPACHE24}
_REQUIRE+=		apache24
.endif

USER=			git
GROUP=			git
USERS=			${USER}
GROUPS=			${GROUP}

post-patch:
	@${REINPLACE_CMD} -i '' -e 's|RepoRootPath = sec\.Key.*|RepoRootPath = "/var/db/gogs/repositories"|' \
		${WRKSRC}/src/${GO_MAIN_PATH}/modules/setting/setting.go

post-build:
	@${REINPLACE_CMD} -i '' -e 's|RUN_USER = git|RUN_USER = ${USER}|' \
		${WRKSRC}/src/${GO_MAIN_PATH}/conf/app.ini

post-install:
	${INSTALL_SCRIPT} ${WRKDIR}/gogs ${STAGEDIR}${PREFIX}/bin/gogs
	${INSTALL_SCRIPT} ${WRKDIR}/gogs-service ${STAGEDIR}${PREFIX}/etc/rc.d/gogs
.for dir in conf public templates
	${CP} -R ${WRKSRC}/src/${GO_MAIN_PATH}/${dir} ${STAGEDIR}${LOCALBASE}/libexec/${PORTNAME}/
.endfor
	${MKDIR} ${STAGEDIR}${LOCALBASE}/libexec/${PORTNAME}/custom/conf
	${MV} ${STAGEDIR}${LOCALBASE}/libexec/${PORTNAME}/conf/app.ini ${STAGEDIR}${LOCALBASE}/etc/${PORTNAME}.ini.sample
	${LN} -s ${LOCALBASE}/etc/${PORTNAME}.ini.sample ${STAGEDIR}${LOCALBASE}/libexec/${PORTNAME}/conf/app.ini
	${LN} -s ${LOCALBASE}/etc/${PORTNAME}.ini        ${STAGEDIR}${LOCALBASE}/libexec/${PORTNAME}/custom/conf/app.ini
	#${CHOWN} ${USER}:${GROUP} ${STAGEDIR}${LOCALBASE}/etc/${PORTNAME}.ini.sample
	${MKDIR} ${STAGEDIR}/var/db/${PORTNAME}/data ${STAGEDIR}/var/db/${PORTNAME}/repositories ${STAGEDIR}/var/db/${PORTNAME}/home
	#${CHOWN} -R ${USER}:${GROUP} ${STAGEDIR}/var/db/${PORTNAME}
	${LN} -s /var/db/${PORTNAME}/data ${STAGEDIR}/${LOCALBASE}/libexec/${PORTNAME}/data
	${MKDIR} ${STAGEDIR}/var/log/gogs
	#${CHOWN} ${USER}:${GROUP} ${STAGEDIR}/var/log/gogs
	${LN} -s /var/log/gogs ${STAGEDIR}/${LOCALBASE}/libexec/${PORTNAME}/log

.include <bsd.port.mk>
