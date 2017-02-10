
DROP TABLE T_MAN_BEHAVIOR_RECORD;

CREATE TABLE T_MAN_BEHAVIOR_RECORD
( 
	ID BIGINT(20) unsigned NOT NULL AUTO_INCREMENT,
	DEVICE_ID BIGINT(20),
	USER_ID BIGINT(20),
	START_TIME BIGINT(13) unsigned,
	TYPE_ID SMALLINT(5),
	PRIMARY KEY (ID)
);

DROP TABLE T_MAN_BEHAVIOR_TYPE;

CREATE TABLE T_MAN_BEHAVIOR_TYPE
(
	ID SMALLINT(5)unsigned NOT NULL AUTO_INCREMENT,
	TYPE VARCHAR(128),
	PRIMARY KEY (ID)
);

DROP TABLE T_MAN_MOVEMENT_RECORD;
 
CREATE TABLE T_MAN_BODY_MOTION_RECORD
(
	ID BIGINT(20) unsigned NOT NULL AUTO_INCREMENT,
	DEVICE_ID BIGINT(20),
	USER_ID BIGINT(20),
	START_TIME BIGINT(13),
	LEVEL_ID SMALLINT(5),
	ALGORITHM VARCHAR(4),
	PRIMARY KEY (ID)
);


-- ALTER TABLE ~T_MAN_MOVEMENT_RECORD~ ADD INDEX MOVEMENT_USERID_DEVICEID_INDEX( ~USER_ID,START_TIME~)  

DROP TABLE T_MAN_MOVEMENT_LEVEL;

CREATE TABLE T_MAN_MOVEMENT_LEVEL
(
	ID SMALLINT(5) unsigned NOT NULL AUTO_INCREMENT,
	LEVEL VARCHAR(128),
	PRIMARY KEY (ID)
);


