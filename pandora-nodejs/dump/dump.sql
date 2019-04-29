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

ALTER TABLE ONLY device ALTER COLUMN id SET DEFAULT nextval('device_id_seq'::regclass);


--
-- Data for Name: bed; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY bed (id, description, hospital_id) FROM stdin;
1	Bed 1	\N
\.


--
-- Name: bed_id_seq; Type: SEQUENCE SET; Schema: public; Owner: guilherme
--

SELECT pg_catalog.setval('bed_id_seq', 1, true);


--
-- Data for Name: bed_staff; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY bed_staff (id, bed_id, staff_cpf) FROM stdin;
1	1	0102
\.


--
-- Name: bed_staff_id_seq; Type: SEQUENCE SET; Schema: public; Owner: guilherme
--

SELECT pg_catalog.setval('bed_staff_id_seq', 1, true);


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
-- Data for Name: hospital; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY hospital (cnpj, name) FROM stdin;
6969	Hospital Teste
\.


--
-- Data for Name: medical_staff; Type: TABLE DATA; Schema: public; Owner: guilherme
--

COPY medical_staff (cpf, name, token, hospital_cnpj) FROM stdin;
0102	Kayron Cabral	14159c7d5fc267d3f0b10497a74a2135a04d6720a76e01d3e92b4d68abf00356	6969
\.


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
-- Name: device_pkey; Type: CONSTRAINT; Schema: public; Owner: guilherme; Tablespace: 
--

ALTER TABLE ONLY device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


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
-- Name: staff_cpf; Type: FK CONSTRAINT; Schema: public; Owner: guilherme
--

ALTER TABLE ONLY bed_staff
    ADD CONSTRAINT staff_cpf FOREIGN KEY (staff_cpf) REFERENCES medical_staff(cpf);


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

