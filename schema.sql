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