DROP TABLE T_USER;
CREATE TABLE `T_USER` (
	`USER_ID` int(24) unsigned NOT NULL AUTO_INCREMENT,
	`USER_NAME` varchar(512) DEFAULT NULL,
	`PASSWORD` varchar(256) DEFAULT NULL,
	`USER_FULL_NAME` varchar(1024) DEFAULT NULL,
	`SEX` varchar(1) DEFAULT NULL,
	`PHONE` varchar(64) DEFAULT NULL,
	`EMAIL` varchar(1024) DEFAULT NULL,
	`WEIGHT_KILO` decimal(8,2) DEFAULT NULL,
	`WEIGHT_POUND` decimal(8,2) DEFAULT NULL,
	`ONLINE` int(2) DEFAULT NULL,
	`HEIGHT` int(3) DEFAULT NULL,
	`REGISTER_TIME` int(128) DEFAULT NULL,
	`TOKEN_TYPE` varchar(16) DEFAULT NULL,
	`SALT` varchar(128) DEFAULT NULL,
	`PROJECT_ID` int(24) DEFAULT NULL,
	PRIMARY KEY (`USER_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1028 DEFAULT CHARSET=latin1;

DROP TABLE T_DEVICE_MAN_RELATION;

CREATE TABLE `T_DEVICE_MAN_RELATION` (
	`ID` int(24) unsigned NOT NULL AUTO_INCREMENT,
	`USER_ID` int(24) DEFAULT NULL,
	`DEVICE_ID` int(24) DEFAULT NULL,
	`BOUND_TIME` int(16) DEFAULT NULL,
	`UNBOUND_TIME` int(16) DEFAULT NULL,
	`ACTIVE` int(1) DEFAULT NULL,
	PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

DROP TABLE T_DEVICE;
CREATE TABLE `T_DEVICE` (
	`ID` int(24) unsigned NOT NULL AUTO_INCREMENT,
	`DEVICE_SERIAL_NO` varchar(512) DEFAULT NULL,
	`DEVICE_NAME` varchar(512) DEFAULT NULL,
	`DEVICE_MAC_ADDRESS` varchar(24) DEFAULT NULL,
	`PROJECT_ID` int(10) DEFAULT NULL,
	`FIRMWARE_ID` int(10) DEFAULT NULL,
	PRIMARY KEY (`ID`),
	KEY `DEVICE_SERIAL_NO` (`DEVICE_SERIAL_NO`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

DROP TABLE T_ACCESS_CONTEXT;
CREATE TABLE `T_ACCESS_CONTEXT` (
	`ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
	`USER_NAME` varchar(512) DEFAULT NULL,
	`ACCESS_TOKEN` varchar(128) DEFAULT NULL,
	`TOKEN_TYPE` varchar(32) DEFAULT NULL,
	`CREATE_TIME` bigint(13) unsigned DEFAULT NULL,
	`EXPIRES_IN` int(9) unsigned DEFAULT NULL,
	`ACTIVE` tinyint(1) NOT NULL DEFAULT '1',
	PRIMARY KEY (`ID`),
	UNIQUE KEY `USER_NAME` (`USER_NAME`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

DROP TABLE T_MAN_HEALTH_MEDDO;
CREATE TABLE `T_MAN_HEALTH_MEDDO` (
	`ID` int(24) unsigned NOT NULL AUTO_INCREMENT,
	`DEVICE_ID` int(24) DEFAULT NULL,
	`START_TIME` int(16) DEFAULT NULL,
	`HEART_RATE` int(8) DEFAULT '0',
	`BREATH` int(8) DEFAULT '0',
	`ALGORITHM` varchar(4) DEFAULT NULL,
	`HEART_RATE_WEIGHT` int(4) DEFAULT '0',
	`BREATH_WEIGHT` int(4) DEFAULT '0',
	`LAST_UPDATE_TIME` bigint(20) DEFAULT NULL,
	`REALLY_DATA` int(2) DEFAULT NULL,
	PRIMARY KEY (`ID`),
	UNIQUE KEY `DEVICE_ID` (`DEVICE_ID`,`START_TIME`),
	KEY `TIME_DEVICE` (`LAST_UPDATE_TIME`,`DEVICE_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

DROP TABLE T_MAN_SLEEP_STATE;

CREATE TABLE `T_MAN_SLEEP_STATE` (
	`ID` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
	`DEVICE_ID` bigint(20) DEFAULT NULL,
	`START_TIME` bigint(15) DEFAULT NULL,
	`END_TIME` bigint(15) DEFAULT NULL,
	`SLEEP_STATE` smallint(5) DEFAULT NULL,
	`ALGORITHM` varchar(4) DEFAULT NULL,
	`UPDATE_TIME` bigint(20) DEFAULT NULL,
	PRIMARY KEY (`ID`),
	UNIQUE KEY `DEVICE_ID` (`DEVICE_ID`,`START_TIME`),
	KEY `I_SLEEP_TIME_SLEEP` (`DEVICE_ID`,`START_TIME`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;

CREATE TABLE `T_PROJECT` (
	`PROJECT_ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
	`PROJECT_NAME` varchar(512) DEFAULT NULL,
	`COMPANY_NAME` varchar(512) DEFAULT NULL,
	PRIMARY KEY (`PROJECT_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;


CREATE TABLE `T_R_PROJECT_FIRMWARE` (
	`FIRMWARE_ID` int(24) unsigned NOT NULL,
	`PROJECT_ID` int(24) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `T_UPGRADE_REQUEST_QUEUE` (
	`ID` int(24) unsigned NOT NULL AUTO_INCREMENT,
	`DEVICE_ID` bigint(20) NOT NULL,
	`PLAN_UPDATE_TIME` bigint(20) DEFAULT '0',
	`SRC_FIRMWARE_ID` int(24) DEFAULT NULL,
	`TARGET_FIRMWARE_ID` int(24) DEFAULT NULL,
	PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=277 DEFAULT CHARSET=latin1;

CREATE TABLE `T_UPGRADE_REQUEST_RECORD` (
	`ID` int(24) unsigned NOT NULL AUTO_INCREMENT,
	`DEVICE_ID` bigint(20) NOT NULL,
	`PLAN_UPDATE_TIME` bigint(20) DEFAULT '0',
	`UPDATE_TIME` bigint(20) DEFAULT '0',
	`UPDATE_RESULT` smallint(2) DEFAULT '0',
	`UPDATE_MESSAGE` varchar(4000) DEFAULT NULL,
	`SRC_FIRMWARE_ID` int(24) DEFAULT NULL,
	`TARGET_FIRMWARE_ID` int(24) DEFAULT NULL,
	PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=284 DEFAULT CHARSET=latin1;

CREATE TABLE `T_MAN_BODY_MOTION_SLEEP` (
	`DEVICE_ID` int(24) NOT NULL DEFAULT '0',
	`START_TIME` bigint(24) NOT NULL DEFAULT '0',
	`END_TIME` bigint(24) DEFAULT NULL,
	`DATA_NUMBER` int(10) DEFAULT NULL,
	`META_DATA` varchar(4000) DEFAULT NULL,
	`ALGORITHM` varchar(4) DEFAULT NULL,
	PRIMARY KEY (`DEVICE_ID`,`START_TIME`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `T_FIRMWARE` (
	`FIRMWARE_ID` int(24) unsigned NOT NULL AUTO_INCREMENT,
	`FIRMWARE_NAME` varchar(512) DEFAULT NULL,
	`VERSION` float(6,1) NOT NULL,
	`PATH` varchar(1024) NOT NULL,
	`UPLOAD_TIME` bigint(20) DEFAULT '0',
	`MD5` varchar(512) DEFAULT NULL,
	`CHECK_SUM` varchar(8) DEFAULT 'FFFF',
	PRIMARY KEY (`FIRMWARE_ID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;


CREATE TABLE `T_OPTICAL_DATA` (
	`DEVICE_ID` int(24) NOT NULL,
	`START_TIME` int(16) NOT NULL,
	`END_TIME` int(16) DEFAULT NULL,
	`UPDATE_TIME` bigint(20) DEFAULT NULL,
	`OPTICAL_DATA` text,
	PRIMARY KEY (`DEVICE_ID`,`START_TIME`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPRESSED;