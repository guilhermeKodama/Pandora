--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bed; Type: TABLE; Schema: public; Owner: guilherme; Tablespace: 
--

CREATE TABLE bed (
    id integer NOT NULL,
    description character varying(255),
    hospital_id character varying(15)
);


ALTER TABLE bed OWNER TO guilherme;

--
-- Name: bed_id_seq; Type: SEQUENCE; Schema: public; Owner: guilherme
--

CREATE SEQUENCE bed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bed_id_seq OWNER TO guilherme;

--
-- Name: bed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: guilherme
--

ALTER SEQUENCE bed_id_seq OWNED BY bed.id;


--
-- Name: bed_staff; Type: TABLE; Schema: public; Owner: guilherme; Tablespace: 
--

CREATE TABLE bed_staff (
    id integer NOT NULL,
    bed_id integer,
    staff_cpf character varying(11)
);


ALTER TABLE bed_staff OWNER TO guilherme;

--
-- Name: bed_staff_id_seq; Type: SEQUENCE; Schema: public; Owner: guilherme
--

CREATE SEQUENCE bed_staff_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE bed_staff_id_seq OWNER TO guilherme;

--
-- Name: bed_staff_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: guilherme
--

ALTER SEQUENCE bed_staff_id_seq OWNED BY bed_staff.id;


--
-- Name: connection; Type: TABLE; Schema: public; Owner: guilherme; Tablespace: 
--

CREATE TABLE connection (
    id integer NOT NULL,
    sensor_id integer,
    user_id character varying(15),
    input_port integer NOT NULL,
    output_port integer NOT NULL,
    device_id integer
);


ALTER TABLE connection OWNER TO guilherme;

--
-- Name: connection_id_seq; Type: SEQUENCE; Schema: public; Owner: guilherme
--

CREATE SEQUENCE connection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE connection_id_seq OWNER TO guilherme;

--
-- Name: connection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: guilherme
--

ALTER SEQUENCE connection_id_seq OWNED BY connection.id;


--
-- Name: device; Type: TABLE; Schema: public; Owner: guilherme; Tablespace: 
--

CREATE TABLE device (
    id integer NOT NULL,
    bed_id integer
);


ALTER TABLE device OWNER TO guilherme;

--
-- Name: device_id_seq; Type: SEQUENCE; Schema: public; Owner: guilherme
--

CREATE SEQUENCE device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE device_id_seq OWNER TO guilherme;

--
-- Name: device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: guilherme
--

ALTER SEQUENCE device_id_seq OWNED BY device.id;


--
-- Name: event; Type: TABLE; Schema: public; Owner: guilherme; Tablespace: 
--

CREATE TABLE event (
    id integer NOT NULL,
    name text NOT NULL,
    description text
);


ALTER TABLE event OWNER TO guilherme;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: guilherme
--

CREATE SEQUENCE event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE event_id_seq OWNER TO guilherme;

--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: guilherme
--

ALTER SEQUENCE event_id_seq OWNED BY event.id;


--
-- Name: event_log; Type: TABLE; Schema: public; Owner: guilherme; Tablespace: 
--

CREATE TABLE event_log (
    id integer NOT NULL,
    event_id integer,
    timestamp_send timestamp without time zone NOT NULL,
    device_id integer,
    bed_id integer,
    staff_cpf character varying(15),
    hospital_cnpj character varying(15)
);


ALTER TABLE event_log OWNER TO guilherme;

--
-- Name: hospital; Type: TABLE; Schema: public; Owner: guilherme; Tablespace: 
--

CREATE TABLE hospital (
    cnpj character varying(15) NOT NULL,
    name text
);


ALTER TABLE hospital OWNER TO guilherme;

--
-- Name: medical_staff; Type: TABLE; Schema: public; Owner: guilherme; Tablespace: 
--

CREATE TABLE medical_staff (
    cpf character varying(11) NOT NULL,
    name text,
    token character varying(64),
    hospital_cnpj character varying(15)
);


ALTER TABLE medical_staff OWNER TO guilherme;

--
-- Name: notification_log_id_seq; Type: SEQUENCE; Schema: public; Owner: guilherme
--

CREATE SEQUENCE notification_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE notification_log_id_seq OWNER TO guilherme;

--
-- Name: notification_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: guilherme
--

ALTER SEQUENCE notification_log_id_seq OWNED BY event_log.id;


--
-- Name: sensor; Type: TABLE; Schema: public; Owner: guilherme; Tablespace: 
--

CREATE TABLE sensor (
    id integer NOT NULL,
    name text
);


ALTER TABLE sensor OWNER TO guilherme;

--
-- Name: sensor_id_seq; Type: SEQUENCE; Schema: public; Owner: guilherme
--

CREATE SEQUENCE sensor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sensor_id_seq OWNER TO guilherme;

--
-- Name: sensor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: guilherme
--

ALTER SEQUENCE sensor_id_seq OWNED BY sensor.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY bed ALTER COLUMN id SET DEFAULT nextval('bed_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY bed_staff ALTER COLUMN id SET DEFAULT nextval('bed_staff_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY connection ALTER COLUMN id SET DEFAULT nextval('connection_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY device ALTER COLUMN id SET DEFAULT nextval('device_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY event ALTER COLUMN id SET DEFAULT nextval('event_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY event_log ALTER COLUMN id SET DEFAULT nextval('notification_log_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY sensor ALTER COLUMN id SET DEFAULT nextval('sensor_id_seq'::regclass);


--
-- Data for Name: bed; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY bed (id, description, hospital_id) FROM stdin;
1	Bed 1	6969
2	Bed 2	6969
3	Bed 3	6969
4	Bed 4	6969
5	Bed 5	6969
6	Bed 6	6969
7	Bed 7	6969
\.


--
-- Name: bed_id_seq; Type: SEQUENCE SET; Schema: public; Owner: guilherme
--

SELECT pg_catalog.setval('bed_id_seq', 7, true);


--
-- Data for Name: bed_staff; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY bed_staff (id, bed_id, staff_cpf) FROM stdin;
1	1	0102
2	2	0102
\.


--
-- Name: bed_staff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: guilherme
--

SELECT pg_catalog.setval('bed_staff_id_seq', 2, true);


--
-- Data for Name: connection; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY connection (id, sensor_id, user_id, input_port, output_port, device_id) FROM stdin;
\.


--
-- Name: connection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: guilherme
--

SELECT pg_catalog.setval('connection_id_seq', 1, false);


--
-- Data for Name: device; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY device (id, bed_id) FROM stdin;
2	\N
1	1
\.


--
-- Name: device_id_seq; Type: SEQUENCE SET; Schema: public; Owner: guilherme
--

SELECT pg_catalog.setval('device_id_seq', 1, false);


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY event (id, name, description) FROM stdin;
1	Cardiac Arrest	\N
2	Bradycardia	\N
3	Tachycardia	\N
\.


--
-- Name: event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: guilherme
--

SELECT pg_catalog.setval('event_id_seq', 3, true);


--
-- Data for Name: event_log; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY event_log (id, event_id, timestamp_send, device_id, bed_id, staff_cpf, hospital_cnpj) FROM stdin;
9	1	2015-12-11 11:09:10.77101	1	1	0102	6969
10	1	2015-12-11 11:11:56.935544	1	1	0102	6969
11	1	2015-12-11 11:13:28.76045	1	1	0102	6969
12	1	2015-12-11 11:15:13.749544	1	1	0102	6969
13	1	2015-12-11 13:44:35.414117	1	1	0102	6969
14	1	2015-12-11 13:45:18.735899	1	1	0102	6969
16	1	2015-12-11 13:50:20.717352	1	1	0102	6969
17	1	2015-12-11 13:51:54.89713	1	1	0102	6969
18	1	2015-12-11 13:53:07.664342	1	1	0102	6969
19	1	2015-12-11 13:54:15.932349	1	1	0102	6969
20	1	2015-12-11 13:55:04.42236	1	1	0102	6969
21	1	2015-12-11 13:55:42.617532	1	1	0102	6969
22	1	2015-12-11 13:56:04.212132	1	1	0102	6969
23	1	2015-12-11 13:56:25.956153	1	1	0102	6969
24	1	2015-12-11 13:59:03.589942	1	1	0102	6969
25	1	2015-12-11 13:59:47.079719	1	1	0102	6969
26	1	2015-12-11 14:00:04.892684	1	1	0102	6969
27	1	2015-12-11 14:00:19.412348	1	1	0102	6969
28	1	2015-12-11 14:00:53.611886	1	1	0102	6969
29	1	2015-12-11 14:01:26.645055	1	1	0102	6969
30	1	2015-12-11 14:07:34.797948	1	1	0102	6969
31	1	2015-12-11 14:07:43.88221	1	1	0102	6969
32	1	2015-12-11 14:10:59.445772	1	1	0102	6969
33	1	2015-12-11 14:12:44.256822	1	1	0102	6969
34	1	2015-12-11 14:13:11.179821	1	1	0102	6969
35	1	2015-12-11 14:21:43.52802	1	1	0102	6969
36	1	2015-12-11 14:26:25.091366	1	1	0102	6969
37	1	2015-12-11 14:27:33.437357	1	1	0102	6969
38	1	2015-12-11 14:30:55.028899	1	1	0102	6969
39	1	2015-12-11 14:31:52.340322	1	1	0102	6969
40	1	2015-12-11 14:32:22.049	1	1	0102	6969
41	1	2015-12-11 14:33:28.928128	1	1	0102	6969
42	1	2015-12-11 14:34:27.082504	1	1	0102	6969
\.


--
-- Data for Name: hospital; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY hospital (cnpj, name) FROM stdin;
6969	Hospital Teste
\.


--
-- Data for Name: medical_staff; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY medical_staff (cpf, name, token, hospital_cnpj) FROM stdin;
0102	Kayron Cabral	b7e9c7249145c2b9e1bef5860a9d6f0a2e11a5c0c0511a7659c62e849498fb63	6969
\.


--
-- Name: notification_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: guilherme
--

SELECT pg_catalog.setval('notification_log_id_seq', 42, true);


--
-- Data for Name: sensor; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY sensor (id, name) FROM stdin;
1	ECG
\.


--
-- Name: sensor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: guilherme
--

SELECT pg_catalog.setval('sensor_id_seq', 1, true);


--
-- Name: bed_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY bed
    ADD CONSTRAINT bed_pkey PRIMARY KEY (id);


--
-- Name: bed_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY bed_staff
    ADD CONSTRAINT bed_staff_pkey PRIMARY KEY (id);


--
-- Name: connection_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY connection
    ADD CONSTRAINT connection_pkey PRIMARY KEY (id);


--
-- Name: device_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: hospital_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY hospital
    ADD CONSTRAINT hospital_pkey PRIMARY KEY (cnpj);


--
-- Name: medical_staff_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY medical_staff
    ADD CONSTRAINT medical_staff_pkey PRIMARY KEY (cpf);


--
-- Name: notification_log_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY event_log
    ADD CONSTRAINT notification_log_pkey PRIMARY KEY (id);


--
-- Name: sensor_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY sensor
    ADD CONSTRAINT sensor_pkey PRIMARY KEY (id);


--
-- Name: bed_id; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY device
    ADD CONSTRAINT bed_id FOREIGN KEY (bed_id) REFERENCES bed(id);


--
-- Name: bed_id; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY bed_staff
    ADD CONSTRAINT bed_id FOREIGN KEY (bed_id) REFERENCES bed(id);


--
-- Name: device_id_connection; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY connection
    ADD CONSTRAINT device_id_connection FOREIGN KEY (device_id) REFERENCES device(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event_log_bed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY event_log
    ADD CONSTRAINT event_log_bed_id_fkey FOREIGN KEY (bed_id) REFERENCES bed(id);


--
-- Name: event_log_device_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY event_log
    ADD CONSTRAINT event_log_device_id_fkey FOREIGN KEY (device_id) REFERENCES device(id);


--
-- Name: event_log_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY event_log
    ADD CONSTRAINT event_log_event_id_fkey FOREIGN KEY (event_id) REFERENCES event(id);


--
-- Name: event_log_hospital_cnpj_fkey; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY event_log
    ADD CONSTRAINT event_log_hospital_cnpj_fkey FOREIGN KEY (hospital_cnpj) REFERENCES hospital(cnpj);


--
-- Name: event_log_staff_cpf_fkey; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY event_log
    ADD CONSTRAINT event_log_staff_cpf_fkey FOREIGN KEY (staff_cpf) REFERENCES medical_staff(cpf);


--
-- Name: hospital_cnpj; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY medical_staff
    ADD CONSTRAINT hospital_cnpj FOREIGN KEY (hospital_cnpj) REFERENCES hospital(cnpj);


--
-- Name: hospital_id; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY bed
    ADD CONSTRAINT hospital_id FOREIGN KEY (hospital_id) REFERENCES hospital(cnpj);


--
-- Name: sensor_id_connection; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY connection
    ADD CONSTRAINT sensor_id_connection FOREIGN KEY (sensor_id) REFERENCES sensor(id);


--
-- Name: staff_cpf; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY bed_staff
    ADD CONSTRAINT staff_cpf FOREIGN KEY (staff_cpf) REFERENCES medical_staff(cpf);


--
-- Name: user_id_connection; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY connection
    ADD CONSTRAINT user_id_connection FOREIGN KEY (user_id) REFERENCES medical_staff(cpf);


--
-- Name: public; Type: ACL; Schema: -; Owner: guilherme
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM guilherme;
GRANT ALL ON SCHEMA public TO guilherme;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

