--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nick` varchar(64) NOT NULL,
  `email` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL,
  `user_name` varchar(128) NOT NULL,
  `group` varchar(100) DEFAULT NULL,
  `registered_at` TIMESTAMP DEFAULT NULL,
  `approved_at` TIMESTAMP DEFAULT NULL,
  `disabled_at` TIMESTAMP DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT now(),
  `vhost` varchar(150) DEFAULT NULL,
  `umode` varchar(20) DEFAULT NULL,
  `opertype` varchar(32) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user` (`nick`),
  UNIQUE KEY `unique_user` (`nick`),
  KEY `index_multi` (`nick`,`password`,`approved_at`,`disabled_at`) USING BTREE,
  KEY `index_approved_at` (`approved_at`),
  KEY `index_disabled_at` (`disabled_at`)
) ENGINE=MyISAM AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='For InspIRCd SQL Auth';

--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

DROP TABLE IF EXISTS events;

CREATE TABLE events (
    id  BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nick VARCHAR(255) DEFAULT NULL,
    ip VARCHAR(255) DEFAULT NULL,
    host VARCHAR(255) DEFAULT NULL,
    user_name VARCHAR(255) DEFAULT NULL,
    ident VARCHAR(255) DEFAULT NULL,
    server VARCHAR(255) DEFAULT NULL,
    channel VARCHAR(255) DEFAULT NULL,
    message TEXT(1024) DEFAULT NULL,
    event VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT now()
);


--
-- Name: index_on_events_channel; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_on_events_channel ON events (channel);


--
-- Name: index_on_events_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_on_events_created_at ON events (created_at);


--
-- Name: index_on_events_event; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_on_events_event ON events (event);


--
-- Name: index_on_events_nick; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_on_events_nick ON events (nick);


